import 'package:flutter/material.dart';
import '../widgets/training_widgets.dart';

/// Mostra quantos treinos o usuário concluiu.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.completed});

  final int completed;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: purple),
            Text(
              '$completed treinos concluídos',
              style: const TextStyle(fontSize: 22),
            ),
          ],
        ),
      );
}
