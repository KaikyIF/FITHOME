import 'package:fithome/account_api.dart';
import 'package:fithome/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Garante que o botão esteja visível antes de simular o toque.
Future<void> button(WidgetTester tester, String label) async {
  final target = find.widgetWithText(FilledButton, label);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

// Simula uma tela de celular e injeta o cliente de conta usado pelo teste.
Future<void> start(WidgetTester tester, AccountRequest request) async {
  SharedPreferences.setMockInitialValues({'onboarded': true});
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(FitHome(accountRequest: request));
}

// Resposta de exemplo compartilhada pelos testes de cadastro e login.
Map<String, dynamic> account() => {
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
      (tester) async {
    var requests = 0;
    await start(tester, (action, data) async {
      requests++;
      expect(action, 'cadastro');
      expect(data, {
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
      if (requests == 1) throw const ApiException('Tente novamente.');
      return account();
    });
    final fields = find.byType(TextField);
    await button(tester, 'Criar Conta');
    for (final (i, value) in [
      (0, 'Ana'),
      (1, 'ana@example.com'),
      (2, 'Senha123'),
      (3, 'Senha123')
    ]) {
      await tester.enterText(fields.at(i), value);
    }
    final terms = find.byType(CheckboxListTile);
    await tester.ensureVisible(terms);
    await tester.tap(terms);
    await tester.pumpAndSettle();
    await button(tester, 'Criar Conta');
    await button(tester, 'Continuar');
    await tester.enterText(fields.at(1), '25');
    await button(tester, 'Continuar');
    await tester.enterText(fields.at(0), '52');
    await tester.enterText(fields.at(1), '172');
    await tester.pump();
    expect(find.text('17,6'), findsOneWidget);
    await tester.enterText(fields.at(0), '52,1');
    await tester.pump();
    expect(find.text('17,6'), findsOneWidget);
    await button(tester, 'Continuar');
    await tester.tap(find.text('Nenhuma'));
    await tester.pumpAndSettle();
    await button(tester, 'Finalizar Avaliação');
    await tester.tap(find.text('Ganhar Flexibilidade'));
    await tester.pumpAndSettle();
    expect(requests, 0);
    await button(tester, 'Começar a Treinar');
    expect(find.text('Tente novamente.'), findsOneWidget);
    expect(find.text('Qual seu objetivo?'), findsOneWidget);
    await button(tester, 'Começar a Treinar');
    expect(requests, 2);
    expect(find.textContaining('Olá, Ana!'), findsOneWidget);
  });

  testWidgets('Login depende da resposta da API', (tester) async {
    await start(tester, (action, data) async {
      expect(action, 'login');
      expect(data['email'], 'ana@example.com');
      if (data['senha'] != 'Senha123') {
        throw const ApiException('E-mail ou senha inválidos.');
      }
      return account();
    });
    expect(find.text('Entrar'), findsOneWidget);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'ana@example.com');
    await tester.enterText(fields.at(1), 'errada');
    await button(tester, 'Entrar');
    expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
    await tester.enterText(fields.at(1), 'Senha123');
    await button(tester, 'Entrar');
    expect(find.textContaining('Olá, Ana!'), findsOneWidget);
  });

  // Confere a ligação entre as classes das telas de treino e as abas do app.
  testWidgets('Navega entre as telas de exercício, treino e perfil',
      (tester) async {
    await start(tester, (action, data) async => account());
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'ana@example.com');
    await tester.enterText(fields.at(1), 'Senha123');
    await button(tester, 'Entrar');

    Future<void> tapText(String label) async {
      final target = find.text(label);
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    await tapText('Exercícios');
    expect(find.text('Biblioteca de Exercícios'), findsOneWidget);
    await tapText('Flexão de Braço');
    expect(find.text('Instruções do exercício'), findsOneWidget);
    await button(tester, 'Adicionar ao treino');
    await button(tester, 'Iniciar treino');
    expect(find.text('Treino em andamento'), findsOneWidget);
    await button(tester, 'Finalizar treino');
    expect(find.text('Parabéns!'), findsOneWidget);
    await button(tester, 'Voltar ao início');
    await tapText('Progresso');
    expect(find.text('1 treinos concluídos'), findsOneWidget);
    await tapText('Perfil');
    expect(find.text('Meu Perfil'), findsOneWidget);
    await button(tester, 'Sair');
    expect(find.text('Entrar'), findsOneWidget);
  });
}
