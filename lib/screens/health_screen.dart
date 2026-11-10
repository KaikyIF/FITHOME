import 'package:flutter/material.dart';
import '../widgets/onboarding_widgets.dart';

/// Exibe as condições de saúde disponíveis.
class HealthScreen extends StatelessWidget {
  const HealthScreen(
      {super.key,
      required this.health,
      required this.onToggle,
      required this.onBack,
      required this.onContinue});

  final Set<String> health;
  final ValueChanged<String> onToggle;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => onboardingLayout(
        title: 'Condições de Saúde',
        subtitle: 'Selecione todas que se aplicam',
        step: 3,
        icon: Icons.favorite_border,
        color: const Color(0xFFDB2777),
        back: onBack,
        onContinue: onContinue,
        label: 'Finalizar Avaliação',
        children: [
          for (final condition in const [
            'Nenhuma',
            'Problemas cardíacos',
            'Diabetes',
            'Pressão alta',
            'Problemas articulares',
            'Problemas respiratórios',
            'Gravidez',
            'Lesão recente',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: onboardingChoice(
                selected: health.contains(condition),
                onTap: () => onToggle(condition),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(condition, style: const TextStyle(fontSize: 14)),
                ),
              ),
            ),
        ],
      );
}
