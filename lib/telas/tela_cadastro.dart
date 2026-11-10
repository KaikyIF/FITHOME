import 'package:flutter/material.dart';
import '../componentes/formulario_acesso.dart';

/// Coleta os dados de acesso de uma nova conta.
class TelaCadastro extends StatelessWidget {
  const TelaCadastro(
      {super.key,
      required this.email,
      required this.password,
      required this.mostrarSenha,
      required this.aoAlternarSenha,
      required this.enviar,
      required this.nome,
      required this.confirmarSenha,
      required this.aceitouTermos,
      required this.aoAlterarAceite,
      required this.aoVoltar});

  final TextEditingController email;
  final TextEditingController password;
  final bool mostrarSenha;
  final VoidCallback aoAlternarSenha;
  final VoidCallback enviar;
  final TextEditingController nome;
  final TextEditingController confirmarSenha;
  final bool aceitouTermos;
  final ValueChanged<bool?> aoAlterarAceite;
  final VoidCallback aoVoltar;

  @override
  Widget build(BuildContext contexto) => FormularioAcesso(
      email: email,
      password: password,
      mostrarSenha: mostrarSenha,
      aoAlternarSenha: aoAlternarSenha,
      enviar: enviar,
      nome: nome,
      confirmarSenha: confirmarSenha,
      aceitouTermos: aceitouTermos,
      aoAlterarAceite: aoAlterarAceite,
      aoVoltar: aoVoltar);
}
