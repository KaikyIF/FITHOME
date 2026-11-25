import 'package:flutter/material.dart';

import '../componentes/componentes_treino.dart';

/// Mostra o resumo e os treinos disponíveis.
class TelaInicio extends StatelessWidget {
  const TelaInicio({
    super.key,
    required this.nome,
    required this.nivel,
    required this.concluidos,
    required this.totalAtividades,
    required this.aoAbrirTreino,
  });

  final String nome;
  final String nivel;
  final int concluidos;
  final int totalAtividades;
  final ValueChanged<String> aoAbrirTreino;

  static const _gradiente = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [roxo, Color(0xFFEC238E)],
  );

  static const _categorias = [
    (
      titulo: 'Cardio',
      treino: 'Cardio',
      imagem: 'cardio',
      icone: Icons.local_fire_department_outlined,
      cor: Color(0xFFE55D1C),
    ),
    (
      titulo: 'Força',
      treino: 'Força em Casa',
      imagem: 'forca',
      icone: Icons.fitness_center,
      cor: Color(0xFF007DA6),
    ),
    (
      titulo: 'Yoga',
      treino: 'Flexibilidade',
      imagem: 'yoga',
      icone: Icons.favorite_border,
      cor: Color(0xFFD83879),
    ),
    (
      titulo: 'HIIT',
      treino: 'HIIT',
      imagem: 'hiit',
      icone: Icons.bolt,
      cor: Color(0xFF8647D9),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final saudacao = nome.trim().isEmpty ? 'Atleta' : nome.trim();
    final estiloSecao = tema.textTheme.titleMedium;

    return ListView(
      key: const PageStorageKey('inicio'),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _gradiente,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Olá, $saudacao! 👋',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pronto para treinar?',
                                    style: tema.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const CircleAvatar(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                              child: Icon(Icons.monitor_heart_outlined),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: _Indicador(
                                icone: Icons.local_fire_department_outlined,
                                rotulo: 'kcal',
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: _Indicador(
                                icone: Icons.timer_outlined,
                                rotulo: 'minutos',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _Indicador(
                                icone: Icons.trending_up,
                                rotulo: 'treinos',
                                valor: '$concluidos',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$nivel • $totalAtividades atividades',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Categorias', style: estiloSecao),
                const SizedBox(height: 10),
                GridView.count(
                  primary: false,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    for (final categoria in _categorias)
                      _CartaoCategoria(
                        titulo: categoria.titulo,
                        imagem: categoria.imagem,
                        icone: categoria.icone,
                        cor: categoria.cor,
                        aoTocar: () => aoAbrirTreino(categoria.treino),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Treino Rápido', style: estiloSecao),
                const SizedBox(height: 10),
                Material(
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: Ink(
                    decoration: const BoxDecoration(gradient: _gradiente),
                    child: ListTile(
                      textColor: Colors.white,
                      iconColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      title: const Text('HIIT'),
                      subtitle: const Text('Treino intervalado'),
                      trailing: const CircleAvatar(
                        backgroundColor: Colors.white24,
                        foregroundColor: Colors.white,
                        child: Icon(Icons.play_arrow_rounded),
                      ),
                      onTap: () => aoAbrirTreino('HIIT'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({required this.icone, required this.rotulo, this.valor});

  final IconData icone;
  final String rotulo;
  final String? valor;

  @override
  Widget build(BuildContext context) {
    final conteudo = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icone, size: 19, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            valor ?? '—',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 19),
          ),
          Text(
            rotulo,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );

    return Semantics(
      label: valor == null ? '$rotulo indisponíveis' : '$valor $rotulo',
      excludeSemantics: true,
      child: valor == null
          ? Tooltip(
              message: 'Dados indisponíveis',
              excludeFromSemantics: true,
              child: conteudo,
            )
          : conteudo,
    );
  }
}

class _CartaoCategoria extends StatelessWidget {
  const _CartaoCategoria({
    required this.titulo,
    required this.imagem,
    required this.icone,
    required this.cor,
    required this.aoTocar,
  });

  final String titulo;
  final String imagem;
  final IconData icone;
  final Color cor;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      color: const Color(0xFF272332),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Ink.image(
            image: AssetImage('assets/categorias/$imagem.jpg'),
            fit: BoxFit.cover,
          ),
          Ink(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
                stops: [0.25, 1],
              ),
            ),
          ),
          InkWell(
            onTap: aoTocar,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: cor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Icon(icone, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
