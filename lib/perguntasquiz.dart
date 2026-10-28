import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Perguntasquiz extends StatefulWidget {
  const Perguntasquiz({super.key});

  @override
  State<Perguntasquiz> createState() => _PerguntasquizState();
}

class _PerguntasquizState extends State<Perguntasquiz> {
  int perguntaAtual = 0;
  bool? respostaVerdadeiroFalso;
  bool respostaMostrada = false;
  int pontos = 0;
  final Set<String> selecionadas = {};
  final Map<String, String> associacoes = {};
  String? conceitoSelecionado;

  static const opcoes = ['a) if', 'b) else', 'c) for', 'd) break'];
  static const respostaCorreta = 'c) for';
  static const conceitos = ['Entidade', 'Atributo', 'Cardinalidade'];
  static const alvos = ['Campo atribuído', '1 para N', 'Tabela'];
  static const associacoesCorretas = {
    'Campo atribuído': 'Atributo',
    '1 para N': 'Cardinalidade',
    'Tabela': 'Entidade',
  };

  bool get respostaEstaCorreta {
    if (perguntaAtual == 0) {
      return selecionadas.length == 1 && selecionadas.contains(respostaCorreta);
    }
    if (perguntaAtual == 1) {
      return respostaVerdadeiroFalso == false;
    }
    return associacoes.length == associacoesCorretas.length &&
        associacoes.entries.every(
          (entry) => associacoesCorretas[entry.key] == entry.value,
        );
  }

  void _mostrarResposta() {
    setState(() {
      if (!respostaMostrada) {
        respostaMostrada = true;
        if (respostaEstaCorreta) {
          pontos += 10;
        }
      } else if (perguntaAtual < 2) {
        perguntaAtual++;
        selecionadas.clear();
        respostaVerdadeiroFalso = null;
        associacoes.clear();
        conceitoSelecionado = null;
        respostaMostrada = false;
      }
    });
  }

  void _selecionarAlvo(String alvo) {
    if (respostaMostrada || conceitoSelecionado == null) return;

    setState(() {
      associacoes.removeWhere((_, conceito) => conceito == conceitoSelecionado);
      associacoes[alvo] = conceitoSelecionado!;
      conceitoSelecionado = null;
    });
  }

  Future<void> _encerrarQuiz() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quiz encerrado'),
        content: Text('Sua pontuação: $pontos pontos'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildPerguntaRelacione() {
    final orientacao = MediaQuery.orientationOf(context);
    if (orientacao != Orientation.landscape) {
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
              'Relacione os conceitos de Banco de Dados Relacional',
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
                for (final conceito in conceitos)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: OutlinedButton(
                        onPressed: respostaMostrada
                            ? null
                            : () => setState(
                                () => conceitoSelecionado = conceito,
                              ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: conceitoSelecionado == conceito
                              ? Colors.white
                              : const Color(0xFF3C00A7),
                          backgroundColor: conceitoSelecionado == conceito
                              ? const Color(0xFF3C00A7)
                              : Colors.white,
                          side: const BorderSide(color: Color(0xFF3C00A7)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          conceito,
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
                for (final alvo in alvos)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: OutlinedButton(
                        onPressed: () => _selecionarAlvo(alvo),
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
                              alvo,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(fontSize: 14),
                            ),
                            if (associacoes[alvo] != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                associacoes[alvo]!,
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
                respostaEstaCorreta
                    ? 'Você acertou! +10 pontos'
                    : 'Você errou. Confira as associações e tente novamente na próxima rodada.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: respostaEstaCorreta
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

  Widget _buildPerguntasObjetivas() {
    final correta = respostaEstaCorreta;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              perguntaAtual == 0
                  ? 'Qual dos comandos abaixo é uma estrutura de repetição?'
                  : 'O SGBD MYSQL é um Sistema Gerenciador de Bancos de Dados Não Relacional',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: const Color(0xFF3C00A7),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (perguntaAtual == 0)
              for (final opcao in opcoes)
                TextButton(
                  onPressed: () {
                    if (respostaMostrada) return;
                    setState(() {
                      if (!selecionadas.add(opcao)) {
                        selecionadas.remove(opcao);
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor:
                        selecionadas.contains(opcao) ||
                            (respostaMostrada && opcao == respostaCorreta)
                        ? const Color(0xFF3C00A7)
                        : Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    opcao,
                    style: GoogleFonts.montserrat(fontSize: 18),
                  ),
                )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTrueFalseButton('Verdadeiro', true),
                  const SizedBox(width: 24),
                  _buildTrueFalseButton('Falso', false),
                ],
              ),
            if (respostaMostrada) ...[
              const SizedBox(height: 8),
              Text(
                correta
                    ? 'Você acertou! +10 pontos'
                    : perguntaAtual == 0
                    ? 'Você errou. A resposta correta é $respostaCorreta.'
                    : 'Você errou. A resposta correta é Falso.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  color: correta ? const Color(0xFF3C00A7) : Colors.black,
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

  Widget _buildTrueFalseButton(String label, bool value) {
    final selecionado = respostaVerdadeiroFalso == value;
    final correta = value == false;
    return TextButton(
      onPressed: () {
        if (respostaMostrada) return;
        setState(() => respostaVerdadeiroFalso = value);
      },
      style: TextButton.styleFrom(
        foregroundColor: respostaMostrada && correta || selecionado
            ? const Color(0xFF3C00A7)
            : Colors.black,
      ),
      child: Text(label, style: GoogleFonts.montserrat()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emPaisagem =
        MediaQuery.orientationOf(context) == Orientation.landscape;
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
                  child: perguntaAtual == 2
                      ? _buildPerguntaRelacione()
                      : _buildPerguntasObjetivas(),
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
                        onPressed: _encerrarQuiz,
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
                        onPressed:
                            (perguntaAtual == 2 && !emPaisagem) ||
                                (perguntaAtual == 2 && respostaMostrada)
                            ? null
                            : _mostrarResposta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C00A7),
                          foregroundColor: Colors.white,
                          shape: const OvalBorder(),
                          minimumSize: const Size.fromHeight(48),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          respostaMostrada && perguntaAtual < 2
                              ? 'Próxima\npergunta'
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
