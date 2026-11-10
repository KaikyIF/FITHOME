import 'package:flutter/material.dart';
import '../componentes/componentes_avaliacao.dart';

/// Seleciona o nível de experiência.
class TelaNivel extends StatelessWidget {
  const TelaNivel(
      {super.key,
      required this.nivel,
      required this.aoSelecionar,
      required this.aoVoltar,
      required this.aoContinuar});

  final String nivel;
  final ValueChanged<String> aoSelecionar;
  final VoidCallback aoVoltar;
  final VoidCallback aoContinuar;

  @override
  Widget build(BuildContext contexto) => estruturaAvaliacao(
        titulo: 'Qual seu nível?',
        subtitulo: 'Escolha o nível que melhor representa você',
        rotulo: 'Continuar',
        aoContinuar: aoContinuar,
        voltar: aoVoltar,
        children: [
          for (final (titulo, descricao, icon, color) in const [
            (
              'Iniciante',
              'Começando agora ou retornando após pausa',
              Icons.track_changes,
              Color(0xFF00CE60),
            ),
            (
              'Intermediário',
              'Já treino regularmente',
              Icons.trending_up,
              Color(0xFF358DF4),
            ),
            (
              'Avançado',
              'Treino intenso e regular',
              Icons.emoji_events_outlined,
              Color(0xFFA657FA),
            ),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: opcaoAvaliacao(
                selecionado: nivel == titulo,
                aoTocar: () => aoSelecionar(titulo),
                child: Row(
                  children: [
                    iconeAvaliacao(icon, color),
                    const SizedBox(width: 14),
                    Expanded(child: legendaAvaliacao(titulo, descricao)),
                  ],
                ),
              ),
            ),
        ],
      );
}
