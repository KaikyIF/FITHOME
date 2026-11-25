import 'package:flutter/material.dart';
import '../componentes/componentes_treino.dart';
import '../dados/exercicios.dart';

/// Apresenta os exercícios e permite marcá-los.
class TelaTreino extends StatelessWidget {
  const TelaTreino(
      {super.key,
      required this.selecionado,
      required this.nivel,
      required this.exercicios,
      required this.marcados,
      required this.aoAlternar,
      required this.aoIniciar});

  final String selecionado;
  final String nivel;
  final List<String> exercicios;
  final Set<String> marcados;
  final void Function(String, bool) aoAlternar;
  final VoidCallback aoIniciar;

  @override
  Widget build(BuildContext contexto) => Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                cabecalho(selecionado, 'Treino adaptado ao nível $nivel'),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Aqueça antes de começar. Mantenha a postura correta, respeite seus limites e interrompa em caso de dor.',
                    ),
                  ),
                ),
                for (final exercicio in exercicios)
                  CheckboxListTile(
                    title: Text(exercicio),
                    subtitle: Text(
                      '${fichasExercicios[exercicio]!.segundos} s por intervalo',
                    ),
                    value: marcados.contains(exercicio),
                    onChanged: (valor) => aoAlternar(exercicio, valor == true),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: marcados.isEmpty ? null : aoIniciar,
            style: FilledButton.styleFrom(
              backgroundColor: roxo,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Iniciar treino'),
          ),
        ],
      );
}
