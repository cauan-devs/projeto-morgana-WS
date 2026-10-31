import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:ws_morgana/modelos/questao_quiz.dart';

class QuestaoQuizRepository {
  const QuestaoQuizRepository();

  Future<List<QuestaoQuiz>> carregar() async {
    final conteudo = await rootBundle.loadString(
      'Banco.JSON/bancoQuestoes.json',
    );
    final json = jsonDecode(conteudo);
    if (json is! Map<String, dynamic> || json['perguntas'] is! List) {
      throw const FormatException('Formato do banco de questões inválido.');
    }

    final perguntasJson = json['perguntas'] as List;
    final perguntas = perguntasJson
        .map((pergunta) {
          if (pergunta is! Map<String, dynamic>) {
            throw const FormatException('Uma questão do banco é inválida.');
          }
          return QuestaoQuiz.fromJson(pergunta);
        })
        .toList(growable: false);
    if (perguntas.isEmpty) {
      throw const FormatException('O banco de questões está vazio.');
    }
    return perguntas;
  }
}
