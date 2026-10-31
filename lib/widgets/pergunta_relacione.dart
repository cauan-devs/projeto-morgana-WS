import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ws_morgana/modelos/questao_quiz.dart';

class PerguntaRelacione extends StatelessWidget {
  const PerguntaRelacione({
    required this.questao,
    required this.associacoes,
    required this.conceitoSelecionado,
    required this.respostaMostrada,
    required this.respostaCorreta,
    required this.pontos,
    required this.onSelecionarConceito,
    required this.onSelecionarAssociacao,
    super.key,
  });

  final QuestaoQuiz questao;
  final Map<int, int> associacoes;
  final int? conceitoSelecionado;
  final bool respostaMostrada;
  final bool respostaCorreta;
  final int pontos;
  final ValueChanged<int> onSelecionarConceito;
  final ValueChanged<int> onSelecionarAssociacao;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.orientationOf(context) != Orientation.landscape) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.screen_rotation,
                color: Color(0xFF3C00A7),
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                'Deite o celular para continuar',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF3C00A7),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              questao.enunciado,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: const Color(0xFF3C00A7),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (
                  var index = 0;
                  index < questao.itensRelacao.length;
                  index++
                )
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: OutlinedButton(
                        onPressed: respostaMostrada
                            ? null
                            : () => onSelecionarConceito(index),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: conceitoSelecionado == index
                              ? Colors.white
                              : const Color(0xFF3C00A7),
                          backgroundColor: conceitoSelecionado == index
                              ? const Color(0xFF3C00A7)
                              : Colors.white,
                          side: const BorderSide(color: Color(0xFF3C00A7)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          questao.itensRelacao[index],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(fontSize: 15),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (
                  var index = 0;
                  index < questao.conceitosRelacao.length;
                  index++
                )
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: OutlinedButton(
                        onPressed: () => onSelecionarAssociacao(index),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFF3C00A7),
                            width: 1,
                          ),
                          minimumSize: const Size.fromHeight(58),
                          padding: const EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              questao.conceitosRelacao[index],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(fontSize: 14),
                            ),
                            if (associacoes.entries.any(
                              (entry) => entry.value == index,
                            )) ...[
                              const SizedBox(height: 6),
                              Text(
                                questao.itensRelacao[associacoes.entries
                                    .firstWhere((entry) => entry.value == index)
                                    .key],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  color: const Color(0xFF3C00A7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (respostaMostrada) ...[
              const SizedBox(height: 8),
              Text(
                respostaCorreta
                    ? 'Você acertou! +${questao.peso} pontos'
                    : 'Você errou. Confira as associações corretas.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: respostaCorreta
                      ? const Color(0xFF3C00A7)
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Pontuação: $pontos pontos',
                style: GoogleFonts.montserrat(),
              ),
            ] else if (conceitoSelecionado != null) ...[
              const SizedBox(height: 6),
              Text(
                'Agora toque no quadrado correspondente.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(color: const Color(0xFF3C00A7)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
