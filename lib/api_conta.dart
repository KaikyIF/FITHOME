import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
  const urlConfigurada = String.fromEnvironment('FITHOME_API_URL');
  // O emulador Android alcança o computador pelo endereço 10.0.2.2.
  final enderecoPadrao =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
          ? '10.0.2.2'
          : '127.0.0.1';
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

  final cliente = http.Client();
  try {
    // O pacote http usa o navegador na web e conexões nativas no Android.
    final requisicao = http.Request(
      'POST',
      url.replace(queryParameters: {...url.queryParameters, 'acao': acao}),
    )
      ..followRedirects = false
      ..headers['Content-Type'] = 'application/json; charset=utf-8'
      ..body = jsonEncode(dados);
    final resposta = await cliente
        .send(requisicao)
        .then(http.Response.fromStream)
        .timeout(const Duration(seconds: 15));
    final corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
    if (resposta.statusCode != 200 && resposta.statusCode != 201) {
      final mensagem = corpo is Map<String, dynamic> ? corpo['erro'] : null;
      throw ErroApi(
        mensagem is String
            ? mensagem
            : 'A API não conseguiu concluir a solicitação.',
      );
    }
    if (corpo is! Map<String, dynamic> ||
        corpo['usuario'] is! Map<String, dynamic>) {
      throw const FormatException();
    }
    return corpo['usuario'] as Map<String, dynamic>;
  } on TimeoutException {
    throw const ErroApi('A API demorou para responder. Tente novamente.');
  } on http.ClientException {
    throw const ErroApi('Não foi possível conectar à API do FitHome.');
  } on FormatException {
    throw const ErroApi('A API retornou uma resposta inesperada.');
  } finally {
    cliente.close();
  }
}
