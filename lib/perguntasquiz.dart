import 'package:flutter/material.dart';
import 'package:ws_morgana/data/questao_quiz_repository.dart';
import 'package:ws_morgana/modelos/questao_quiz.dart';
import 'package:ws_morgana/widgets/tela_quiz.dart';

class Perguntasquiz extends StatefulWidget {
  const Perguntasquiz({super.key});

  @override
  State<Perguntasquiz> createState() => _PerguntasquizState();
}

class _PerguntasquizState extends State<Perguntasquiz> {
  final QuestaoQuizRepository _repositorio = const QuestaoQuizRepository();
  List<QuestaoQuiz> _perguntas = const [];
  String? _erroCarregamento;
  int _perguntaAtual = 0;
  int? _alternativaSelecionada;
  bool _respostaMostrada = false;
  int _pontos = 0;
  final Map<int, int> _associacoes = {};
  int? _conceitoSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarPerguntas();
  }

  Future<void> _carregarPerguntas() async {
    try {
      final perguntas = await _repositorio.carregar();
      if (!mounted) return;
      setState(() => _perguntas = perguntas);
    } on FlutterError catch (error) {
      if (!mounted) return;
      setState(() {
        _erroCarregamento =
            'Não foi possível carregar Banco.JSON/bancoQuestoes.json: '
            '${error.message}';
      });
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() {
        _erroCarregamento = 'Erro no banco de questões: ${error.message}';
      });
    }
  }

  bool get _respostaEstaCorreta {
    final questao = _perguntas[_perguntaAtual];
    if (questao.tipo == 'REL') {
      return _associacoes.length == questao.itensRelacao.length &&
          questao.respostaRelacao.entries.every(
            (entry) => _associacoes[entry.key] == entry.value,
          );
    }
    return _alternativaSelecionada == questao.resposta;
  }

  void _mostrarResposta() {
    setState(() {
      if (!_respostaMostrada) {
        _respostaMostrada = true;
        if (_respostaEstaCorreta) {
          _pontos += _perguntas[_perguntaAtual].peso;
        }
      } else if (_perguntaAtual < _perguntas.length - 1) {
        _perguntaAtual++;
        _alternativaSelecionada = null;
        _associacoes.clear();
        _conceitoSelecionado = null;
        _respostaMostrada = false;
      }
    });
  }

  void _selecionarAssociacao(int alvo) {
    if (_respostaMostrada || _conceitoSelecionado == null) return;

    setState(() {
      _associacoes.removeWhere((_, conceito) => conceito == alvo);
      _associacoes[_conceitoSelecionado!] = alvo;
      _conceitoSelecionado = null;
    });
  }

  Future<void> _encerrarQuiz() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quiz encerrado'),
        content: Text('Sua pontuação: $_pontos pontos'),
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

  @override
  Widget build(BuildContext context) {
    if (_erroCarregamento != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('QuizMyBrain')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_erroCarregamento!, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    if (_perguntas.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return TelaQuiz(
      questao: _perguntas[_perguntaAtual],
      ultimaQuestao: _perguntaAtual == _perguntas.length - 1,
      respostaMostrada: _respostaMostrada,
      respostaCorreta: _respostaEstaCorreta,
      alternativaSelecionada: _alternativaSelecionada,
      associacoes: _associacoes,
      conceitoSelecionado: _conceitoSelecionado,
      pontos: _pontos,
      onSelecionarAlternativa: (alternativa) {
        setState(() => _alternativaSelecionada = alternativa);
      },
      onSelecionarConceito: (conceito) {
        setState(() => _conceitoSelecionado = conceito);
      },
      onSelecionarAssociacao: _selecionarAssociacao,
      onMostrarResposta: _mostrarResposta,
      onEncerrar: _encerrarQuiz,
    );
  }
}
