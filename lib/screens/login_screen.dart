import 'package:flutter/material.dart';
import '../widgets/access_form.dart';

/// Exibe o formulário de entrada.
class LoginScreen extends StatelessWidget {
  const LoginScreen(
      {super.key,
      required this.email,
      required this.password,
      required this.showPassword,
      required this.onTogglePassword,
      required this.submit,
      required this.onRegister,
      required this.onForgotPassword});

  final TextEditingController email;
  final TextEditingController password;
  final bool showPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback submit;
  final VoidCallback onRegister;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) => AccessForm(
      email: email,
      password: password,
      showPassword: showPassword,
      onTogglePassword: onTogglePassword,
      submit: submit,
      onRegister: onRegister,
      onForgotPassword: onForgotPassword);
}
