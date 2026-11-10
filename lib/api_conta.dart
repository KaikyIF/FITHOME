import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Contrato do cliente de conta, também utilizado pelos testes do app.
typedef RequisicaoConta = Future<Map<String, dynamic>> Function(
  String acao,
  Map<String, Object?> dados,
);

/// Erro de acesso à conta que pode ser exibido no formulário.
class ErroApi implements Exception {
  const ErroApi(this.mensagem);

  final String mensagem;
}

/// Envia as credenciais ou o cadastro ao servidor e interpreta a resposta JSON.
Future<Map<String, dynamic>> requisitarConta(
  String acao,
  Map<String, Object?> dados,
) async {
  // O emulador Android alcança o computador pelo endereço 10.0.2.2.
  const urlConfigurada = String.fromEnvironment('FITHOME_API_URL');
  final enderecoPadrao = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
  final url = Uri.tryParse(
    urlConfigurada.isEmpty
        ? 'http://$enderecoPadrao:8088/api.php'
        : urlConfigurada,
  );
  if (url == null ||
      !url.hasAuthority ||
      (url.scheme != 'http' && url.scheme != 'https')) {
    throw const ErroApi('Configure um endereço válido para a API.');
  }

  const tempoLimite = Duration(seconds: 15);
  final cliente = HttpClient()..connectionTimeout = tempoLimite;
  try {
    return await (() async {
      // A query acao seleciona cadastro ou login no mesmo arquivo PHP.
      final requisicao = await cliente.postUrl(
        url.replace(queryParameters: {...url.queryParameters, 'acao': acao}),
      );
      // Evita reenviar os dados da conta após um redirecionamento.
      requisicao.followRedirects = false;
      requisicao.headers.contentType = ContentType.json;
      requisicao.write(jsonEncode(dados));
      final resposta = await requisicao.close();
      // Decodifica o JSON em UTF-8 para preservar acentos nas mensagens e nos dados.
      final corpo = jsonDecode(await resposta.transform(utf8.decoder).join());
      // A API responde com 200 no login e 201 ao criar a conta.
      if (resposta.statusCode != 200 && resposta.statusCode != 201) {
        final mensagem = corpo is Map<String, dynamic> ? corpo['erro'] : null;
        throw ErroApi(
          mensagem is String
              ? mensagem
              : 'A API não conseguiu concluir a solicitação.',
        );
      }
      // Confere a estrutura da resposta antes de devolver os dados à tela.
      if (corpo is! Map<String, dynamic> ||
          corpo['usuario'] is! Map<String, dynamic>) {
        throw const FormatException();
      }
      return corpo['usuario'] as Map<String, dynamic>;
    })()
        .timeout(tempoLimite);
  } on TimeoutException {
    throw const ErroApi('A API demorou para responder. Tente novamente.');
  } on IOException {
    throw const ErroApi('Não foi possível conectar à API do FitHome.');
  } on FormatException {
    throw const ErroApi('A API retornou uma resposta inesperada.');
  } finally {
    // Encerra a conexão mesmo se a operação exceder o tempo limite.
    cliente.close(force: true);
  }
}
