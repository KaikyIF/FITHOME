import 'package:flutter/material.dart';
import '../widgets/access_form.dart';

/// Coleta os dados de acesso de uma nova conta.
class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen(
      {super.key,
      required this.email,
      required this.password,
      required this.showPassword,
      required this.onTogglePassword,
      required this.submit,
      required this.name,
      required this.confirmPassword,
      required this.acceptedTerms,
      required this.onTermsChanged,
      required this.onBack});

  final TextEditingController email;
  final TextEditingController password;
  final bool showPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback submit;
  final TextEditingController name;
  final TextEditingController confirmPassword;
  final bool acceptedTerms;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => AccessForm(
      email: email,
      password: password,
      showPassword: showPassword,
      onTogglePassword: onTogglePassword,
      submit: submit,
      name: name,
      confirmPassword: confirmPassword,
      acceptedTerms: acceptedTerms,
      onTermsChanged: onTermsChanged,
      onBack: onBack);
}
