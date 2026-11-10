import 'package:flutter/material.dart';

// Paleta do fluxo de cadastro.
const corDestaque = Color(0xFF980DFA);
const _corTexto = Color(0xFF1F2937);
const _corSecundaria = Color(0xFF4B5563);
const _corBorda = Color(0xFFE3E5E8);

/// Converte números positivos digitados com vírgula ou ponto.
double? interpretarNumeroPositivo(String texto) {
  final valor = double.tryParse(texto.trim().replaceAll(',', '.'));
  return valor != null && valor.isFinite && valor > 0 ? valor : null;
}

/// Organiza as etapas e mantém o conteúdo rolável quando o teclado aparece.
Widget estruturaAvaliacao({
  required String titulo,
  required String subtitulo,
  required String rotulo,
  required VoidCallback aoContinuar,
  required List<Widget> children,
  VoidCallback? voltar,
  int? etapa,
  IconData? icon,
  Color color = corDestaque,
}) {
  return DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF6F7F9), Colors.white],
      ),
    ),
    child: SafeArea(
      child: LayoutBuilder(
        builder: (contexto, restricoes) {
          return SingleChildScrollView(
            // Arrastar o formulário recolhe o teclado e facilita o acesso ao botão inferior.
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(22, voltar == null ? 46 : 14, 22, 22),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (restricoes.maxHeight - (voltar == null ? 68 : 36))
                    .clamp(0.0, double.infinity)
                    .toDouble(),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (voltar != null) botaoVoltar(voltar),
                      if (etapa != null) ...[
                        Row(
                          children: [
                            for (var indice = 1; indice <= 3; indice++)
                              Expanded(
                                child: Container(
                                  height: 4,
                                  margin: EdgeInsets.only(
                                    right: indice < 3 ? 8 : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: indice <= etapa
                                        ? corDestaque
                                        : _corBorda,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 28),
                      ],
                      if (icon != null) ...[
                        iconeAvaliacao(icon, color, suave: true),
                        const SizedBox(height: 18),
                      ],
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 28,
                          height: 1.16,
                          color: _corTexto,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                            fontSize: 14, color: _corSecundaria),
                      ),
                      const SizedBox(height: 30),
                      ...children,
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: botaoAvaliacao(rotulo, aoContinuar),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

/// Estiliza os campos dos formulários.
Widget campoAvaliacao(
  String rotulo,
  TextEditingController controlador, {
  required String sugestao,
  IconData? icon,
  bool claro = false,
  bool ocultar = false,
  VoidCallback? alternar,
  TextInputType? teclado,
  TextCapitalization capitalizacao = TextCapitalization.none,
}) {
  final corPrimeiroPlano = claro ? Colors.white : _corTexto;
  final borda = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: claro ? Colors.white30 : _corBorda),
  );
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: TextStyle(
            fontSize: 14,
            color: claro ? Colors.white : _corSecundaria,
          ),
        ),
        const SizedBox(height: 7),
        Semantics(
          label: rotulo,
          child: TextField(
            controller: controlador,
            obscureText: ocultar,
            keyboardType: teclado,
            textCapitalization: capitalizacao,
            style: TextStyle(color: corPrimeiroPlano, fontSize: 14),
            cursorColor: corPrimeiroPlano,
            decoration: InputDecoration(
              hintText: sugestao,
              hintStyle: TextStyle(
                color: claro ? Colors.white70 : _corSecundaria,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              filled: true,
              fillColor: claro
                  ? Colors.white.withAlpha(46)
                  : Colors.white.withAlpha(128),
              prefixIcon: icon == null
                  ? null
                  : Icon(icon, size: 19, color: Colors.white70),
              suffixIcon: alternar == null
                  ? null
                  : IconButton(
                      onPressed: alternar,
                      tooltip: ocultar ? 'Mostrar senha' : 'Ocultar senha',
                      icon: Icon(
                        ocultar
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 19,
                        color: Colors.white70,
                      ),
                    ),
              border: borda,
              enabledBorder: borda,
              focusedBorder: borda.copyWith(
                borderSide: BorderSide(
                  color: claro ? Colors.white : corDestaque,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Cria a seta de retorno.
Widget botaoVoltar(VoidCallback aoTocar, {bool branco = false}) => IconButton(
      tooltip: 'Voltar',
      alignment: branco ? Alignment.center : Alignment.centerLeft,
      onPressed: aoTocar,
      color: branco ? Colors.white : _corSecundaria,
      style:
          branco ? IconButton.styleFrom(backgroundColor: Colors.white24) : null,
      icon: const Icon(Icons.arrow_back, size: 21),
    );

/// Cria a ação principal da etapa.
Widget botaoAvaliacao(String rotulo, VoidCallback aoTocar,
        {bool branco = false}) =>
    FilledButton(
      onPressed: aoTocar,
      style: FilledButton.styleFrom(
        backgroundColor: branco ? Colors.white : corDestaque,
        foregroundColor: branco ? const Color(0xFF7316B5) : Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(rotulo),
    );

/// Exibe o ícone de uma etapa ou opção.
Widget iconeAvaliacao(IconData icon, Color color, {bool suave = false}) =>
    Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: suave ? color.withAlpha(27) : color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: suave ? color : Colors.white, size: 28),
    );

/// Apresenta os textos de um cartão.
Widget legendaAvaliacao(String titulo, String subtitulo,
        {bool centralizado = false}) =>
    Column(
      crossAxisAlignment:
          centralizado ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          titulo,
          textAlign: centralizado ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: _corTexto,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitulo,
          textAlign: centralizado ? TextAlign.center : TextAlign.start,
          style: const TextStyle(color: _corSecundaria, fontSize: 12),
        ),
      ],
    );

/// Destaca visual e semanticamente a seleção.
Widget opcaoAvaliacao({
  required bool selecionado,
  required VoidCallback aoTocar,
  required Widget child,
}) {
  final forma = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: BorderSide(color: selecionado ? corDestaque : _corBorda),
  );
  return Semantics(
    selected: selecionado,
    child: Material(
      color: selecionado ? const Color(0xFFF8EEFF) : Colors.white,
      shape: forma,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(padding: const EdgeInsets.all(15), child: child),
      ),
    ),
  );
}
