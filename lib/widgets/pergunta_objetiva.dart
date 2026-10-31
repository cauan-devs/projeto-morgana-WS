import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ws_morgana/modelos/questao_quiz.dart';

class PerguntaObjetiva extends StatelessWidget {
  const PerguntaObjetiva({
    required this.questao,
    required this.alternativaSelecionada,
    required this.respostaMostrada,
    required this.respostaCorreta,
    required this.pontos,
    required this.onSelecionar,
    super.key,
  });

  final QuestaoQuiz questao;
  final int? alternativaSelecionada;
  final bool respostaMostrada;
  final bool respostaCorreta;
  final int pontos;
  final ValueChanged<int> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questao.enunciado,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: const Color(0xFF3C00A7),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            for (var index = 0; index < questao.alternativas.length; index++)
              TextButton(
                onPressed: respostaMostrada ? null : () => onSelecionar(index),
                style: TextButton.styleFrom(
                  foregroundColor:
                      alternativaSelecionada == index ||
                          (respostaMostrada && questao.resposta == index)
                      ? const Color(0xFF3C00A7)
                      : Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  alignment: Alignment.centerLeft,
                ),
                child: Text(
                  questao.alternativas[index],
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (respostaMostrada) ...[
              const SizedBox(height: 8),
              Text(
                respostaCorreta
                    ? 'Você acertou! +${questao.peso} pontos'
                    : 'Você errou. A resposta correta é '
                          '${questao.alternativas[questao.resposta!]}.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: respostaCorreta
                      ? const Color(0xFF3C00A7)
                      : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pontuação: $pontos pontos',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
