import 'package:flutter/material.dart';
import '../widgets/training_widgets.dart';

/// Apresenta os exercícios e permite marcá-los.
class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen(
      {super.key,
      required this.selected,
      required this.level,
      required this.exercises,
      required this.done,
      required this.onToggle,
      required this.onStart});

  final String selected;
  final String level;
  final List<String> exercises;
  final Set<String> done;
  final void Function(String, bool) onToggle;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          heading(selected, 'Treino adaptado ao nível $level'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Aqueça antes de começar. Mantenha a postura correta, respeite seus limites e interrompa em caso de dor.',
              ),
            ),
          ),
          for (final e in exercises.take(4))
            CheckboxListTile(
              title: Text(e),
              subtitle: const Text('3 séries • 12 repetições'),
              value: done.contains(e),
              // Envia a marcação ao estado da sessão para atualizar a lista de exercícios.
              onChanged: (value) => onToggle(e, value == true),
            ),
          const Spacer(),
          action('Iniciar treino', onStart),
        ],
      );
}
