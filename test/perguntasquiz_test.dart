import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ws_morgana/modelos/questao_quiz.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('carrega e interpreta as questões do arquivo JSON', () async {
    final conteudo = await rootBundle.loadString(
      'Banco.JSON/bancoQuestoes.json',
    );
    final json = jsonDecode(conteudo) as Map<String, dynamic>;
    final perguntas = (json['perguntas'] as List)
        .map(
          (pergunta) => QuestaoQuiz.fromJson(pergunta as Map<String, dynamic>),
        )
        .toList();

    expect(perguntas, hasLength(7));
    expect(perguntas.map((pergunta) => pergunta.tipo).toSet(), {
      'ME',
      'VF',
      'REL',
    });
    expect(perguntas[5].respostaRelacao, {0: 1, 1: 2, 2: 0});
  });
}
