import 'package:flutter/material.dart';
import '../componentes/componentes_treino.dart';

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
          cabecalho(selecionado, 'Treino adaptado ao nível $nivel'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Aqueça antes de começar. Mantenha a postura correta, respeite seus limites e interrompa em caso de dor.',
              ),
            ),
          ),
          for (final exercicio in exercicios.take(4))
            CheckboxListTile(
              title: Text(exercicio),
              subtitle: const Text('3 séries • 12 repetições'),
              value: marcados.contains(exercicio),
              // Envia a marcação ao estado da sessão para atualizar a lista de exercícios.
              onChanged: (valor) => aoAlternar(exercicio, valor == true),
            ),
          const Spacer(),
          botaoPrincipal('Iniciar treino', aoIniciar),
        ],
      );
}
