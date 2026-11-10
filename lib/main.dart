import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_conta.dart';

import 'telas/tela_detalhe_exercicio.dart';
import 'telas/tela_biblioteca_exercicios.dart';
import 'telas/tela_objetivo.dart';
import 'telas/tela_saude.dart';
import 'telas/tela_inicio.dart';
import 'telas/tela_nivel.dart';
import 'telas/tela_login.dart';
import 'telas/tela_medidas.dart';
import 'telas/tela_dados_pessoais.dart';
import 'telas/tela_perfil.dart';
import 'telas/tela_progresso.dart';
import 'telas/tela_cadastro.dart';
import 'telas/tela_treino_concluido.dart';
import 'telas/tela_treino.dart';
import 'telas/tela_cronometro.dart';
import 'componentes/componentes_avaliacao.dart';
import 'componentes/componentes_treino.dart';

// Inicializa o aplicativo no Flutter.
void main() => runApp(const FitHome());

/// Configura o tema e o cliente HTTP usado pelo app.
class FitHome extends StatelessWidget {
  const FitHome({super.key, this.requisicaoConta = requisitarConta});

  final RequisicaoConta requisicaoConta;
  @override
  Widget build(BuildContext contexto) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FitHome',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: roxo),
          scaffoldBackgroundColor: const Color(0xFFF9F7FB),
        ),
        home: AplicativoFitHome(requisicaoConta: requisicaoConta),
      );
}

/// Hospeda a navegação e mantém o estado da sessão entre as telas.
class AplicativoFitHome extends StatefulWidget {
  const AplicativoFitHome({super.key, required this.requisicaoConta});

  final RequisicaoConta requisicaoConta;
  @override
  State<AplicativoFitHome> createState() => _EstadoAplicativoFitHome();
}

class _EstadoAplicativoFitHome extends State<AplicativoFitHome> {
  // Os controladores sobrevivem à troca de telas durante o cadastro.
  final nome = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController();
  final idade = TextEditingController(),
      peso = TextEditingController(),
      altura = TextEditingController();
  final confirmarSenha = TextEditingController();
  // Os dois campos notificam o cartão de IMC pelo mesmo Listenable.
  late final medidas = Listenable.merge([peso, altura]);
  // O conjunto mantém cada condição de saúde selecionada uma única vez.
  final saude = <String>{};
  bool mostrarSenha = false, aceitouTermos = false;
  bool editandoNivel = false, editandoObjetivo = false;
  String escolhaAnterior = '';
  // Controla o indicador de carregamento e impede o envio duplicado do formulário.
  bool enviandoConta = false;
  int? idUsuario;

  // Guarda a opção atual para restaurá-la se a edição for cancelada.
  void editarEscolha({required bool ehNivel}) {
    setState(() {
      editandoNivel = ehNivel;
      editandoObjetivo = !ehNivel;
      escolhaAnterior = ehNivel ? nivel : objetivo;
      pagina = ehNivel ? 2 : 7;
    });
  }

  // A tela ativa e a aba selecionada são controladas separadamente.
  int pagina = 0, aba = 0, segundos = 40, concluidos = 0;
  String nivel = 'Iniciante',
      objetivo = 'Perder Peso',
      selecionado = 'Força em Casa';
  bool emExecucao = false, notificacoes = true;
  Timer? cronometro;
  final exercicios = <String>[
    'Flexão de Braço',
    'Agachamento',
    'Prancha',
    'Abdominal',
    'Polichinelo',
  ];
  // Guarda os exercícios marcados durante a sessão atual.
  final marcados = <String>{};
  // O contador de treinos fica no dispositivo e é separado por conta.
  Future<void> _salvarProgresso() async {
    // Captura a conta e o total antes da espera pelo armazenamento local.
    final id = idUsuario;
    final total = concluidos;
    if (id == null) return;
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setInt('completed_$id', total);
  }

  // Limpa os dados da sessão antes de voltar ao login.
  void sair() {
    setState(() {
      idUsuario = null;
      pagina = 0;
      aba = 0;
      nivel = 'Iniciante';
      objetivo = 'Perder Peso';
      selecionado = 'Força em Casa';
      concluidos = 0;
      notificacoes = true;
      marcados.clear();
      saude.clear();
      for (final campo in [
        nome,
        email,
        idade,
        peso,
        altura,
        password,
        confirmarSenha,
      ]) {
        campo.clear();
      }
      mostrarSenha = false;
      aceitouTermos = false;
    });
  }

  // Mantém um único cronômetro ativo por treino.
  void iniciarCronometro() {
    cronometro?.cancel();
    setState(() => emExecucao = true);
    cronometro = Timer.periodic(const Duration(seconds: 1), (cronometroAtivo) {
      if (!mounted) {
        cronometroAtivo.cancel();
        return;
      }
      if (segundos > 0) {
        setState(() => segundos--);
      } else {
        _concluirTreino();
      }
    });
  }

  // Pausa a contagem sem alterar os segundos restantes.
  void pausar() {
    cronometro?.cancel();
    setState(() => emExecucao = false);
  }

  // Libera o cronômetro e os controladores quando o app sai da árvore.
  @override
  void dispose() {
    cronometro?.cancel();
    for (final controlador in [
      nome,
      email,
      password,
      confirmarSenha,
      idade,
      peso,
      altura,
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  // Fecha o teclado antes de trocar de etapa.
  void _irPara(int destino) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => pagina = destino);
  }

  // Mantém o aviso acima do botão para permitir nova tentativa.
  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
      ));
  }

  // Ao cancelar uma edição no perfil, recupera a opção anterior.
  void _finalizarEdicao({bool cancelar = false}) {
    setState(() {
      if (cancelar && editandoNivel) nivel = escolhaAnterior;
      if (cancelar && editandoObjetivo) objetivo = escolhaAnterior;
      editandoNivel = false;
      editandoObjetivo = false;
      pagina = 6;
    });
  }

  // Só abre o app depois que a API confirmar e devolver a conta.
  Future<void> _enviarConta(String acao, Map<String, Object?> dados) async {
    // Ignora novos toques enquanto a requisição anterior estiver pendente.
    if (enviandoConta) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => enviandoConta = true);
    try {
      final conta = await widget.requisicaoConta(acao, dados);
      final id = conta['id'];
      final nomeConta = conta['nome'];
      final emailConta = conta['email'];
      final nivelConta = conta['nivel'];
      final objetivoConta = conta['objetivo'];
      final condicoes = conta['condicoes_saude'];
      final idadeConta = conta['idade'];
      final alturaConta = conta['altura'];
      final pesoConta = conta['peso'];
      // Avaliações anteriores à migração podem ter idade ou medidas nulas.
      if (id is! int ||
          nomeConta is! String ||
          emailConta is! String ||
          nivelConta is! String ||
          objetivoConta is! String ||
          condicoes is! List ||
          (idadeConta != null && idadeConta is! int) ||
          (alturaConta != null && alturaConta is! num) ||
          (pesoConta != null && pesoConta is! num)) {
        throw const ErroApi('A API retornou um cadastro incompleto.');
      }
      // O servidor confirma o perfil, e o dispositivo recupera o contador dessa conta.
      var concluidosLocais = 0;
      try {
        final preferencias = await SharedPreferences.getInstance();
        concluidosLocais = preferencias.getInt('completed_$id') ?? 0;
      } on Exception {
        // O histórico local é independente do acesso à conta.
      }
      // Uma resposta pode chegar depois que o widget já saiu da tela.
      if (!mounted) return;
      setState(() {
        idUsuario = id;
        nome.text = nomeConta;
        email.text = emailConta;
        idade.text = idadeConta?.toString() ?? '';
        altura.text = alturaConta?.toString() ?? '';
        peso.text = pesoConta?.toString() ?? '';
        nivel = nivelConta;
        objetivo = objetivoConta;
        saude
          ..clear()
          ..addAll(condicoes.whereType<String>());
        // A sessão não precisa guardar a senha após a autenticação.
        password.clear();
        confirmarSenha.clear();
        mostrarSenha = false;
        aceitouTermos = false;
        concluidos = concluidosLocais;
        pagina = 6;
        aba = 0;
      });
    } on ErroApi catch (erro) {
      if (mounted) _mostrarMensagem(erro.mensagem);
      // Desbloqueia o formulário também quando a API retorna um erro.
    } finally {
      if (mounted) setState(() => enviandoConta = false);
    }
  }

  // Reúne as respostas das etapas e envia o cadastro de uma só vez.
  void _cadastrar() {
    final anos = int.tryParse(idade.text.trim());
    final quilogramas = interpretarNumeroPositivo(peso.text);
    final centimetros = interpretarNumeroPositivo(altura.text);
    // Volta à etapa correspondente quando faltam dados obrigatórios.
    if (nome.text.trim().isEmpty || anos == null || anos < 1 || anos > 120) {
      _mostrarMensagem('Informe seu nome e uma idade entre 1 e 120 anos.');
      _irPara(3);
      return;
    }
    if (quilogramas == null ||
        quilogramas < 1 ||
        quilogramas > 999.99 ||
        centimetros == null ||
        centimetros < 30 ||
        centimetros > 300) {
      _mostrarMensagem('Confira o peso em kg e a altura em cm.');
      _irPara(4);
      return;
    }
    if (saude.isEmpty) {
      _mostrarMensagem('Selecione as condições de saúde ou marque Nenhuma.');
      _irPara(5);
      return;
    }
    // O servidor recebe as medidas e calcula o IMC que será gravado.
    _enviarConta('cadastro', {
      'nome': nome.text.trim(),
      'email': email.text.trim(),
      'senha': password.text,
      'idade': anos,
      'altura': centimetros,
      'peso': quilogramas,
      'nivel': nivel,
      'objetivo': objetivo,
      'condicoes_saude': saude.toList(),
    });
  }

  // Valida os dados de acesso antes de navegar ou chamar a API.
  void _enviarCredenciais({required bool cadastrando}) {
    if (cadastrando && nome.text.trim().isEmpty) {
      _mostrarMensagem('Informe seu nome.');
      return;
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.text.trim())) {
      _mostrarMensagem('Informe um e-mail válido.');
      return;
    }
    // O mínimo depende do fluxo. O bcrypt usa um limite de 72 bytes.
    final minimo = cadastrando ? 6 : 1;
    if (password.text.runes.length < minimo ||
        utf8.encode(password.text).length > 72) {
      _mostrarMensagem(
        'Confira a senha. No cadastro, use pelo menos 6 caracteres e até 72 bytes.',
      );
      return;
    }
    if (cadastrando &&
        (password.text != confirmarSenha.text || !aceitouTermos)) {
      _mostrarMensagem(
        password.text != confirmarSenha.text
            ? 'As senhas precisam ser iguais.'
            : 'Aceite os termos para criar a conta.',
      );
      return;
    }
    if (cadastrando) {
      _irPara(2);
    } else {
      _enviarConta('login', {
        'email': email.text.trim(),
        'senha': password.text,
      });
    }
  }

  // Mantém os dados do cadastro quando a pessoa avança ou volta entre etapas.
  Widget _telaAvaliacao() => switch (pagina) {
        0 => TelaLogin(
            email: email,
            password: password,
            mostrarSenha: mostrarSenha,
            aoAlternarSenha: _alternarVisibilidadeSenha,
            enviar: () => _enviarCredenciais(cadastrando: false),
            aoCadastrar: () => _irPara(1),
            aoEsquecerSenha: () => _mostrarMensagem(
              'A recuperação de senha ainda não está disponível no acesso local.',
            ),
          ),
        1 => TelaCadastro(
            email: email,
            password: password,
            mostrarSenha: mostrarSenha,
            aoAlternarSenha: _alternarVisibilidadeSenha,
            enviar: () => _enviarCredenciais(cadastrando: true),
            nome: nome,
            confirmarSenha: confirmarSenha,
            aceitouTermos: aceitouTermos,
            aoAlterarAceite: (valor) =>
                setState(() => aceitouTermos = valor ?? false),
            aoVoltar: () => _irPara(0),
          ),
        2 => TelaNivel(
            nivel: nivel,
            aoSelecionar: (valor) => setState(() => nivel = valor),
            aoVoltar: editandoNivel
                ? () => _finalizarEdicao(cancelar: true)
                : () => _irPara(1),
            aoContinuar: editandoNivel ? _finalizarEdicao : () => _irPara(3),
          ),
        3 => TelaDadosPessoais(
            nome: nome,
            idade: idade,
            aoVoltar: () => _irPara(2),
            aoContinuar: () => _irPara(4),
          ),
        4 => TelaMedidas(
            peso: peso,
            altura: altura,
            medidas: medidas,
            aoVoltar: () => _irPara(3),
            aoContinuar: () => _irPara(5),
          ),
        5 => TelaSaude(
            saude: saude,
            aoAlternar: _alternarCondicao,
            aoVoltar: () => _irPara(4),
            aoContinuar: () => _irPara(7),
          ),
        _ => TelaObjetivo(
            objetivo: objetivo,
            editandoObjetivo: editandoObjetivo,
            aoSelecionar: (valor) => setState(() => objetivo = valor),
            aoVoltar: editandoObjetivo
                ? () => _finalizarEdicao(cancelar: true)
                : () => _irPara(5),
            aoContinuar: editandoObjetivo ? _finalizarEdicao : _cadastrar,
          ),
      };

  // A opção Nenhuma é exclusiva e pode ser desmarcada como as demais.
  void _alternarCondicao(String condicao) => setState(() {
        if (saude.remove(condicao)) return;
        if (condicao == 'Nenhuma') {
          saude.clear();
        } else {
          saude.remove('Nenhuma');
        }
        saude.add(condicao);
      });

  void _alternarVisibilidadeSenha() =>
      setState(() => mostrarSenha = !mostrarSenha);

  // Escolhe a aba exibida pela barra de navegação.
  Widget _telaAba() => switch (aba) {
        0 => TelaInicio(
            nome: nome.text,
            nivel: nivel,
            concluidos: concluidos,
            totalAtividades: marcados.length,
            aoAbrirTreino: (valor) => setState(() {
              selecionado = valor;
              pagina = 8;
            }),
          ),
        1 => TelaBibliotecaExercicios(
            exercicios: exercicios,
            aoAbrirExercicio: (valor) => setState(() {
              selecionado = valor;
              pagina = 9;
            }),
          ),
        2 => TelaProgresso(concluidos: concluidos),
        _ => TelaPerfil(
            nome: nome.text,
            nivel: nivel,
            objetivo: objetivo,
            concluidos: concluidos,
            notificacoes: notificacoes,
            aoEditarObjetivo: () => editarEscolha(ehNivel: false),
            aoEditarNivel: () => editarEscolha(ehNivel: true),
            aoAlterarNotificacoes: (valor) =>
                setState(() => notificacoes = valor),
            aoSair: sair,
          ),
      };

  // As telas abertas a partir de uma aba compartilham a barra superior.
  Widget _telaTreino() => switch (pagina) {
        8 => TelaTreino(
            selecionado: selecionado,
            nivel: nivel,
            exercicios: exercicios,
            marcados: marcados,
            aoAlternar: (exercicio, marcado) => setState(() =>
                marcado ? marcados.add(exercicio) : marcados.remove(exercicio)),
            aoIniciar: () => setState(() {
              segundos = 40;
              pagina = 11;
            }),
          ),
        9 => TelaDetalheExercicio(
            selecionado: selecionado,
            aoAdicionar: () => setState(() {
              marcados.add(selecionado);
              pagina = 8;
            }),
          ),
        10 => TelaTreinoConcluido(
            aoVoltarInicio: () => setState(() {
              pagina = 6;
              aba = 0;
            }),
          ),
        11 => TelaCronometro(
            selecionado: selecionado,
            segundos: segundos,
            emExecucao: emExecucao,
            aoAlternar: emExecucao ? pausar : iniciarCronometro,
            aoReiniciar: () => setState(() => segundos = 40),
            aoConcluir: _concluirTreino,
          ),
        _ => _telaAba(),
      };

  // Compartilha a conclusão entre o fim do cronômetro e o botão manual.
  void _concluirTreino() {
    cronometro?.cancel();
    setState(() {
      emExecucao = false;
      concluidos++;
      pagina = 10;
    });
    _salvarProgresso();
  }

  @override
  Widget build(BuildContext contexto) {
    // A tela de objetivo pertence à avaliação mesmo com o identificador 7. O 6 abre as abas.
    final emAvaliacao = pagina <= 5 || pagina == 7;
    if (emAvaliacao) {
      // Bloqueia o formulário enquanto o servidor processa a solicitação.
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            AbsorbPointer(absorbing: enviandoConta, child: _telaAvaliacao()),
            if (enviandoConta)
              const SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(),
                ),
              ),
          ],
        ),
      );
    }
    final corpo = _telaTreino();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FitHome',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: roxo,
        leading: pagina == 8 || pagina == 9 || pagina == 11
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  pausar();
                  setState(() => pagina = pagina == 9 ? 6 : 8);
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20), child: corpo),
      ),
      bottomNavigationBar: (pagina == 6)
          ? NavigationBar(
              selectedIndex: aba,
              onDestinationSelected: (v) => setState(() => aba = v),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  label: 'Início',
                ),
                NavigationDestination(
                  icon: Icon(Icons.fitness_center),
                  label: 'Exercícios',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart),
                  label: 'Progresso',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Perfil',
                ),
              ],
            )
          : null,
    );
  }
}
