import 'package:flutter/material.dart';
import 'onboarding_widgets.dart';

/// Compartilha a aparência de login e cadastro. O cadastro fornece o campo de nome.
class AccessForm extends StatelessWidget {
  const AccessForm(
      {super.key,
      required this.email,
      required this.password,
      required this.showPassword,
      required this.onTogglePassword,
      required this.submit,
      this.name,
      this.confirmPassword,
      this.acceptedTerms = false,
      this.onTermsChanged,
      this.onBack,
      this.onRegister,
      this.onForgotPassword});

  final TextEditingController email;
  final TextEditingController password;
  final bool showPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback submit;
  final TextEditingController? name;
  final TextEditingController? confirmPassword;
  final bool acceptedTerms;
  final ValueChanged<bool?>? onTermsChanged;
  final VoidCallback? onBack;
  final VoidCallback? onRegister;
  final VoidCallback? onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final registering = name != null;
    const legal = 'Termos de Uso e Política de Privacidade';
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9809E8), Color(0xFFF0269C)],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 44)
                      .clamp(0.0, double.infinity)
                      .toDouble(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: registering
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    if (registering) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: backButton(onBack!, white: true),
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      const Center(
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Color(0xFF7837BD),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home_rounded,
                                size: 31,
                                color: Colors.white,
                              ),
                              Icon(
                                Icons.fitness_center,
                                size: 19,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      registering ? 'Criar Conta' : 'FitHome',
                      textAlign:
                          registering ? TextAlign.start : TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      registering
                          ? 'Comece sua jornada fitness hoje'
                          : 'Seu treino personalizado em casa',
                      textAlign:
                          registering ? TextAlign.start : TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(height: registering ? 28 : 45),
                    if (registering)
                      onboardingInput(
                        'Nome Completo',
                        name!,
                        hint: 'Seu nome',
                        icon: Icons.person_outline,
                        light: true,
                        capitalization: TextCapitalization.words,
                      ),
                    onboardingInput(
                      'Email',
                      email,
                      hint: 'seu@email.com',
                      icon: Icons.mail_outline,
                      light: true,
                      keyboard: TextInputType.emailAddress,
                    ),
                    onboardingInput(
                      'Senha',
                      password,
                      hint: registering ? 'Mínimo 6 caracteres' : '••••••••',
                      icon: Icons.lock_outline,
                      light: true,
                      obscure: !showPassword,
                      toggle: onTogglePassword,
                    ),
                    if (registering) ...[
                      onboardingInput(
                        'Confirmar Senha',
                        confirmPassword!,
                        hint: 'Digite a senha novamente',
                        icon: Icons.lock_outline,
                        light: true,
                        obscure: true,
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        side: const BorderSide(color: Colors.white70),
                        activeColor: Colors.white,
                        checkColor: onboardingAccent,
                        title: const Text(
                          'Aceito os $legal do FitHome',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        value: acceptedTerms,
                        onChanged: onTermsChanged,
                      ),
                      const SizedBox(height: 20),
                    ] else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: onForgotPassword,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text('Esqueceu a senha?'),
                        ),
                      ),
                    onboardingButton(
                      registering ? 'Criar Conta' : 'Entrar',
                      submit,
                      white: true,
                    ),
                    if (!registering) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Ainda não tem uma conta?',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      onboardingButton('Criar Conta', onRegister!, white: true),
                      const SizedBox(height: 26),
                      const Text(
                        'Ao continuar, você concorda com nossos $legal.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
