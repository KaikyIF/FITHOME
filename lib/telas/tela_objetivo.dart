import 'package:flutter/material.dart';
import '../componentes/componentes_avaliacao.dart';

/// Permite escolher o objetivo no cadastro ou no perfil.
class TelaObjetivo extends StatelessWidget {
  const TelaObjetivo(
      {super.key,
      required this.objetivo,
      required this.editandoObjetivo,
      required this.aoSelecionar,
      required this.aoVoltar,
      required this.aoContinuar});

  final String objetivo;
  final bool editandoObjetivo;
  final ValueChanged<String> aoSelecionar;
  final VoidCallback aoVoltar;
  final VoidCallback aoContinuar;

  @override
  Widget build(BuildContext contexto) {
    const objetivos = [
      (
        'Perder Peso',
        'Queimar calorias e reduzir gordura',
        Icons.balance,
        Color(0xFFFF7134),
      ),
      (
        'Ganhar Massa',
        'Desenvolver músculos e força',
        Icons.fitness_center,
        Color(0xFF0DB8E9),
      ),
      (
        'Melhorar Saúde',
        'Bem-estar geral e energia',
        Icons.favorite_border,
        Color(0xFFF75294),
      ),
      (
        'Ganhar Flexibilidade',
        'Alongamento e mobilidade',
        Icons.bolt_outlined,
        Color(0xFFA976F5),
      ),
    ];
    Widget cartaoObjetivo((String, String, IconData, Color) item) {
      final (titulo, descricao, icon, color) = item;
      return Expanded(
        child: opcaoAvaliacao(
          selecionado: objetivo == titulo,
          aoTocar: () => aoSelecionar(titulo),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconeAvaliacao(icon, color),
              const SizedBox(height: 10),
              legendaAvaliacao(titulo, descricao, centralizado: true),
            ],
          ),
        ),
      );
    }

    return estruturaAvaliacao(
      titulo: 'Qual seu objetivo?',
      subtitulo: 'Vamos criar seu plano de treino personalizado',
      rotulo: editandoObjetivo ? 'Salvar objetivo' : 'Começar a Treinar',
      voltar: aoVoltar,
      aoContinuar: aoContinuar,
      children: [
        for (var indice = 0; indice < objetivos.length; indice += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            // Mantém os dois cartões da linha com a mesma altura quando um texto ocupa mais linhas.
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cartaoObjetivo(objetivos[indice]),
                  const SizedBox(width: 14),
                  cartaoObjetivo(objetivos[indice + 1]),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
