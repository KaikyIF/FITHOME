import 'package:flutter/material.dart';
import '../widgets/onboarding_widgets.dart';

/// Coleta nome e idade.
class PersonalDataScreen extends StatelessWidget {
  const PersonalDataScreen(
      {super.key,
      required this.name,
      required this.age,
      required this.onBack,
      required this.onContinue});

  final TextEditingController name;
  final TextEditingController age;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => onboardingLayout(
        title: 'Dados Pessoais',
        subtitle: 'Vamos conhecer você melhor',
        step: 1,
        icon: Icons.person_outline,
        color: onboardingAccent,
        back: onBack,
        onContinue: onContinue,
        label: 'Continuar',
        children: [
          onboardingInput(
            'Nome',
            name,
            hint: 'Seu nome',
            capitalization: TextCapitalization.words,
          ),
          onboardingInput(
            'Idade',
            age,
            hint: 'Sua idade',
            keyboard: TextInputType.number,
          ),
        ],
      );
}
