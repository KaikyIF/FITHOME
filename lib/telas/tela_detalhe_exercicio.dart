import 'package:flutter/material.dart';

import '../componentes/componentes_treino.dart';
import '../dados/exercicios.dart';

/// Apresenta a ficha e os passos do exercício escolhido.
class TelaDetalheExercicio extends StatelessWidget {
  const TelaDetalheExercicio({
    super.key,
    required this.selecionado,
    required this.aoAdicionar,
  });

  final String selecionado;
  final VoidCallback aoAdicionar;

  @override
  Widget build(BuildContext context) {
    final ficha = fichasExercicios[selecionado];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              cabecalho(selecionado, 'Detalhes do exercício'),
              if (ficha != null) ...[
                Text(ficha.descricao),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(label: Text(ficha.nivel)),
                    Chip(label: Text('${ficha.segundos} s por intervalo')),
                    for (final categoria in ficha.categorias)
                      Chip(label: Text(categoria.rotulo)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Músculos trabalhados: ${ficha.musculos}'),
                const SizedBox(height: 24),
                Text('Como fazer',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                for (final (indice, passo) in ficha.instrucoes.indexed)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${indice + 1}')),
                      title: Text(passo),
                    ),
                  ),
              ] else
                const Text('Instruções indisponíveis para este exercício.'),
            ],
          ),
        ),
        if (ficha != null) ...[
          const SizedBox(height: 12),
          botaoPrincipal('Adicionar ao treino', aoAdicionar),
        ],
      ],
    );
  }
}
