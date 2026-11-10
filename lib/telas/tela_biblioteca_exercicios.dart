import 'package:flutter/material.dart';
import '../componentes/componentes_treino.dart';

/// Lista os exercícios disponíveis.
class TelaBibliotecaExercicios extends StatelessWidget {
  const TelaBibliotecaExercicios(
      {super.key, required this.exercicios, required this.aoAbrirExercicio});

  final List<String> exercicios;
  final ValueChanged<String> aoAbrirExercicio;

  @override
  Widget build(BuildContext contexto) => ListView(
        children: [
          cabecalho(
            'Biblioteca de Exercícios',
            'Escolha o exercício e veja suas orientações.',
          ),
          for (final exercicio in exercicios)
            Card(
              child: ListTile(
                title: Text(exercicio),
                subtitle: Text(
                  exercicio == 'Flexão de Braço'
                      ? 'Peito, ombros e tríceps'
                      : 'Condicionamento e força',
                ),
                leading: const Icon(Icons.sports_gymnastics, color: roxo),
                onTap: () => aoAbrirExercicio(exercicio),
              ),
            ),
        ],
      );
}
