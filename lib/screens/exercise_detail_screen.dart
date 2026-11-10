import 'package:flutter/material.dart';
import '../widgets/training_widgets.dart';

/// Apresenta as instruções do exercício.
class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen(
      {super.key, required this.selected, required this.onAdd});

  final String selected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          heading(selected, 'Instruções do exercício'),
          const Icon(Icons.accessibility_new, size: 110, color: purple),
          const SizedBox(height: 22),
          const Text(
            'Mantenha a coluna alinhada, controle o movimento e respire normalmente. Ajuste a intensidade ao seu condicionamento.',
          ),
          const SizedBox(height: 24),
          option('Séries', '3 séries de 12 repetições', false, () {},
              Icons.repeat),
          const Spacer(),
          action('Adicionar ao treino', onAdd),
        ],
      );
}
