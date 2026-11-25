import 'package:flutter/material.dart';

import '../componentes/componentes_treino.dart';

/// Exibe o tempo ativo e os exercícios concluídos na sessão.
class TelaTreinoConcluido extends StatelessWidget {
  const TelaTreinoConcluido({
    super.key,
    required this.treino,
    required this.segundosAtivos,
    required this.exerciciosConcluidos,
    required this.totalExercicios,
    required this.aoVoltarInicio,
  });

  final String treino;
  final int segundosAtivos;
  final int exerciciosConcluidos;
  final int totalExercicios;
  final VoidCallback aoVoltarInicio;

  @override
  Widget build(BuildContext context) {
    final completo = exerciciosConcluidos == totalExercicios;
    final minutos = segundosAtivos ~/ 60;
    final segundos = segundosAtivos % 60;
    final tempo = minutos > 0 ? '$minutos min $segundos s' : '$segundos s';

    return ListView(
      children: [
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 48,
          backgroundColor: const Color(0xFFF1E4FF),
          foregroundColor: roxo,
          child: Icon(completo ? Icons.emoji_events : Icons.flag, size: 48),
        ),
        const SizedBox(height: 16),
        Text(
          completo ? 'Treino concluído!' : 'Treino encerrado',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(treino, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Exercícios concluídos'),
                trailing: Text('$exerciciosConcluidos de $totalExercicios'),
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Tempo ativo'),
                trailing: Text(tempo),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        botaoPrincipal('Voltar ao início', aoVoltarInicio),
      ],
    );
  }
}
