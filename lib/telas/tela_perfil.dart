import 'package:flutter/material.dart';
import '../componentes/componentes_treino.dart';

/// Mostra os dados e as preferências da sessão.
class TelaPerfil extends StatelessWidget {
  const TelaPerfil(
      {super.key,
      required this.nome,
      required this.nivel,
      required this.objetivo,
      required this.concluidos,
      required this.notificacoes,
      required this.aoEditarObjetivo,
      required this.aoEditarNivel,
      required this.aoAlterarNotificacoes,
      required this.aoSair});

  final String nome;
  final String nivel;
  final String objetivo;
  final int concluidos;
  final bool notificacoes;
  final VoidCallback aoEditarObjetivo;
  final VoidCallback aoEditarNivel;
  final ValueChanged<bool> aoAlterarNotificacoes;
  final VoidCallback aoSair;

  @override
  Widget build(BuildContext contexto) => ListView(
        children: [
          cabecalho('Meu Perfil', 'Suas informações e preferências.'),
          const CircleAvatar(
            radius: 40,
            backgroundColor: roxo,
            child: Icon(Icons.person, size: 45, color: Colors.white),
          ),
          Center(
            child: Text(
              nome,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          cartaoOpcao(
            'Objetivo',
            objetivo,
            false,
            aoEditarObjetivo,
            Icons.flag,
          ),
          cartaoOpcao(
            'Nível',
            nivel,
            false,
            aoEditarNivel,
            Icons.trending_up,
          ),
          cartaoOpcao(
            'Treinos concluídos',
            '$concluidos',
            false,
            () {},
            Icons.emoji_events,
          ),
          SwitchListTile(
            title: const Text('Notificações'),
            value: notificacoes,
            onChanged: aoAlterarNotificacoes,
          ),
          botaoPrincipal('Sair', aoSair),
        ],
      );
}
