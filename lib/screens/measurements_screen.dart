import 'package:flutter/material.dart';
import '../widgets/onboarding_widgets.dart';

/// Coleta as medidas e mostra o IMC durante a digitação.
class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen(
      {super.key,
      required this.weight,
      required this.height,
      required this.measurements,
      required this.onBack,
      required this.onContinue});

  final TextEditingController weight;
  final TextEditingController height;
  final Listenable measurements;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => onboardingLayout(
        title: 'Medidas Corporais',
        subtitle: 'Para calcular seu IMC e personalizar treinos',
        step: 2,
        icon: Icons.monitor_heart_outlined,
        color: const Color(0xFF2563EB),
        back: onBack,
        onContinue: onContinue,
        label: 'Continuar',
        children: [
          onboardingInput('Peso (kg)', weight,
              hint: 'Ex.: 52',
              keyboard: const TextInputType.numberWithOptions(decimal: true)),
          onboardingInput('Altura (cm)', height,
              hint: 'Ex.: 172',
              keyboard: const TextInputType.numberWithOptions(decimal: true)),
          // Reconstrói o resultado quando o usuário edita peso ou altura.
          ListenableBuilder(
            listenable: measurements,
            builder: (context, _) {
              final kilograms = parsePositiveNumber(weight.text);
              final centimeters = parsePositiveNumber(height.text);
              // O IMC usa a altura em metros. O cartão reage aos dois campos.
              final meters = (centimeters ?? 0) / 100;
              final bmi = kilograms != null && meters > 0
                  ? kilograms / (meters * meters)
                  : null;
              // Formata com vírgula e uma casa decimal. O traço indica um cálculo indisponível.
              final value = bmi != null && bmi.isFinite && bmi > 0
                  ? bmi.toStringAsFixed(1).replaceAll('.', ',')
                  : '—';
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F2FC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Semantics(
                  // Permite que leitores de tela anunciem a mudança do resultado.
                  liveRegion: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seu IMC será',
                        style: TextStyle(
                          color: Color(0xFF7127A2),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        value,
                        style: const TextStyle(
                          color: Color(0xFF8510D5),
                          fontSize: 27,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
}
