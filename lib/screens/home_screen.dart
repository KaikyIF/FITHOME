import 'package:flutter/material.dart';
import '../widgets/training_widgets.dart';

/// Mostra o resumo e os treinos disponíveis.
class HomeScreen extends StatelessWidget {
  const HomeScreen(
      {super.key,
      required this.name,
      required this.level,
      required this.completed,
      required this.activityCount,
      required this.onWorkout});

  final String name;
  final String level;
  final int completed;
  final int activityCount;
  final ValueChanged<String> onWorkout;

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [purple, pink]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${name.isEmpty ? 'Atleta' : name}! 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Pronto para treinar?',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Text(
                      '$completed\nTreinos',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      '${activityCount}\nAtividades',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(level, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          heading('Treinos para você', 'Escolha um treino para começar.'),
          for (final x in ['Força em Casa', 'Cardio', 'Flexibilidade', 'HIIT'])
            Card(
              child: ListTile(
                leading: const Icon(Icons.fitness_center, color: purple),
                title: Text(x),
                subtitle: const Text('Treino em casa • Sem equipamentos'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onWorkout(x),
              ),
            ),
        ],
      );
}
