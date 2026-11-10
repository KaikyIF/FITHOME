import 'package:flutter/material.dart';
import '../componentes/componentes_treino.dart';

/// Exibe a contagem regressiva e seus controles.
class TelaCronometro extends StatelessWidget {
  const TelaCronometro(
      {super.key,
      required this.selecionado,
      required this.segundos,
      required this.emExecucao,
      required this.aoAlternar,
      required this.aoReiniciar,
      required this.aoConcluir});

  final String selecionado;
  final int segundos;
  final bool emExecucao;
  final VoidCallback aoAlternar;
  final VoidCallback aoReiniciar;
  final VoidCallback aoConcluir;

  @override
  Widget build(BuildContext contexto) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          cabecalho('Treino em andamento', selecionado),
          const Spacer(),
          Text(
            '$segundos',
            style: const TextStyle(
              fontSize: 100,
              color: roxo,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('segundos restantes'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: aoAlternar,
                icon: Icon(emExecucao ? Icons.pause : Icons.play_arrow),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: aoReiniciar,
                icon: const Icon(Icons.restart_alt),
              ),
            ],
          ),
          const Spacer(),
          botaoPrincipal('Finalizar treino', aoConcluir),
        ],
      );
}
