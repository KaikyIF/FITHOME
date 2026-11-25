import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import '../componentes/componentes_treino.dart';

import '../dados/exercicios.dart';

/// Lista os exercícios disponíveis com busca por nome e filtros por categoria.
class TelaBibliotecaExercicios extends StatefulWidget {
  const TelaBibliotecaExercicios({
    super.key,
    required this.exercicios,
    required this.aoAbrirExercicio,
    this.aoVoltar,
  });

  final List<String> exercicios;
  final ValueChanged<String> aoAbrirExercicio;
  final VoidCallback? aoVoltar;

  @override
  State<TelaBibliotecaExercicios> createState() =>
      _TelaBibliotecaExerciciosState();
}

class _TelaBibliotecaExerciciosState extends State<TelaBibliotecaExercicios> {
  static const _titulo = 'Biblioteca de Exercícios';
  static const _margem = EdgeInsets.symmetric(horizontal: 20);

  final _busca = TextEditingController();
  CategoriaExercicio _categoria = CategoriaExercicio.todos;

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  static String _normalizar(String texto) {
    const acentos = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const letras = 'aaaaaeeeeiiiiooooouuuuc';
    final minusculo = texto.toLowerCase().trim();
    return minusculo.replaceAllMapped(
      RegExp('[$acentos]'),
      (match) => letras[acentos.indexOf(match[0]!)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final consulta = _normalizar(_busca.text);
    final resultados = widget.exercicios.where((nome) {
      final correspondeCategoria = _categoria == CategoriaExercicio.todos ||
          (fichasExercicios[nome]?.categorias.contains(_categoria) ?? false);
      return correspondeCategoria && _normalizar(nome).contains(consulta);
    }).toList();
    final total = resultados.length;

    return ColoredBox(
      color: const Color(0xFFF6F7F8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [roxo, Color(0xFFED238F)],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: widget.aoVoltar == null
                                  ? null
                                  : IconButton(
                                      onPressed: widget.aoVoltar,
                                      tooltip: 'Voltar para o início',
                                      style: IconButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.white24,
                                      ),
                                      icon: const Icon(Icons.arrow_back),
                                    ),
                            ),
                            Expanded(
                              child: Semantics(
                                header: true,
                                child: Text(
                                  _titulo,
                                  textAlign: TextAlign.center,
                                  style: tema.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextField(
                            controller: _busca,
                            onChanged: (_) => setState(() {}),
                            textInputAction: TextInputAction.search,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              hintText: 'Buscar exercício...',
                              hintStyle: const TextStyle(color: Colors.white),
                              prefixIcon: const Icon(Icons.search),
                              prefixIconColor: Colors.white,
                              suffixIcon: _busca.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Limpar busca',
                                      color: Colors.white,
                                      icon: const Icon(Icons.close),
                                      onPressed: () => setState(_busca.clear),
                                    ),
                              filled: true,
                              fillColor: Colors.white24,
                              isDense: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.white54),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        ...ScrollConfiguration.of(context).dragDevices,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: _margem,
                      child: Row(
                        children: [
                          for (final categoria in CategoriaExercicio.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(categoria.rotulo),
                                avatar: Icon(
                                  categoria.icone,
                                  size: 16,
                                  color: _categoria == categoria
                                      ? Colors.white
                                      : const Color(0xFF38445A),
                                ),
                                selected: _categoria == categoria,
                                showCheckmark: false,
                                backgroundColor: Colors.white,
                                selectedColor: roxo,
                                labelStyle: TextStyle(
                                  color: _categoria == categoria
                                      ? Colors.white
                                      : const Color(0xFF38445A),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                onSelected: (_) {
                                  setState(() => _categoria = categoria);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: _margem.add(const EdgeInsets.only(bottom: 10)),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      total == 1
                          ? '1 exercício encontrado'
                          : '$total exercícios encontrados',
                      style: const TextStyle(color: Color(0xFF46536A)),
                    ),
                  ),
                ),
              ),
              if (resultados.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Tente outra busca ou selecione outra categoria.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              SliverPadding(
                padding: _margem.add(const EdgeInsets.only(bottom: 12)),
                sliver: SliverList.builder(
                  itemCount: total,
                  itemBuilder: (context, index) {
                    final nome = resultados[index];
                    return _CartaoExercicio(
                      nome: nome,
                      ficha: fichasExercicios[nome],
                      aoTocar: () => widget.aoAbrirExercicio(nome),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartaoExercicio extends StatelessWidget {
  const _CartaoExercicio({
    required this.nome,
    required this.ficha,
    required this.aoTocar,
  });

  final String nome;
  final FichaExercicio? ficha;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final dados = ficha;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(
                      nome,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (dados != null)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1E4FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            dados.nivel,
                            style: const TextStyle(
                              color: Color(0xFF6913AE),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (dados != null) ...[
                const SizedBox(height: 6),
                Text(
                  dados.descricao,
                  style: const TextStyle(color: Color(0xFF46536A)),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.track_changes, size: 14, color: roxo),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dados.musculos,
                        style: const TextStyle(
                          color: Color(0xFF59657A),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
