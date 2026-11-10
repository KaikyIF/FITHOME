import 'package:flutter/material.dart';
import '../componentes/componentes_treino.dart';

/// Mostra quantos treinos o usuário concluiu.
class TelaProgresso extends StatelessWidget {
  const TelaProgresso({super.key, required this.concluidos});

  final int concluidos;

  @override
  Widget build(BuildContext contexto) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: roxo),
            Text(
              '$concluidos treinos concluídos',
              style: const TextStyle(fontSize: 22),
            ),
          ],
        ),
      );
}
