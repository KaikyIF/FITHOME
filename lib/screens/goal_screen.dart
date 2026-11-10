import 'package:flutter/material.dart';
import '../widgets/onboarding_widgets.dart';

/// Permite escolher o objetivo no cadastro ou no perfil.
class GoalScreen extends StatelessWidget {
  const GoalScreen(
      {super.key,
      required this.goal,
      required this.editingGoal,
      required this.onSelected,
      required this.onBack,
      required this.onContinue});

  final String goal;
  final bool editingGoal;
  final ValueChanged<String> onSelected;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    const goals = [
      (
        'Perder Peso',
        'Queimar calorias e reduzir gordura',
        Icons.balance,
        Color(0xFFFF7134),
      ),
      (
        'Ganhar Massa',
        'Desenvolver músculos e força',
        Icons.fitness_center,
        Color(0xFF0DB8E9),
      ),
      (
        'Melhorar Saúde',
        'Bem-estar geral e energia',
        Icons.favorite_border,
        Color(0xFFF75294),
      ),
      (
        'Ganhar Flexibilidade',
        'Alongamento e mobilidade',
        Icons.bolt_outlined,
        Color(0xFFA976F5),
      ),
    ];
    Widget goalCard((String, String, IconData, Color) item) {
      final (title, description, icon, color) = item;
      return Expanded(
        child: onboardingChoice(
          selected: goal == title,
          onTap: () => onSelected(title),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              onboardingBadge(icon, color),
              const SizedBox(height: 10),
              onboardingCaption(title, description, centered: true),
            ],
          ),
        ),
      );
    }

    return onboardingLayout(
      title: 'Qual seu objetivo?',
      subtitle: 'Vamos criar seu plano de treino personalizado',
      label: editingGoal ? 'Salvar objetivo' : 'Começar a Treinar',
      back: onBack,
      onContinue: onContinue,
      children: [
        for (var index = 0; index < goals.length; index += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  goalCard(goals[index]),
                  const SizedBox(width: 14),
                  goalCard(goals[index + 1]),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
