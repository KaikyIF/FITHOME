import 'package:flutter/material.dart';

import '../componentes/componentes_treino.dart';
import '../dados/exercicios.dart';

/// Mostra o exercício atual, a contagem regressiva e o avanço do treino.
class TelaCronometro extends StatelessWidget {
  const TelaCronometro({
    super.key,
    required this.treino,
    required this.exercicio,
    required this.posicao,
    required this.total,
    required this.segundos,
    required this.duracaoExercicio,
    required this.emExecucao,
    required this.aoAlternar,
    required this.aoReiniciar,
    required this.aoConcluirExercicio,
    required this.aoConcluir,
  });

  final String treino;
  final String exercicio;
  final int posicao;
  final int total;
  final int segundos;
  final int duracaoExercicio;
  final bool emExecucao;
  final VoidCallback aoAlternar;
  final VoidCallback aoReiniciar;
  final VoidCallback aoConcluirExercicio;
  final VoidCallback aoConcluir;

  @override
  Widget build(BuildContext context) {
    final minutos = (segundos ~/ 60).toString().padLeft(2, '0');
    final resto = (segundos % 60).toString().padLeft(2, '0');
    final ficha = fichasExercicios[exercicio];
    return ListView(
      children: [
        cabecalho(treino, 'Exercício $posicao de $total'),
        LinearProgressIndicator(
          value: (posicao - 1 + (1 - segundos / duracaoExercicio)) / total,
          semanticsLabel: 'Andamento do treino',
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 24),
        Text(exercicio, style: Theme.of(context).textTheme.headlineSmall),
        if (ficha != null) ...[
          const SizedBox(height: 8),
          for (final (indice, passo) in ficha.instrucoes.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('${indice + 1}. $passo'),
            ),
        ],
        const SizedBox(height: 20),
        Text(
          '$minutos:$resto',
          textAlign: TextAlign.center,
          semanticsLabel: '$segundos segundos restantes',
          style: const TextStyle(
            fontSize: 64,
            color: roxo,
            fontWeight: FontWeight.bold,
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            FilledButton.icon(
              onPressed: aoAlternar,
              icon: Icon(emExecucao ? Icons.pause : Icons.play_arrow),
              label: Text(
                emExecucao
                    ? 'Pausar'
                    : segundos == duracaoExercicio
                        ? 'Iniciar exercício'
                        : 'Retomar',
              ),
            ),
            IconButton(
              tooltip: 'Reiniciar exercício',
              onPressed: aoReiniciar,
              icon: const Icon(Icons.restart_alt),
            ),
          ],
        ),
        const SizedBox(height: 20),
        botaoPrincipal('Concluir exercício', aoConcluirExercicio),
        if (posicao < total) ...[
          const SizedBox(height: 4),
          TextButton(
            onPressed: aoConcluir,
            child: const Text('Encerrar treino agora'),
          ),
        ] else
          TextButton(
            onPressed: aoConcluir,
            child: const Text('Encerrar sem concluir o exercício'),
          ),
      ],
    );
  }
}
