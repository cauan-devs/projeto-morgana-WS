class QuestaoQuiz {
  const QuestaoQuiz({
    required this.id,
    required this.peso,
    required this.tipo,
    required this.enunciado,
    this.alternativas = const [],
    this.itensRelacao = const [],
    this.conceitosRelacao = const [],
    this.resposta,
    this.respostaRelacao = const {},
  });

  factory QuestaoQuiz.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final peso = json['peso'];
    final tipo = json['tipo'];
    final enunciado = json['enunciado'];
    if (id is! int || peso is! int || tipo is! String || enunciado is! String) {
      throw const FormatException('Dados básicos de questão inválidos.');
    }

    final alternativasJson = json['alternativas'];
    final respostaJson = json['resposta'];
    if (tipo == 'REL') {
      if (alternativasJson is! List ||
          alternativasJson.length != 2 ||
          alternativasJson[0] is! List ||
          alternativasJson[1] is! List ||
          respostaJson is! List) {
        throw const FormatException('Dados de questão REL inválidos.');
      }

      final itens = List<String>.from(alternativasJson[0] as List);
      final conceitos = List<String>.from(alternativasJson[1] as List);
      final associacoes = <int, int>{};
      for (final associacao in respostaJson) {
        if (associacao is! List ||
            associacao.length != 2 ||
            associacao[0] is! int ||
            associacao[1] is! int) {
          throw const FormatException('Gabarito de questão REL inválido.');
        }
        final item = associacao[0] as int;
        final conceito = associacao[1] as int;
        if (item < 0 ||
            item >= itens.length ||
            conceito < 0 ||
            conceito >= conceitos.length ||
            associacoes.containsKey(item) ||
            associacoes.values.contains(conceito)) {
          throw const FormatException('Associação de questão REL inválida.');
        }
        associacoes[item] = conceito;
      }
      if (itens.isEmpty ||
          itens.length != conceitos.length ||
          associacoes.length != itens.length) {
        throw const FormatException('Questão REL incompleta.');
      }

      return QuestaoQuiz(
        id: id,
        peso: peso,
        tipo: tipo,
        enunciado: enunciado,
        itensRelacao: itens,
        conceitosRelacao: conceitos,
        respostaRelacao: associacoes,
      );
    }

    if (tipo != 'ME' && tipo != 'VF' ||
        alternativasJson is! List ||
        respostaJson is! int) {
      throw const FormatException('Dados de questão objetiva inválidos.');
    }
    final alternativas = List<String>.from(alternativasJson);
    if (respostaJson < 0 || respostaJson >= alternativas.length) {
      throw const FormatException('Resposta de questão objetiva inválida.');
    }
    return QuestaoQuiz(
      id: id,
      peso: peso,
      tipo: tipo,
      enunciado: enunciado,
      alternativas: alternativas,
      resposta: respostaJson,
    );
  }

  final int id;
  final int peso;
  final String tipo;
  final String enunciado;
  final List<String> alternativas;
  final List<String> itensRelacao;
  final List<String> conceitosRelacao;
  final int? resposta;
  final Map<int, int> respostaRelacao;
}
