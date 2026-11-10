import 'package:fithome/api_conta.dart';
import 'package:fithome/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Garante que o botão esteja visível antes de simular o toque.
Future<void> tocarBotao(WidgetTester testador, String rotulo) async {
  final alvo = find.widgetWithText(FilledButton, rotulo);
  await testador.ensureVisible(alvo);
  await testador.tap(alvo);
  await testador.pumpAndSettle();
}

// Simula uma tela de celular e injeta o cliente de conta usado pelo teste.
Future<void> iniciarTeste(
    WidgetTester testador, RequisicaoConta requisicao) async {
  SharedPreferences.setMockInitialValues({'onboarded': true});
  testador.view.physicalSize = const Size(390, 844);
  testador.view.devicePixelRatio = 1;
  addTearDown(testador.view.resetPhysicalSize);
  addTearDown(testador.view.resetDevicePixelRatio);
  await testador.pumpWidget(FitHome(requisicaoConta: requisicao));
}

// Resposta de exemplo compartilhada pelos testes de cadastro e login.
Map<String, dynamic> conta() => {
      'id': 1,
      'nome': 'Ana',
      'email': 'ana@example.com',
      'idade': 25,
      'altura': 172,
      'peso': 52.1,
      'imc': 17.61,
      'nivel': 'Iniciante',
      'objetivo': 'Ganhar Flexibilidade',
      'condicoes_saude': ['Nenhuma'],
    };

void main() {
  testWidgets('Envia o cadastro no fim e permite tentar novamente',
      (testador) async {
    var requisicoes = 0;
    await iniciarTeste(testador, (acao, dados) async {
      requisicoes++;
      expect(acao, 'cadastro');
      expect(dados, {
        'nome': 'Ana',
        'email': 'ana@example.com',
        'senha': 'Senha123',
        'idade': 25,
        'altura': 172,
        'peso': 52.1,
        'nivel': 'Iniciante',
        'objetivo': 'Ganhar Flexibilidade',
        'condicoes_saude': ['Nenhuma'],
      });
      if (requisicoes == 1) throw const ErroApi('Tente novamente.');
      return conta();
    });
    final campos = find.byType(TextField);
    await tocarBotao(testador, 'Criar Conta');
    for (final (i, valor) in [
      (0, 'Ana'),
      (1, 'ana@example.com'),
      (2, 'Senha123'),
      (3, 'Senha123')
    ]) {
      await testador.enterText(campos.at(i), valor);
    }
    final termos = find.byType(CheckboxListTile);
    await testador.ensureVisible(termos);
    await testador.tap(termos);
    await testador.pumpAndSettle();
    await tocarBotao(testador, 'Criar Conta');
    await tocarBotao(testador, 'Continuar');
    await testador.enterText(campos.at(1), '25');
    await tocarBotao(testador, 'Continuar');
    await testador.enterText(campos.at(0), '52');
    await testador.enterText(campos.at(1), '172');
    await testador.pump();
    expect(find.text('17,6'), findsOneWidget);
    await testador.enterText(campos.at(0), '52,1');
    await testador.pump();
    expect(find.text('17,6'), findsOneWidget);
    await tocarBotao(testador, 'Continuar');
    await testador.tap(find.text('Nenhuma'));
    await testador.pumpAndSettle();
    await tocarBotao(testador, 'Finalizar Avaliação');
    await testador.tap(find.text('Ganhar Flexibilidade'));
    await testador.pumpAndSettle();
    expect(requisicoes, 0);
    await tocarBotao(testador, 'Começar a Treinar');
    expect(find.text('Tente novamente.'), findsOneWidget);
    expect(find.text('Qual seu objetivo?'), findsOneWidget);
    await tocarBotao(testador, 'Começar a Treinar');
    expect(requisicoes, 2);
    expect(find.textContaining('Olá, Ana!'), findsOneWidget);
  });

  testWidgets('Login depende da resposta da API', (testador) async {
    await iniciarTeste(testador, (acao, dados) async {
      expect(acao, 'login');
      expect(dados['email'], 'ana@example.com');
      if (dados['senha'] != 'Senha123') {
        throw const ErroApi('E-mail ou senha inválidos.');
      }
      return conta();
    });
    expect(find.text('Entrar'), findsOneWidget);
    final campos = find.byType(TextField);
    await testador.enterText(campos.at(0), 'ana@example.com');
    await testador.enterText(campos.at(1), 'errada');
    await tocarBotao(testador, 'Entrar');
    expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
    await testador.enterText(campos.at(1), 'Senha123');
    await tocarBotao(testador, 'Entrar');
    expect(find.textContaining('Olá, Ana!'), findsOneWidget);
  });

  // Confere a ligação entre as classes das telas de treino e as abas do app.
  testWidgets('Navega entre as telas de exercício, treino e perfil',
      (testador) async {
    await iniciarTeste(testador, (acao, dados) async => conta());
    final campos = find.byType(TextField);
    await testador.enterText(campos.at(0), 'ana@example.com');
    await testador.enterText(campos.at(1), 'Senha123');
    await tocarBotao(testador, 'Entrar');

    Future<void> tocarTexto(String rotulo) async {
      final alvo = find.text(rotulo);
      await testador.ensureVisible(alvo);
      await testador.tap(alvo);
      await testador.pumpAndSettle();
    }

    await tocarTexto('Exercícios');
    expect(find.text('Biblioteca de Exercícios'), findsOneWidget);
    await tocarTexto('Flexão de Braço');
    expect(find.text('Instruções do exercício'), findsOneWidget);
    await tocarBotao(testador, 'Adicionar ao treino');
    await tocarBotao(testador, 'Iniciar treino');
    expect(find.text('Treino em andamento'), findsOneWidget);
    await tocarBotao(testador, 'Finalizar treino');
    expect(find.text('Parabéns!'), findsOneWidget);
    await tocarBotao(testador, 'Voltar ao início');
    await tocarTexto('Progresso');
    expect(find.text('1 treinos concluídos'), findsOneWidget);
    await tocarTexto('Perfil');
    expect(find.text('Meu Perfil'), findsOneWidget);
    await tocarBotao(testador, 'Sair');
    expect(find.text('Entrar'), findsOneWidget);
  });
}
