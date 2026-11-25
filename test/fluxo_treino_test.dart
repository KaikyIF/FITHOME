import 'package:fithome/main.dart';
import 'package:fithome/telas/tela_cronometro.dart';
import 'package:fithome/telas/tela_treino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> entrar(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(FitHome(
    requisicaoConta: (_, __) async => {
      'id': 7,
      'nome': 'Pessoa Teste',
      'email': 'teste@example.com',
      'nivel': 'Iniciante',
      'objetivo': 'Perder Peso',
      'condicoes_saude': ['Nenhuma'],
    },
  ));
  final campos = find.byType(EditableText);
  await tester.enterText(campos.at(0), 'teste@example.com');
  await tester.enterText(campos.at(1), 'senha');
  await tocar(tester, find.text('Entrar'));
}

Future<void> tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('cards abrem seus exercícios e voltam ao início', (tester) async {
    await entrar(tester);
    const primeiros = {
      'Cardio': 'Burpee',
      'Força': 'Flexão de Braço',
      'Yoga': 'Alongamento Posterior da Coxa',
      'HIIT': 'Burpee',
    };
    for (final item in primeiros.entries) {
      await tocar(tester, find.text(item.key).first);
      expect(find.byType(TelaTreino), findsOneWidget);
      expect(find.text(item.value), findsOneWidget);
      await tocar(tester, find.byTooltip('Voltar'));
      expect(find.text('Categorias'), findsOneWidget);
    }
    await tocar(tester, find.text('Treino intervalado'));
    expect(find.byType(TelaTreino), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Categorias'), findsOneWidget);
  });

  testWidgets('voltar do detalhe preserva a busca da biblioteca',
      (tester) async {
    await entrar(tester);
    await tocar(tester, find.text('Exercícios'));
    await tester.enterText(find.byType(TextField), 'flexao');
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Flexão de Braço'));
    expect(find.text('Como fazer'), findsOneWidget);
    await tocar(tester, find.text('Adicionar ao treino'));
    expect(find.text('Meu treino'), findsOneWidget);
    await tocar(tester, find.byTooltip('Voltar'));
    expect(find.text('Como fazer'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('flexao'), findsOneWidget);
    expect(find.text('1 exercício encontrado'), findsOneWidget);
    await tocar(tester, find.byTooltip('Voltar para o início'));
    expect(find.text('Categorias'), findsOneWidget);
  });

  testWidgets('execução pausa, avança e só registra o treino completo',
      (tester) async {
    await entrar(tester);
    await tocar(tester, find.text('Cardio'));
    await tocar(tester, find.text('Iniciar treino'));
    expect(find.text('Exercício 1 de 2'), findsOneWidget);
    await tocar(tester, find.text('Pausar'));
    expect(
        tester.widget<TelaCronometro>(find.byType(TelaCronometro)).emExecucao,
        isFalse);
    await tocar(tester, find.byTooltip('Reiniciar exercício'));
    await tocar(tester, find.byTooltip('Voltar'));
    expect(find.byType(TelaTreino), findsOneWidget);
    await tocar(tester, find.text('Iniciar treino'));
    await tocar(tester, find.text('Encerrar treino agora'));
    expect(find.text('Treino encerrado'), findsOneWidget);
    expect(find.text('0 de 2'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('completed_7'), isNull);
    await tocar(tester, find.byTooltip('Voltar'));
    await tocar(tester, find.text('Cardio'));
    await tocar(tester, find.text('Iniciar treino'));
    await tocar(tester, find.text('Concluir exercício'));
    expect(find.text('Exercício 2 de 2'), findsOneWidget);
    await tocar(tester, find.text('Concluir exercício'));
    expect(find.text('Treino concluído!'), findsOneWidget);
    expect(find.text('2 de 2'), findsOneWidget);
    expect(prefs.getInt('completed_7'), 1);
    await tocar(tester, find.text('Voltar ao início'));
    expect(find.text('Categorias'), findsOneWidget);
  });
}
