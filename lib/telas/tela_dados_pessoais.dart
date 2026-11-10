import 'package:flutter/material.dart';
import '../componentes/componentes_avaliacao.dart';

/// Coleta nome e idade.
class TelaDadosPessoais extends StatelessWidget {
  const TelaDadosPessoais(
      {super.key,
      required this.nome,
      required this.idade,
      required this.aoVoltar,
      required this.aoContinuar});

  final TextEditingController nome;
  final TextEditingController idade;
  final VoidCallback aoVoltar;
  final VoidCallback aoContinuar;

  @override
  Widget build(BuildContext contexto) => estruturaAvaliacao(
        titulo: 'Dados Pessoais',
        subtitulo: 'Vamos conhecer você melhor',
        etapa: 1,
        icon: Icons.person_outline,
        color: corDestaque,
        voltar: aoVoltar,
        aoContinuar: aoContinuar,
        rotulo: 'Continuar',
        children: [
          campoAvaliacao(
            'Nome',
            nome,
            sugestao: 'Seu nome',
            capitalizacao: TextCapitalization.words,
          ),
          campoAvaliacao(
            'Idade',
            idade,
            sugestao: 'Sua idade',
            teclado: TextInputType.number,
          ),
        ],
      );
}
