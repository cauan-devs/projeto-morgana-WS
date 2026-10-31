import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ws_morgana/modelos/questao_quiz.dart';
import 'package:ws_morgana/widgets/pergunta_objetiva.dart';
import 'package:ws_morgana/widgets/pergunta_relacione.dart';

class TelaQuiz extends StatelessWidget {
  const TelaQuiz({
    required this.questao,
    required this.ultimaQuestao,
    required this.respostaMostrada,
    required this.respostaCorreta,
    required this.alternativaSelecionada,
    required this.associacoes,
    required this.conceitoSelecionado,
    required this.pontos,
    required this.onSelecionarAlternativa,
    required this.onSelecionarConceito,
    required this.onSelecionarAssociacao,
    required this.onMostrarResposta,
    required this.onEncerrar,
    super.key,
  });

  final QuestaoQuiz questao;
  final bool ultimaQuestao;
  final bool respostaMostrada;
  final bool respostaCorreta;
  final int? alternativaSelecionada;
  final Map<int, int> associacoes;
  final int? conceitoSelecionado;
  final int pontos;
  final ValueChanged<int> onSelecionarAlternativa;
  final ValueChanged<int> onSelecionarConceito;
  final ValueChanged<int> onSelecionarAssociacao;
  final VoidCallback onMostrarResposta;
  final VoidCallback onEncerrar;

  @override
  Widget build(BuildContext context) {
    final emPaisagem =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final ehRelacione = questao.tipo == 'REL';
    final tema = Theme.of(context);

    return Theme(
      data: tema.copyWith(
        textTheme: GoogleFonts.montserratTextTheme(tema.textTheme),
        primaryTextTheme: GoogleFonts.montserratTextTheme(
          tema.primaryTextTheme,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'QuizMyBrain',
            style: GoogleFonts.montserrat(
              color: const Color(0xFF3C00A7),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ehRelacione
                      ? PerguntaRelacione(
                          questao: questao,
                          associacoes: associacoes,
                          conceitoSelecionado: conceitoSelecionado,
                          respostaMostrada: respostaMostrada,
                          respostaCorreta: respostaCorreta,
                          pontos: pontos,
                          onSelecionarConceito: onSelecionarConceito,
                          onSelecionarAssociacao: onSelecionarAssociacao,
                        )
                      : PerguntaObjetiva(
                          questao: questao,
                          alternativaSelecionada: alternativaSelecionada,
                          respostaMostrada: respostaMostrada,
                          respostaCorreta: respostaCorreta,
                          pontos: pontos,
                          onSelecionar: onSelecionarAlternativa,
                        ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onEncerrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C00A7),
                          foregroundColor: Colors.white,
                          shape: const OvalBorder(),
                          minimumSize: const Size.fromHeight(48),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          'Encerrar',
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (ehRelacione && !emPaisagem)
                            ? null
                            : respostaMostrada && ultimaQuestao
                            ? onEncerrar
                            : onMostrarResposta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C00A7),
                          foregroundColor: Colors.white,
                          shape: const OvalBorder(),
                          minimumSize: const Size.fromHeight(48),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          respostaMostrada
                              ? ultimaQuestao
                                    ? 'Concluir'
                                    : 'Próxima\npergunta'
                              : 'Próximo',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
