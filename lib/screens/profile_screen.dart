import 'package:flutter/material.dart';
import '../widgets/training_widgets.dart';

/// Mostra os dados e as preferências da sessão.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen(
      {super.key,
      required this.name,
      required this.level,
      required this.goal,
      required this.completed,
      required this.notifications,
      required this.onEditGoal,
      required this.onEditLevel,
      required this.onNotifications,
      required this.onSignOut});

  final String name;
  final String level;
  final String goal;
  final int completed;
  final bool notifications;
  final VoidCallback onEditGoal;
  final VoidCallback onEditLevel;
  final ValueChanged<bool> onNotifications;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          heading('Meu Perfil', 'Suas informações e preferências.'),
          const CircleAvatar(
            radius: 40,
            backgroundColor: purple,
            child: Icon(Icons.person, size: 45, color: Colors.white),
          ),
          Center(
            child: Text(
              name,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          option(
            'Objetivo',
            goal,
            false,
            onEditGoal,
            Icons.flag,
          ),
          option(
            'Nível',
            level,
            false,
            onEditLevel,
            Icons.trending_up,
          ),
          option(
            'Treinos concluídos',
            '$completed',
            false,
            () {},
            Icons.emoji_events,
          ),
          SwitchListTile(
            title: const Text('Notificações'),
            value: notifications,
            onChanged: onNotifications,
          ),
          action('Sair', onSignOut),
        ],
      );
}
