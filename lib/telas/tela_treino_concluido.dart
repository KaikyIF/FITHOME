import 'package:flutter/material.dart';
import '../componentes/componentes_treino.dart';

/// Confirma a conclusão do treino.
class TelaTreinoConcluido extends StatelessWidget {
  const TelaTreinoConcluido({super.key, required this.aoVoltarInicio});

  final VoidCallback aoVoltarInicio;

  @override
  Widget build(BuildContext contexto) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 100, color: roxo),
          cabecalho('Parabéns!', 'Você concluiu seu treino!'),
          botaoPrincipal(
            'Voltar ao início',
            aoVoltarInicio,
          ),
        ],
      );
}
