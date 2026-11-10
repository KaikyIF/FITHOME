import 'package:flutter/material.dart';
import '../componentes/componentes_treino.dart';

/// Mostra o resumo e os treinos disponíveis.
class TelaInicio extends StatelessWidget {
  const TelaInicio(
      {super.key,
      required this.nome,
      required this.nivel,
      required this.concluidos,
      required this.totalAtividades,
      required this.aoAbrirTreino});

  final String nome;
  final String nivel;
  final int concluidos;
  final int totalAtividades;
  final ValueChanged<String> aoAbrirTreino;

  @override
  Widget build(BuildContext contexto) => ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [roxo, rosa]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${nome.isEmpty ? 'Atleta' : nome}! 👋',
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
                      '$concluidos\nTreinos',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      '${totalAtividades}\nAtividades',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(nivel, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          cabecalho('Treinos para você', 'Escolha um treino para começar.'),
          for (final treino in [
            'Força em Casa',
            'Cardio',
            'Flexibilidade',
            'HIIT'
          ])
            Card(
              child: ListTile(
                leading: const Icon(Icons.fitness_center, color: roxo),
                title: Text(treino),
                subtitle: const Text('Treino em casa • Sem equipamentos'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => aoAbrirTreino(treino),
              ),
            ),
        ],
      );
}
