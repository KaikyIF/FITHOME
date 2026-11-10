import 'package:flutter/material.dart';
import '../widgets/onboarding_widgets.dart';

/// Seleciona o nível de experiência.
class LevelScreen extends StatelessWidget {
  const LevelScreen(
      {super.key,
      required this.level,
      required this.onSelected,
      required this.onBack,
      required this.onContinue});

  final String level;
  final ValueChanged<String> onSelected;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => onboardingLayout(
        title: 'Qual seu nível?',
        subtitle: 'Escolha o nível que melhor representa você',
        label: 'Continuar',
        onContinue: onContinue,
        back: onBack,
        children: [
          for (final (title, description, icon, color) in const [
            (
              'Iniciante',
              'Começando agora ou retornando após pausa',
              Icons.track_changes,
              Color(0xFF00CE60),
            ),
            (
              'Intermediário',
              'Já treino regularmente',
              Icons.trending_up,
              Color(0xFF358DF4),
            ),
            (
              'Avançado',
              'Treino intenso e regular',
              Icons.emoji_events_outlined,
              Color(0xFFA657FA),
            ),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: onboardingChoice(
                selected: level == title,
                onTap: () => onSelected(title),
                child: Row(
                  children: [
                    onboardingBadge(icon, color),
                    const SizedBox(width: 14),
                    Expanded(child: onboardingCaption(title, description)),
                  ],
                ),
              ),
            ),
        ],
      );
}
