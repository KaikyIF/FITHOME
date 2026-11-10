import 'package:flutter/material.dart';
import '../widgets/training_widgets.dart';

/// Lista os exercícios disponíveis.
class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen(
      {super.key, required this.exercises, required this.onExercise});

  final List<String> exercises;
  final ValueChanged<String> onExercise;

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          heading(
            'Biblioteca de Exercícios',
            'Escolha o exercício e veja suas orientações.',
          ),
          for (final e in exercises)
            Card(
              child: ListTile(
                title: Text(e),
                subtitle: Text(
                  e == 'Flexão de Braço'
                      ? 'Peito, ombros e tríceps'
                      : 'Condicionamento e força',
                ),
                leading: const Icon(Icons.sports_gymnastics, color: purple),
                onTap: () => onExercise(e),
              ),
            ),
        ],
      );
}
