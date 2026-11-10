import 'package:flutter/material.dart';
import '../componentes/componentes_treino.dart';

/// Apresenta as instruções do exercício.
class TelaDetalheExercicio extends StatelessWidget {
  const TelaDetalheExercicio(
      {super.key, required this.selecionado, required this.aoAdicionar});

  final String selecionado;
  final VoidCallback aoAdicionar;

  @override
  Widget build(BuildContext contexto) => Column(
        children: [
          cabecalho(selecionado, 'Instruções do exercício'),
          const Icon(Icons.accessibility_new, size: 110, color: roxo),
          const SizedBox(height: 22),
          const Text(
            'Mantenha a coluna alinhada, controle o movimento e respire normalmente. Ajuste a intensidade ao seu condicionamento.',
          ),
          const SizedBox(height: 24),
          cartaoOpcao('Séries', '3 séries de 12 repetições', false, () {},
              Icons.repeat),
          const Spacer(),
          botaoPrincipal('Adicionar ao treino', aoAdicionar),
        ],
      );
}
