import 'package:flutter/material.dart';
import '../componentes/componentes_avaliacao.dart';

/// Exibe as condições de saúde disponíveis.
class TelaSaude extends StatelessWidget {
  const TelaSaude(
      {super.key,
      required this.saude,
      required this.aoAlternar,
      required this.aoVoltar,
      required this.aoContinuar});

  final Set<String> saude;
  final ValueChanged<String> aoAlternar;
  final VoidCallback aoVoltar;
  final VoidCallback aoContinuar;

  @override
  Widget build(BuildContext contexto) => estruturaAvaliacao(
        titulo: 'Condições de Saúde',
        subtitulo: 'Selecione todas que se aplicam',
        etapa: 3,
        icon: Icons.favorite_border,
        color: const Color(0xFFDB2777),
        voltar: aoVoltar,
        aoContinuar: aoContinuar,
        rotulo: 'Finalizar Avaliação',
        children: [
          for (final condicao in const [
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
              child: opcaoAvaliacao(
                // A seleção vem do estado da avaliação e é preservada ao voltar para esta etapa.
                selecionado: saude.contains(condicao),
                aoTocar: () => aoAlternar(condicao),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(condicao, style: const TextStyle(fontSize: 14)),
                ),
              ),
            ),
        ],
      );
}
