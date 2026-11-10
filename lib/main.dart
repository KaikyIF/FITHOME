import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_api.dart';

import 'screens/exercise_detail_screen.dart';
import 'screens/exercise_library_screen.dart';
import 'screens/goal_screen.dart';
import 'screens/health_screen.dart';
import 'screens/home_screen.dart';
import 'screens/level_screen.dart';
import 'screens/login_screen.dart';
import 'screens/measurements_screen.dart';
import 'screens/personal_data_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/workout_complete_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/workout_timer_screen.dart';
import 'widgets/onboarding_widgets.dart';
import 'widgets/training_widgets.dart';

// Inicializa o aplicativo no Flutter.
void main() => runApp(const FitHome());

/// Configura o tema e o cliente HTTP usado pelo app.
class FitHome extends StatelessWidget {
  const FitHome({super.key, this.accountRequest = requestAccount});

  final AccountRequest accountRequest;
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FitHome',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: purple),
          scaffoldBackgroundColor: const Color(0xFFF9F7FB),
        ),
        home: FitApp(accountRequest: accountRequest),
      );
}

/// Hospeda a navegação e mantém o estado da sessão entre as telas.
class FitApp extends StatefulWidget {
  const FitApp({super.key, required this.accountRequest});

  final AccountRequest accountRequest;
  @override
  State<FitApp> createState() => _FitAppState();
}

class _FitAppState extends State<FitApp> {
  // Os controladores sobrevivem à troca de telas durante o cadastro.
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController();
  final age = TextEditingController(),
      weight = TextEditingController(),
      height = TextEditingController();
  final confirmPassword = TextEditingController();
  late final measurements = Listenable.merge([weight, height]);
  final health = <String>{};
  bool showPassword = false, acceptedTerms = false;
  bool editingLevel = false, editingGoal = false;
  String previousChoice = '';
  bool sendingAccount = false;
  int? userId;

  // Guarda a opção atual para restaurá-la se a edição for cancelada.
  void editChoice({required bool isLevel}) {
    setState(() {
      editingLevel = isLevel;
      editingGoal = !isLevel;
      previousChoice = isLevel ? level : goal;
      page = isLevel ? 2 : 7;
    });
  }

  // A tela ativa e a aba selecionada são controladas separadamente.
  int page = 0, tab = 0, seconds = 40, completed = 0;
  String level = 'Iniciante', goal = 'Perder Peso', selected = 'Força em Casa';
  bool playing = false, notifications = true;
  Timer? timer;
  final exercises = <String>[
    'Flexão de Braço',
    'Agachamento',
    'Prancha',
    'Abdominal',
    'Polichinelo',
  ];
  final done = <String>{};
  // O contador de treinos fica no dispositivo e é separado por conta.
  Future<void> _save() async {
    final id = userId;
    final count = completed;
    if (id == null) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('completed_$id', count);
  }

  // Limpa os dados da sessão antes de voltar ao login.
  void signOut() {
    setState(() {
      userId = null;
      page = 0;
      tab = 0;
      level = 'Iniciante';
      goal = 'Perder Peso';
      selected = 'Força em Casa';
      completed = 0;
      notifications = true;
      done.clear();
      health.clear();
      for (final field in [
        name,
        email,
        age,
        weight,
        height,
        password,
        confirmPassword,
      ]) {
        field.clear();
      }
      showPassword = false;
      acceptedTerms = false;
    });
  }

  // Mantém um único cronômetro ativo por treino.
  void startTimer() {
    timer?.cancel();
    setState(() => playing = true);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        _finishWorkout();
      }
    });
  }

  // Pausa a contagem sem alterar os segundos restantes.
  void pause() {
    timer?.cancel();
    setState(() => playing = false);
  }

  // Libera o cronômetro e os controladores quando o app sai da árvore.
  @override
  void dispose() {
    timer?.cancel();
    for (final c in [
      name,
      email,
      password,
      confirmPassword,
      age,
      weight,
      height,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // Fecha o teclado antes de trocar de etapa.
  void _go(int destination) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => page = destination);
  }

  // Mantém o aviso acima do botão para permitir nova tentativa.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
      ));
  }

  // Ao cancelar uma edição no perfil, recupera a opção anterior.
  void _finishEdit({bool cancel = false}) {
    setState(() {
      if (cancel && editingLevel) level = previousChoice;
      if (cancel && editingGoal) goal = previousChoice;
      editingLevel = false;
      editingGoal = false;
      page = 6;
    });
  }

  // Só abre o app depois que a API confirmar e devolver a conta.
  Future<void> _submitAccount(String action, Map<String, Object?> data) async {
    if (sendingAccount) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => sendingAccount = true);
    try {
      final account = await widget.accountRequest(action, data);
      final id = account['id'];
      final accountName = account['nome'];
      final accountEmail = account['email'];
      final accountLevel = account['nivel'];
      final accountGoal = account['objetivo'];
      final conditions = account['condicoes_saude'];
      final accountAge = account['idade'];
      final accountHeight = account['altura'];
      final accountWeight = account['peso'];
      // Avaliações anteriores à migração podem ter idade ou medidas nulas.
      if (id is! int ||
          accountName is! String ||
          accountEmail is! String ||
          accountLevel is! String ||
          accountGoal is! String ||
          conditions is! List ||
          (accountAge != null && accountAge is! int) ||
          (accountHeight != null && accountHeight is! num) ||
          (accountWeight != null && accountWeight is! num)) {
        throw const ApiException('A API retornou um cadastro incompleto.');
      }
      var localCompleted = 0;
      try {
        final preferences = await SharedPreferences.getInstance();
        localCompleted = preferences.getInt('completed_$id') ?? 0;
      } on Exception {
        // O histórico local é independente do acesso à conta.
      }
      if (!mounted) return;
      setState(() {
        userId = id;
        name.text = accountName;
        email.text = accountEmail;
        age.text = accountAge?.toString() ?? '';
        height.text = accountHeight?.toString() ?? '';
        weight.text = accountWeight?.toString() ?? '';
        level = accountLevel;
        goal = accountGoal;
        health
          ..clear()
          ..addAll(conditions.whereType<String>());
        // A sessão não precisa guardar a senha após a autenticação.
        password.clear();
        confirmPassword.clear();
        showPassword = false;
        acceptedTerms = false;
        completed = localCompleted;
        page = 6;
        tab = 0;
      });
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => sendingAccount = false);
    }
  }

  // Reúne as respostas das etapas e envia o cadastro de uma só vez.
  void _register() {
    final years = int.tryParse(age.text.trim());
    final kilograms = parsePositiveNumber(weight.text);
    final centimeters = parsePositiveNumber(height.text);
    if (name.text.trim().isEmpty || years == null || years < 1 || years > 120) {
      _showMessage('Informe seu nome e uma idade entre 1 e 120 anos.');
      _go(3);
      return;
    }
    if (kilograms == null ||
        kilograms < 1 ||
        kilograms > 999.99 ||
        centimeters == null ||
        centimeters < 30 ||
        centimeters > 300) {
      _showMessage('Confira o peso em kg e a altura em cm.');
      _go(4);
      return;
    }
    if (health.isEmpty) {
      _showMessage('Selecione as condições de saúde ou marque Nenhuma.');
      _go(5);
      return;
    }
    _submitAccount('cadastro', {
      'nome': name.text.trim(),
      'email': email.text.trim(),
      'senha': password.text,
      'idade': years,
      'altura': centimeters,
      'peso': kilograms,
      'nivel': level,
      'objetivo': goal,
      'condicoes_saude': health.toList(),
    });
  }

  // Valida os dados de acesso antes de navegar ou chamar a API.
  void _submitCredentials({required bool registering}) {
    if (registering && name.text.trim().isEmpty) {
      _showMessage('Informe seu nome.');
      return;
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.text.trim())) {
      _showMessage('Informe um e-mail válido.');
      return;
    }
    final minimum = registering ? 6 : 1;
    if (password.text.runes.length < minimum ||
        utf8.encode(password.text).length > 72) {
      _showMessage(
        'Confira a senha. No cadastro, use pelo menos 6 caracteres e até 72 bytes.',
      );
      return;
    }
    if (registering &&
        (password.text != confirmPassword.text || !acceptedTerms)) {
      _showMessage(
        password.text != confirmPassword.text
            ? 'As senhas precisam ser iguais.'
            : 'Aceite os termos para criar a conta.',
      );
      return;
    }
    if (registering) {
      _go(2);
    } else {
      _submitAccount('login', {
        'email': email.text.trim(),
        'senha': password.text,
      });
    }
  }

  // Mantém os dados do cadastro quando a pessoa avança ou volta entre etapas.
  Widget _onboardingScreen() => switch (page) {
        0 => LoginScreen(
            email: email,
            password: password,
            showPassword: showPassword,
            onTogglePassword: _togglePassword,
            submit: () => _submitCredentials(registering: false),
            onRegister: () => _go(1),
            onForgotPassword: () => _showMessage(
              'A recuperação de senha ainda não está disponível no acesso local.',
            ),
          ),
        1 => RegistrationScreen(
            email: email,
            password: password,
            showPassword: showPassword,
            onTogglePassword: _togglePassword,
            submit: () => _submitCredentials(registering: true),
            name: name,
            confirmPassword: confirmPassword,
            acceptedTerms: acceptedTerms,
            onTermsChanged: (value) =>
                setState(() => acceptedTerms = value ?? false),
            onBack: () => _go(0),
          ),
        2 => LevelScreen(
            level: level,
            onSelected: (value) => setState(() => level = value),
            onBack:
                editingLevel ? () => _finishEdit(cancel: true) : () => _go(1),
            onContinue: editingLevel ? _finishEdit : () => _go(3),
          ),
        3 => PersonalDataScreen(
            name: name,
            age: age,
            onBack: () => _go(2),
            onContinue: () => _go(4),
          ),
        4 => MeasurementsScreen(
            weight: weight,
            height: height,
            measurements: measurements,
            onBack: () => _go(3),
            onContinue: () => _go(5),
          ),
        5 => HealthScreen(
            health: health,
            onToggle: _toggleHealth,
            onBack: () => _go(4),
            onContinue: () => _go(7),
          ),
        _ => GoalScreen(
            goal: goal,
            editingGoal: editingGoal,
            onSelected: (value) => setState(() => goal = value),
            onBack:
                editingGoal ? () => _finishEdit(cancel: true) : () => _go(5),
            onContinue: editingGoal ? _finishEdit : _register,
          ),
      };

  // A opção Nenhuma é exclusiva e pode ser desmarcada como as demais.
  void _toggleHealth(String condition) => setState(() {
        if (health.remove(condition)) return;
        if (condition == 'Nenhuma') {
          health.clear();
        } else {
          health.remove('Nenhuma');
        }
        health.add(condition);
      });

  void _togglePassword() => setState(() => showPassword = !showPassword);

  // Escolhe a aba exibida pela barra de navegação.
  Widget _tabScreen() => switch (tab) {
        0 => HomeScreen(
            name: name.text,
            level: level,
            completed: completed,
            activityCount: done.length,
            onWorkout: (value) => setState(() {
              selected = value;
              page = 8;
            }),
          ),
        1 => ExerciseLibraryScreen(
            exercises: exercises,
            onExercise: (value) => setState(() {
              selected = value;
              page = 9;
            }),
          ),
        2 => ProgressScreen(completed: completed),
        _ => ProfileScreen(
            name: name.text,
            level: level,
            goal: goal,
            completed: completed,
            notifications: notifications,
            onEditGoal: () => editChoice(isLevel: false),
            onEditLevel: () => editChoice(isLevel: true),
            onNotifications: (value) => setState(() => notifications = value),
            onSignOut: signOut,
          ),
      };

  // As telas abertas a partir de uma aba compartilham a barra superior.
  Widget _trainingScreen() => switch (page) {
        8 => WorkoutScreen(
            selected: selected,
            level: level,
            exercises: exercises,
            done: done,
            onToggle: (exercise, checked) => setState(
                () => checked ? done.add(exercise) : done.remove(exercise)),
            onStart: () => setState(() {
              seconds = 40;
              page = 11;
            }),
          ),
        9 => ExerciseDetailScreen(
            selected: selected,
            onAdd: () => setState(() {
              done.add(selected);
              page = 8;
            }),
          ),
        10 => WorkoutCompleteScreen(
            onHome: () => setState(() {
              page = 6;
              tab = 0;
            }),
          ),
        11 => WorkoutTimerScreen(
            selected: selected,
            seconds: seconds,
            playing: playing,
            onToggle: playing ? pause : startTimer,
            onReset: () => setState(() => seconds = 40),
            onFinish: _finishWorkout,
          ),
        _ => _tabScreen(),
      };

  // Compartilha a conclusão entre o fim do cronômetro e o botão manual.
  void _finishWorkout() {
    timer?.cancel();
    setState(() {
      playing = false;
      completed++;
      page = 10;
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = page <= 5 || page == 7;
    if (onboarding) {
      // Bloqueia o formulário enquanto o servidor processa a solicitação.
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            AbsorbPointer(
                absorbing: sendingAccount, child: _onboardingScreen()),
            if (sendingAccount)
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
    final body = _trainingScreen();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FitHome',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: purple,
        leading: page == 8 || page == 9 || page == 11
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  pause();
                  setState(() => page = page == 9 ? 6 : 8);
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20), child: body),
      ),
      bottomNavigationBar: (page == 6)
          ? NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (v) => setState(() => tab = v),
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
