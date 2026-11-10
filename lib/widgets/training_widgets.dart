import 'package:flutter/material.dart';

// Cores compartilhadas entre o tema do app e as telas de treino.
const purple = Color(0xFF9412F5);
const pink = Color(0xFFEF36A7);

/// Botão principal das telas de treino.
Widget action(String label, VoidCallback onTap) => SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: purple,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );

/// Título e subtítulo de uma tela.
Widget heading(String title, String subtitle) => Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );

/// Cartão de opção com ícone e ação.
Widget option(
  String title,
  String subtitle,
  bool active,
  VoidCallback onTap,
  IconData icon,
) =>
    Card(
      color: active ? const Color(0xFFF1E4FF) : Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: purple),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: active ? const Icon(Icons.check_circle, color: purple) : null,
      ),
    );
