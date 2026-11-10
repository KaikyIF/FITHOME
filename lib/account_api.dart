import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Contrato do cliente de conta, também utilizado pelos testes do app.
typedef AccountRequest = Future<Map<String, dynamic>> Function(
  String action,
  Map<String, Object?> data,
);

/// Erro de acesso à conta que pode ser exibido no formulário.
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;
}

/// Envia as credenciais ou o cadastro ao servidor e interpreta a resposta JSON.
Future<Map<String, dynamic>> requestAccount(
  String action,
  Map<String, Object?> data,
) async {
  // O emulador Android alcança o computador pelo endereço 10.0.2.2.
  const configuredUrl = String.fromEnvironment('FITHOME_API_URL');
  final defaultHost = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
  final url = Uri.tryParse(
    configuredUrl.isEmpty ? 'http://$defaultHost:8088/api.php' : configuredUrl,
  );
  if (url == null ||
      !url.hasAuthority ||
      (url.scheme != 'http' && url.scheme != 'https')) {
    throw const ApiException('Configure um endereço válido para a API.');
  }

  const timeout = Duration(seconds: 15);
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    return await (() async {
      // A query acao seleciona cadastro ou login no mesmo arquivo PHP.
      final request = await client.postUrl(
        url.replace(queryParameters: {...url.queryParameters, 'acao': action}),
      );
      // Evita reenviar os dados da conta após um redirecionamento.
      request.followRedirects = false;
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(data));
      final response = await request.close();
      // Decodifica o JSON em UTF-8 para preservar acentos nas mensagens e nos dados.
      final body = jsonDecode(await response.transform(utf8.decoder).join());
      // A API responde com 200 no login e 201 ao criar a conta.
      if (response.statusCode != 200 && response.statusCode != 201) {
        final message = body is Map<String, dynamic> ? body['erro'] : null;
        throw ApiException(
          message is String
              ? message
              : 'A API não conseguiu concluir a solicitação.',
        );
      }
      // Confere a estrutura da resposta antes de devolver os dados à tela.
      if (body is! Map<String, dynamic> ||
          body['usuario'] is! Map<String, dynamic>) {
        throw const FormatException();
      }
      return body['usuario'] as Map<String, dynamic>;
    })()
        .timeout(timeout);
  } on TimeoutException {
    throw const ApiException('A API demorou para responder. Tente novamente.');
  } on IOException {
    throw const ApiException('Não foi possível conectar à API do FitHome.');
  } on FormatException {
    throw const ApiException('A API retornou uma resposta inesperada.');
  } finally {
    // Encerra a conexão mesmo se a operação exceder o tempo limite.
    client.close(force: true);
  }
}
