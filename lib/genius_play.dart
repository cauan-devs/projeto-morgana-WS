import 'dart:async' as k;
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const GeniusPlayApp());
}

class GeniusPlayApp extends StatelessWidget {
  const GeniusPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3C00A7),
          brightness: Brightness.light,
        ),
      ),
      home: const Geniusplay(),
    );
  }
}

class Geniusplay extends StatefulWidget {
  const Geniusplay({super.key});

  @override
  State<Geniusplay> createState() => _GeniusplayState();
}

class _GeniusplayState extends State<Geniusplay> {
  final GlobalKey<GeniusPentagonState> _pentagonKey =
      GlobalKey<GeniusPentagonState>();
  final math.Random _random = math.Random();
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const Map<String, List<String>> _colorAudioPaths = {
    'pt': [
      'audios/PT-BR/amarelo (1).mp3',
      'audios/PT-BR/azul.mp3',
      'audios/PT-BR/vermelho.mp3',
      'audios/PT-BR/laranja.mp3',
      'audios/PT-BR/verde.mp3',
    ],
    'en': [
      'audios/EN/yellow.mp3',
      'audios/EN/blue.mp3',
      'audios/EN/red.mp3',
      'audios/EN/orange.mp3',
      'audios/EN/green.mp3',
    ],
    'es': [
      'audios/ES/amarillo.mp3',
      'audios/ES/azul (1).mp3',
      'audios/ES/rojo.mp3',
      'audios/ES/naranja.mp3',
      'audios/ES/verde (1).mp3',
    ],
  };
  static const String _clickAudioPath =
      'audios/CLICK-MOUSE/mouse-click-sound.mp3';

  String _language = 'pt';
  final List<int> _sequence = [];
  k.Timer? _timer;
  int _level = 1;
  int _score = 0;
  int _elapsedSeconds = 0;
  int _playerPosition = 0;
  int _correctRoundsInLevel = 0;
  int _roundToken = 0;
  bool _isPlaying = false;
  bool _isShowingSequence = false;
  bool _isAudioReady = false;
  bool _audioContextUnlocked = false;
  int? _preparedPiece;
  String? _preparedAudioPath;
  String? _message;

  @override
  void initState() {
    super.initState();
    final systemLanguage =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    _language = switch (systemLanguage) {
      'en' => 'en',
      'es' => 'es',
      _ => 'pt',
    };
    _createSequence();
    k.unawaited(_prepareFirstAudio());
    k.unawaited(_setPortraitOrientation([DeviceOrientation.portraitUp]));
  }

  k.Future<void> _setPortraitOrientation(
    List<DeviceOrientation> orientations,
  ) async {
    try {
      await SystemChrome.setPreferredOrientations(orientations);
    } on Exception catch (error) {
      debugPrint('Não foi possível definir a orientação da tela: $error');
    }
  }

  String _label(String portuguese, String english, String spanish) {
    return switch (_language) {
      'en' => english,
      'es' => spanish,
      _ => portuguese,
    };
  }

  String get _formattedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _toggleGame() {
    if (_isPlaying) {
      _stopGame();
      return;
    }

    _startGame();
  }

  void _startGame() {
    if (!_isAudioReady || _sequence.isEmpty) return;
    final token = ++_roundToken;
    _timer?.cancel();
    _timer = null;
    final firstAudio = _playAudio(
      _colorAudioPaths[_language]![_sequence.first],
      usePreparedSource: true,
    );
    setState(() {
      _isPlaying = true;
      _isShowingSequence = false;
      _message = null;
      _level = 1;
      _score = 0;
      _elapsedSeconds = 0;
      _correctRoundsInLevel = 0;
      _playerPosition = 0;
    });

    _timer = k.Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _isPlaying) {
        setState(() => _elapsedSeconds++);
      }
    });
    k.unawaited(_showSequence(firstAudio: firstAudio, token: token));
  }

  void _stopGame() {
    _roundToken++;
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isPlaying = false;
      _isShowingSequence = false;
      _sequence.clear();
      _playerPosition = 0;
      _correctRoundsInLevel = 0;
      _level = 1;
      _score = 0;
      _elapsedSeconds = 0;
      _message = null;
      _createSequence();
    });
    k.unawaited(_stopAndPrepareFirstAudio());
  }

  void _restartGame() {
    if (_audioContextUnlocked) {
      _roundToken++;
      _timer?.cancel();
      _timer = null;
      setState(() {
        _isPlaying = false;
        _isShowingSequence = true;
        _message = null;
        _level = 1;
        _score = 0;
        _elapsedSeconds = 0;
        _correctRoundsInLevel = 0;
        _playerPosition = 0;
        _createSequence();
      });
      k.unawaited(_prepareAndStartGame());
      return;
    }

    final firstPiece = _preparedPiece;
    setState(() {
      _sequence
        ..clear()
        ..add(firstPiece ?? _random.nextInt(5));
      _level = 1;
      _score = 0;
      _elapsedSeconds = 0;
      _correctRoundsInLevel = 0;
      _playerPosition = 0;
      _message = null;
    });
    _startGame();
  }

  k.Future<void> _prepareAndStartGame() async {
    await _stopAudioPlayback();
    await _prepareFirstAudio();
    if (mounted && _isAudioReady) _startGame();
  }

  k.Future<void> _stopAndPrepareFirstAudio() async {
    await _stopAudioPlayback();
    if (mounted) await _prepareFirstAudio();
  }

  k.Future<void> _prepareFirstAudio() async {
    if (_sequence.isEmpty) _createSequence();
    final piece = _sequence.first;
    final assetPath = _colorAudioPaths[_language]![piece];
    if (_isAudioReady && _preparedAudioPath == assetPath) return;

    if (mounted) {
      setState(() {
        _isAudioReady = false;
        _preparedPiece = null;
        _preparedAudioPath = null;
      });
    }

    try {
      await _audioPlayer.setSource(AssetSource(assetPath));
      if (!mounted) return;
      setState(() {
        _isAudioReady = true;
        _preparedPiece = piece;
        _preparedAudioPath = assetPath;
      });
    } on Exception catch (error, stackTrace) {
      debugPrint('Erro ao preparar o áudio "$assetPath": $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _message = _label(
          'Não foi possível carregar o áudio.',
          'Could not load audio.',
          'No se pudo cargar el audio.',
        );
      });
    }
  }

  void _createSequence({int? firstPiece}) {
    _sequence
      ..clear()
      ..addAll(
        List<int>.generate(
          _level,
          (index) => index == 0 && firstPiece != null
              ? firstPiece
              : _random.nextInt(5),
        ),
      );
  }

  k.Future<void> _showSequence({
    k.Future<bool>? firstAudio,
    required int token,
  }) async {
    final sequence = List<int>.of(_sequence);
    setState(() {
      _isShowingSequence = true;
      _playerPosition = 0;
    });

    for (var index = 0; index < sequence.length; index++) {
      final piece = sequence[index];
      if (!mounted || !_isPlaying || token != _roundToken) return;
      _pentagonKey.currentState?.flash(piece);
      final audioPlayed = index == 0 && firstAudio != null
          ? await firstAudio
          : await _playAudio(_colorAudioPaths[_language]![piece]);
      if (!mounted || !_isPlaying || token != _roundToken) return;
      if (!audioPlayed) break;
      await k.Future<void>.delayed(const Duration(milliseconds: 120));
    }

    if (!mounted || token != _roundToken) return;
    setState(() => _isShowingSequence = false);
  }

  k.Future<bool> _playAudio(
    String assetPath, {
    bool usePreparedSource = false,
  }) async {
    final completed = k.Completer<void>();
    final completionSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (!completed.isCompleted) completed.complete();
    });
    final stateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped && !completed.isCompleted) {
        completed.complete();
      }
    });

    try {
      if (usePreparedSource && _preparedAudioPath == assetPath) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.play(AssetSource(assetPath));
      }
      await completed.future;
      _audioContextUnlocked = true;
      _preparedAudioPath = null;
      _preparedPiece = null;
      _isAudioReady = false;
      return true;
    } on Exception catch (error, stackTrace) {
      debugPrint('Erro ao reproduzir o áudio "$assetPath": $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _message = _label(
            'Não foi possível reproduzir o áudio.',
            'Could not play audio.',
            'No se pudo reproducir el audio.',
          );
        });
      }
      return false;
    } finally {
      await completionSubscription.cancel();
      await stateSubscription.cancel();
    }
  }

  k.Future<void> _onPiecePressed(int index) async {
    if (!_isPlaying || _isShowingSequence) return;

    final token = _roundToken;
    setState(() => _isShowingSequence = true);
    await _playAudio(_clickAudioPath);
    if (!mounted || !_isPlaying || token != _roundToken) return;
    setState(() => _isShowingSequence = false);

    if (_sequence[_playerPosition] != index) {
      _roundToken++;
      _timer?.cancel();
      _timer = null;
      final finalTime = _formattedTime;
      final finalScore = _score;
      setState(() {
        _isPlaying = false;
        _isShowingSequence = false;
        _level = 1;
        _elapsedSeconds = 0;
        _correctRoundsInLevel = 0;
        _sequence.clear();
        _playerPosition = 0;
        _message = _label('Fim de jogo!', 'Game over!', '¡Fin del juego!');
      });
      k.unawaited(_showGameOverDialog(finalScore, finalTime));
      _createSequence();
      k.unawaited(_stopAndPrepareFirstAudio());
      return;
    }

    setState(() {
      _playerPosition++;
    });

    if (_playerPosition == _sequence.length) {
      final nextRoundToken = ++_roundToken;
      setState(() {
        _score++;
        _correctRoundsInLevel++;
        if (_correctRoundsInLevel == 2) {
          _level++;
          _correctRoundsInLevel = 0;
        }
        _createSequence();
      });
      k.unawaited(_showSequence(token: nextRoundToken));
    }
  }

  k.Future<void> _showGameOverDialog(int finalScore, String finalTime) async {
    await k.Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _label('Fim de jogo', 'Game over', 'Fin del juego'),
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${_label('Pontuação final', 'Final score', 'Puntuación final')}: '
          '${finalScore.toString().padLeft(4, '0')}\n'
          '${_label('Tempo', 'Time', 'Tiempo')}: $finalTime',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              _label('OK', 'OK', 'OK'),
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _leaveGame() {
    _roundToken++;
    _timer?.cancel();
    _timer = null;
    k.unawaited(_stopAudioPlayback());
    Navigator.of(context).maybePop();
  }

  k.Future<void> _stopAudioPlayback() async {
    try {
      await _audioPlayer.stop();
    } on Exception catch (error, stackTrace) {
      debugPrint('Não foi possível parar o áudio: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    k.unawaited(_disposeAudioPlayer());
    k.unawaited(_setPortraitOrientation(DeviceOrientation.values));
    super.dispose();
  }

  k.Future<void> _disposeAudioPlayer() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.dispose();
    } on Exception catch (error, stackTrace) {
      debugPrint('Não foi possível finalizar o player de áudio: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pentagonSize = (constraints.maxHeight - 190)
                .clamp(120.0, constraints.maxWidth - 32)
                .clamp(120.0, 340.0)
                .toDouble();

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 14),
                  _buildStats(),
                  if (_message != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _message!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: const Color(0xFF3C00A7),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: pentagonSize,
                        height: pentagonSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GeniusPentagon(
                              key: _pentagonKey,
                              size: pentagonSize,
                              enabled: _isPlaying && !_isShowingSequence,
                              onPiecePressed: _onPiecePressed,
                            ),
                            _buildCenterButton(pentagonSize),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              const TextSpan(text: 'Score: '),
                              TextSpan(
                                text: _score.toString().padLeft(4, '0'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 124,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isPlaying || _isAudioReady
                              ? _restartGame
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3C00A7),
                            foregroundColor: Colors.white,
                            shape: const OvalBorder(),
                            minimumSize: const Size.fromHeight(48),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(
                            'Restart',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          tooltip: _label('Voltar', 'Back', 'Volver'),
          onPressed: _leaveGame,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: const Color(0xFF3C00A7),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            'Genius Play',
            style: GoogleFonts.montserrat(
              color: Color(0xFF3C00A7),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _language,
            dropdownColor: Colors.white,
            icon: const Icon(Icons.expand_more_rounded),
            iconEnabledColor: const Color(0xFF3C00A7),
            style: GoogleFonts.montserrat(
              color: const Color(0xFF3C00A7),
              fontWeight: FontWeight.bold,
            ),
            items: [
              DropdownMenuItem(
                value: 'pt',
                child: Text(
                  'Português',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text(
                  'Inglês',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
              ),
              DropdownMenuItem(
                value: 'es',
                child: Text(
                  'Espanhol',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            onChanged: (value) {
              if (value == null || _isPlaying) return;
              setState(() => _language = value);
              k.unawaited(_stopAndPrepareFirstAudio());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${_label('Nível', 'Level', 'Nivel')}: $_level',
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            '${_label('Cronômetro', 'Timer', 'Cronómetro')}: $_formattedTime',
            textAlign: TextAlign.end,
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterButton(double size) {
    final buttonWidth = (size * 0.3).clamp(40.0, 90.0).toDouble();
    final buttonHeight = (size * 0.15).clamp(30.0, 48.0).toDouble();
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: _isPlaying || _isAudioReady ? _toggleGame : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3C00A7),
          foregroundColor: Colors.white,
          shape: const OvalBorder(),
          minimumSize: Size(buttonWidth, buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        child: Text(
          _isPlaying
              ? _label('Parar', 'Stop', 'Parar')
              : _label('Start', 'Start', 'Start'),
          style: GoogleFonts.montserrat(
            fontSize: (size * 0.05).clamp(12.0, 16.0).toDouble(),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class GeniusPentagon extends StatefulWidget {
  const GeniusPentagon({
    super.key,
    this.size = 320,
    this.enabled = true,
    this.onPiecePressed,
  });

  final double size;
  final bool enabled;
  final ValueChanged<int>? onPiecePressed;

  @override
  State<GeniusPentagon> createState() => GeniusPentagonState();
}

class GeniusPentagonState extends State<GeniusPentagon>
    with SingleTickerProviderStateMixin {
  static const List<Color> _pieceColors = [
    Color(0xFFFFD83D),
    Color(0xFF3788FF),
    Color(0xFFFF4B55),
    Color(0xFFFF9138),
    Color(0xFF36D17C),
  ];

  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;
  int? _activePiece;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _activePiece = null);
      }
    });
  }

  void flash(int index) {
    RangeError.checkValidIndex(index, _pieceColors, 'index');
    setState(() => _activePiece = index);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details, _PentagonPainter painter) {
    final index = painter.pieceAt(
      details.localPosition,
      Size(widget.size, widget.size),
    );
    if (index == null) return;
    widget.onPiecePressed?.call(index);
    flash(index);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final painter = _PentagonPainter(
          colors: _pieceColors,
          activePiece: _activePiece,
          glowProgress: _glowAnimation.value,
        );
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.enabled
              ? (details) => _handleTap(details, painter)
              : null,
          child: CustomPaint(size: Size.square(widget.size), painter: painter),
        );
      },
    );
  }
}

class _PentagonPainter extends CustomPainter {
  const _PentagonPainter({
    required this.colors,
    required this.activePiece,
    required this.glowProgress,
  });

  final List<Color> colors;
  final int? activePiece;
  final double glowProgress;

  List<Offset> _vertices(Size size, double radius) {
    final center = Offset(size.width / 2, size.height / 2);
    return List<Offset>.generate(5, (index) {
      final angle = -math.pi / 2 + index * 2 * math.pi / 5;
      return Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
    });
  }

  List<Path> _piecePaths(Size size) {
    final radius = math.min(size.width, size.height) / 2 - 12;
    final outer = _vertices(size, radius);
    final inner = _vertices(size, radius * 0.38);

    return List<Path>.generate(5, (index) {
      final next = (index + 1) % 5;
      return Path()
        ..moveTo(outer[index].dx, outer[index].dy)
        ..lineTo(outer[next].dx, outer[next].dy)
        ..lineTo(inner[next].dx, inner[next].dy)
        ..lineTo(inner[index].dx, inner[index].dy)
        ..close();
    });
  }

  int? pieceAt(Offset position, Size size) {
    final paths = _piecePaths(size);
    for (var index = 0; index < paths.length; index++) {
      if (paths[index].contains(position)) return index;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paths = _piecePaths(size);

    if (activePiece case final index? when glowProgress > 0) {
      canvas.drawPath(
        paths[index],
        Paint()
          ..color = colors[index].withValues(alpha: glowProgress * 0.8)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18 * glowProgress),
      );
    }

    for (var index = 0; index < paths.length; index++) {
      final isActive = index == activePiece && glowProgress > 0;
      final color = colors[index];
      final paint = Paint()..style = PaintingStyle.fill;

      if (isActive) {
        paint.shader = RadialGradient(
          colors: [Color.lerp(Colors.white, color, 0.25)!, color],
        ).createShader(paths[index].getBounds());
      } else {
        paint.color = color;
      }

      canvas.drawPath(paths[index], paint);
    }

    final outerRadius = math.min(size.width, size.height) / 2 - 12;
    final innerVertices = _vertices(size, outerRadius * 0.385);
    final innerPath = Path()
      ..moveTo(innerVertices.first.dx, innerVertices.first.dy)
      ..addPolygon(innerVertices.skip(1).toList(), true);
    canvas.drawPath(
      innerPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _PentagonPainter oldDelegate) {
    return activePiece != oldDelegate.activePiece ||
        glowProgress != oldDelegate.glowProgress ||
        colors != oldDelegate.colors;
  }
}
