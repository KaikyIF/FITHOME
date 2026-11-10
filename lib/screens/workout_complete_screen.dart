import 'package:flutter/material.dart';
import '../widgets/training_widgets.dart';

/// Confirma a conclusão do treino.
class WorkoutCompleteScreen extends StatelessWidget {
  const WorkoutCompleteScreen({super.key, required this.onHome});

  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 100, color: purple),
          heading('Parabéns!', 'Você concluiu seu treino!'),
          action(
            'Voltar ao início',
            onHome,
          ),
        ],
      );
}
