import 'package:flutter/material.dart';
import 'componentes_avaliacao.dart';

/// Compartilha a aparência de login e cadastro. O cadastro fornece o campo de nome.
class FormularioAcesso extends StatelessWidget {
  const FormularioAcesso(
      {super.key,
      required this.email,
      required this.password,
      required this.mostrarSenha,
      required this.aoAlternarSenha,
      required this.enviar,
      this.nome,
      this.confirmarSenha,
      this.aceitouTermos = false,
      this.aoAlterarAceite,
      this.aoVoltar,
      this.aoCadastrar,
      this.aoEsquecerSenha});

  final TextEditingController email;
  final TextEditingController password;
  final bool mostrarSenha;
  final VoidCallback aoAlternarSenha;
  final VoidCallback enviar;
  final TextEditingController? nome;
  final TextEditingController? confirmarSenha;
  final bool aceitouTermos;
  final ValueChanged<bool?>? aoAlterarAceite;
  final VoidCallback? aoVoltar;
  final VoidCallback? aoCadastrar;
  final VoidCallback? aoEsquecerSenha;

  @override
  Widget build(BuildContext contexto) {
    // O campo de nome está presente no cadastro e define os campos adicionais do formulário.
    final cadastrando = nome != null;
    const termosUso = 'Termos de Uso e Política de Privacidade';
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
          builder: (contexto, restricoes) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (restricoes.maxHeight - 44)
                      .clamp(0.0, double.infinity)
                      .toDouble(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: cadastrando
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    if (cadastrando) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: botaoVoltar(aoVoltar!, branco: true),
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
                      cadastrando ? 'Criar Conta' : 'FitHome',
                      textAlign:
                          cadastrando ? TextAlign.start : TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cadastrando
                          ? 'Comece sua jornada fitness hoje'
                          : 'Seu treino personalizado em casa',
                      textAlign:
                          cadastrando ? TextAlign.start : TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(height: cadastrando ? 28 : 45),
                    if (cadastrando)
                      campoAvaliacao(
                        'Nome Completo',
                        nome!,
                        sugestao: 'Seu nome',
                        icon: Icons.person_outline,
                        claro: true,
                        capitalizacao: TextCapitalization.words,
                      ),
                    campoAvaliacao(
                      'Email',
                      email,
                      sugestao: 'seu@email.com',
                      icon: Icons.mail_outline,
                      claro: true,
                      teclado: TextInputType.emailAddress,
                    ),
                    campoAvaliacao(
                      'Senha',
                      password,
                      sugestao:
                          cadastrando ? 'Mínimo 6 caracteres' : '••••••••',
                      icon: Icons.lock_outline,
                      claro: true,
                      ocultar: !mostrarSenha,
                      alternar: aoAlternarSenha,
                    ),
                    if (cadastrando) ...[
                      campoAvaliacao(
                        'Confirmar Senha',
                        confirmarSenha!,
                        sugestao: 'Digite a senha novamente',
                        icon: Icons.lock_outline,
                        claro: true,
                        ocultar: true,
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        side: const BorderSide(color: Colors.white70),
                        activeColor: Colors.white,
                        checkColor: corDestaque,
                        title: const Text(
                          'Aceito os $termosUso do FitHome',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        value: aceitouTermos,
                        onChanged: aoAlterarAceite,
                      ),
                      const SizedBox(height: 20),
                    ] else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: aoEsquecerSenha,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text('Esqueceu a senha?'),
                        ),
                      ),
                    botaoAvaliacao(
                      cadastrando ? 'Criar Conta' : 'Entrar',
                      enviar,
                      branco: true,
                    ),
                    if (!cadastrando) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Ainda não tem uma conta?',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      botaoAvaliacao('Criar Conta', aoCadastrar!, branco: true),
                      const SizedBox(height: 26),
                      const Text(
                        'Ao continuar, você concorda com nossos $termosUso.',
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
