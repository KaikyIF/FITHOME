import 'package:flutter/material.dart';
import '../widgets/training_widgets.dart';

/// Exibe a contagem regressiva e seus controles.
class WorkoutTimerScreen extends StatelessWidget {
  const WorkoutTimerScreen(
      {super.key,
      required this.selected,
      required this.seconds,
      required this.playing,
      required this.onToggle,
      required this.onReset,
      required this.onFinish});

  final String selected;
  final int seconds;
  final bool playing;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          heading('Treino em andamento', selected),
          const Spacer(),
          Text(
            '$seconds',
            style: const TextStyle(
              fontSize: 100,
              color: purple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('segundos restantes'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: onToggle,
                icon: Icon(playing ? Icons.pause : Icons.play_arrow),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt),
              ),
            ],
          ),
          const Spacer(),
          action('Finalizar treino', onFinish),
        ],
      );
}
