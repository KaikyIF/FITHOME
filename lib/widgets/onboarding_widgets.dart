import 'package:flutter/material.dart';

// Paleta do fluxo de cadastro.
const onboardingAccent = Color(0xFF980DFA);
const _ink = Color(0xFF1F2937);
const _muted = Color(0xFF4B5563);
const _line = Color(0xFFE3E5E8);

/// Converte números positivos digitados com vírgula ou ponto.
double? parsePositiveNumber(String text) {
  final value = double.tryParse(text.trim().replaceAll(',', '.'));
  return value != null && value.isFinite && value > 0 ? value : null;
}

/// Organiza as etapas e mantém o conteúdo rolável quando o teclado aparece.
Widget onboardingLayout({
  required String title,
  required String subtitle,
  required String label,
  required VoidCallback onContinue,
  required List<Widget> children,
  VoidCallback? back,
  int? step,
  IconData? icon,
  Color color = onboardingAccent,
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
        builder: (context, constraints) {
          return SingleChildScrollView(
            // Arrastar o formulário recolhe o teclado e facilita o acesso ao botão inferior.
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(22, back == null ? 46 : 14, 22, 22),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - (back == null ? 68 : 36))
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
                      if (back != null) backButton(back),
                      if (step != null) ...[
                        Row(
                          children: [
                            for (var index = 1; index <= 3; index++)
                              Expanded(
                                child: Container(
                                  height: 4,
                                  margin: EdgeInsets.only(
                                    right: index < 3 ? 8 : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: index <= step
                                        ? onboardingAccent
                                        : _line,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 28),
                      ],
                      if (icon != null) ...[
                        onboardingBadge(icon, color, tinted: true),
                        const SizedBox(height: 18),
                      ],
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          height: 1.16,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 14, color: _muted),
                      ),
                      const SizedBox(height: 30),
                      ...children,
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: onboardingButton(label, onContinue),
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
Widget onboardingInput(
  String label,
  TextEditingController controller, {
  required String hint,
  IconData? icon,
  bool light = false,
  bool obscure = false,
  VoidCallback? toggle,
  TextInputType? keyboard,
  TextCapitalization capitalization = TextCapitalization.none,
}) {
  final foreground = light ? Colors.white : _ink;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: light ? Colors.white30 : _line),
  );
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: light ? Colors.white : _muted,
          ),
        ),
        const SizedBox(height: 7),
        Semantics(
          label: label,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboard,
            textCapitalization: capitalization,
            style: TextStyle(color: foreground, fontSize: 14),
            cursorColor: foreground,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: light ? Colors.white70 : _muted,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              filled: true,
              fillColor: light
                  ? Colors.white.withAlpha(46)
                  : Colors.white.withAlpha(128),
              prefixIcon: icon == null
                  ? null
                  : Icon(icon, size: 19, color: Colors.white70),
              suffixIcon: toggle == null
                  ? null
                  : IconButton(
                      onPressed: toggle,
                      tooltip: obscure ? 'Mostrar senha' : 'Ocultar senha',
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 19,
                        color: Colors.white70,
                      ),
                    ),
              border: border,
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: BorderSide(
                  color: light ? Colors.white : onboardingAccent,
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
Widget backButton(VoidCallback onTap, {bool white = false}) => IconButton(
      tooltip: 'Voltar',
      alignment: white ? Alignment.center : Alignment.centerLeft,
      onPressed: onTap,
      color: white ? Colors.white : _muted,
      style:
          white ? IconButton.styleFrom(backgroundColor: Colors.white24) : null,
      icon: const Icon(Icons.arrow_back, size: 21),
    );

/// Cria a ação principal da etapa.
Widget onboardingButton(String label, VoidCallback onTap,
        {bool white = false}) =>
    FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: white ? Colors.white : onboardingAccent,
        foregroundColor: white ? const Color(0xFF7316B5) : Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(label),
    );

/// Exibe o ícone de uma etapa ou opção.
Widget onboardingBadge(IconData icon, Color color, {bool tinted = false}) =>
    Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: tinted ? color.withAlpha(27) : color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: tinted ? color : Colors.white, size: 28),
    );

/// Apresenta os textos de um cartão.
Widget onboardingCaption(String title, String subtitle,
        {bool centered = false}) =>
    Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: _ink,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: const TextStyle(color: _muted, fontSize: 12),
        ),
      ],
    );

/// Destaca visual e semanticamente a seleção.
Widget onboardingChoice({
  required bool selected,
  required VoidCallback onTap,
  required Widget child,
}) {
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: BorderSide(color: selected ? onboardingAccent : _line),
  );
  return Semantics(
    selected: selected,
    child: Material(
      color: selected ? const Color(0xFFF8EEFF) : Colors.white,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(15), child: child),
      ),
    ),
  );
}
