import 'package:flutter/material.dart';

// Cores compartilhadas entre o tema do app e as telas de treino.
const roxo = Color(0xFF9412F5);
const rosa = Color(0xFFEF36A7);

/// Botão principal das telas de treino.
Widget botaoPrincipal(String rotulo, VoidCallback aoTocar) => SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: roxo,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: aoTocar,
        child: Text(rotulo),
      ),
    );

/// Título e subtítulo de uma tela.
Widget cabecalho(String titulo, String subtitulo) => Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(subtitulo, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );

/// Cartão de opção com ícone e ação.
Widget cartaoOpcao(
  String titulo,
  String subtitulo,
  bool ativo,
  VoidCallback aoTocar,
  IconData icon,
) =>
    Card(
      color: ativo ? const Color(0xFFF1E4FF) : Colors.white,
      child: ListTile(
        onTap: aoTocar,
        leading: Icon(icon, color: roxo),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: ativo ? const Icon(Icons.check_circle, color: roxo) : null,
      ),
    );
