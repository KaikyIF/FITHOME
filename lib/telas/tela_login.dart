import 'package:flutter/material.dart';
import '../componentes/formulario_acesso.dart';

/// Exibe o formulário de entrada.
class TelaLogin extends StatelessWidget {
  const TelaLogin(
      {super.key,
      required this.email,
      required this.password,
      required this.mostrarSenha,
      required this.aoAlternarSenha,
      required this.enviar,
      required this.aoCadastrar,
      required this.aoEsquecerSenha});

  final TextEditingController email;
  final TextEditingController password;
  final bool mostrarSenha;
  final VoidCallback aoAlternarSenha;
  final VoidCallback enviar;
  final VoidCallback aoCadastrar;
  final VoidCallback aoEsquecerSenha;

  @override
  Widget build(BuildContext contexto) => FormularioAcesso(
      email: email,
      password: password,
      mostrarSenha: mostrarSenha,
      aoAlternarSenha: aoAlternarSenha,
      enviar: enviar,
      aoCadastrar: aoCadastrar,
      aoEsquecerSenha: aoEsquecerSenha);
}
