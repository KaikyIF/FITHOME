import 'package:flutter/material.dart';
import '../componentes/componentes_avaliacao.dart';

/// Coleta as medidas e mostra o IMC durante a digitação.
class TelaMedidas extends StatelessWidget {
  const TelaMedidas(
      {super.key,
      required this.peso,
      required this.altura,
      required this.medidas,
      required this.aoVoltar,
      required this.aoContinuar});

  final TextEditingController peso;
  final TextEditingController altura;
  final Listenable medidas;
  final VoidCallback aoVoltar;
  final VoidCallback aoContinuar;

  @override
  Widget build(BuildContext contexto) => estruturaAvaliacao(
        titulo: 'Medidas Corporais',
        subtitulo: 'Para calcular seu IMC e personalizar treinos',
        etapa: 2,
        icon: Icons.monitor_heart_outlined,
        color: const Color(0xFF2563EB),
        voltar: aoVoltar,
        aoContinuar: aoContinuar,
        rotulo: 'Continuar',
        children: [
          campoAvaliacao('Peso (kg)', peso,
              sugestao: 'Ex.: 52',
              teclado: const TextInputType.numberWithOptions(decimal: true)),
          campoAvaliacao('Altura (cm)', altura,
              sugestao: 'Ex.: 172',
              teclado: const TextInputType.numberWithOptions(decimal: true)),
          // Reconstrói o resultado quando o usuário edita peso ou altura.
          ListenableBuilder(
            listenable: medidas,
            builder: (contexto, _) {
              final quilogramas = interpretarNumeroPositivo(peso.text);
              final centimetros = interpretarNumeroPositivo(altura.text);
              // O IMC usa a altura em metros. O cartão reage aos dois campos.
              final metros = (centimetros ?? 0) / 100;
              final imc = quilogramas != null && metros > 0
                  ? quilogramas / (metros * metros)
                  : null;
              // Formata com vírgula e uma casa decimal. O traço indica um cálculo indisponível.
              final valor = imc != null && imc.isFinite && imc > 0
                  ? imc.toStringAsFixed(1).replaceAll('.', ',')
                  : '—';
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F2FC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Semantics(
                  // Permite que leitores de tela anunciem a mudança do resultado.
                  liveRegion: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seu IMC será',
                        style: TextStyle(
                          color: Color(0xFF7127A2),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        valor,
                        style: const TextStyle(
                          color: Color(0xFF8510D5),
                          fontSize: 27,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
}
