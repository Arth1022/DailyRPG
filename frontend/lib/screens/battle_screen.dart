import 'dart:math'; // Import para animações matemáticas
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/models/battle_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  List<String> _displayLog = [];
  bool _isProcessing = false;

  // --- CONTROLADORES DE ANIMAÇÃO ---
  late AnimationController _shakeController;
  late AnimationController _flashController;
  Color _flashColor = Colors.transparent;
  // --------------------------------

  // --- Estilos de Tema ---
  static const darkBackground = Color(0xFF1A1A1A);
  static const darkCardColor = Color(0xff2a2a2a);
  // Azul Ciano (Cor principal do tema)
  static const pixelPrimaryColor = Color.fromARGB(255, 77, 167, 209);
  static const enemyColor = Color(0xFFE53935);
  static const playerColor = Color.fromARGB(255, 85, 166, 82);

  TextStyle get _pixelText =>
      GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white);

  TextStyle get _pixelName => GoogleFonts.pressStart2p(
    fontSize: 12,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    shadows: [const Shadow(offset: Offset(2, 2), color: Colors.black)],
  );

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<HunterProvider>().battleState;
      if (state != null) {
        setState(() {
          int count = state.log.length;
          int start = count > 3 ? count - 3 : 0;
          _displayLog = state.log.sublist(start);
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _shakeController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  // --- EFEITOS ---
  void _triggerShake() {
    _shakeController.forward(from: 0.0);
  }

  void _triggerFlash(Color color) {
    setState(() {
      _flashColor = color;
    });
    _flashController.forward(from: 0.0).then((_) => _flashController.reverse());
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleAction(String type, {String? moveId}) async {
    if (_isProcessing) return;

    if (type == 'move') {
      _triggerShake();
      _triggerFlash(Colors.white.withOpacity(0.3));
    } else if (type == 'potion') {
      _triggerFlash(Colors.greenAccent.withOpacity(0.4));
    } else if (type == 'defend') {
      _triggerFlash(Colors.blueAccent.withOpacity(0.4));
    }

    setState(() {
      _isProcessing = true;
    });

    final provider = context.read<HunterProvider>();
    final int previousLogLength = provider.battleState?.log.length ?? 0;

    try {
      await provider.battleAction(type, moveId: moveId);

      final newState = provider.battleState;

      if (newState != null) {
        final fullLog = newState.log;
        List<String> newMessages = [];

        if (fullLog.length > previousLogLength) {
          newMessages = fullLog.sublist(previousLogLength);
        } else {
          if (fullLog.isNotEmpty) newMessages.add(fullLog.last);
        }

        setState(() {
          _displayLog.clear();
        });

        for (String message in newMessages) {
          if (message.toLowerCase().contains("você sofreu") ||
              message.toLowerCase().contains("dano")) {
            _triggerShake();
            _triggerFlash(Colors.red.withOpacity(0.3));
          }

          await Future.delayed(const Duration(milliseconds: 800));

          if (!mounted) return;

          setState(() {
            _displayLog.add(message);
          });
          _scrollToBottom();
        }

        if (newState.finished == true && mounted) {
          await Future.delayed(const Duration(milliseconds: 1000));
          _showEndDialog(newState.win);
          return;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _displayLog.add("Erro de conexão..."));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Color _getColorForAffinity(String affinity) {
    switch (affinity) {
      case 'Strength':
        return const Color(0xFFC0392B);
      case 'Intelligence':
        return const Color(0xFF8E44AD);
      case 'Dexterity':
        return const Color(0xFF27AE60);
      default:
        return Colors.grey[700]!;
    }
  }

  Widget _buildLogText(String text) {
    Color textColor = Colors.white;
    IconData? icon;

    if (text.toLowerCase().contains("dano") ||
        text.toLowerCase().contains("hit")) {
      textColor = const Color(0xFFEF5350);
      icon = Icons.flash_on;
    } else if (text.toLowerCase().contains("curou") ||
        text.toLowerCase().contains("heal")) {
      textColor = const Color(0xFF66BB6A);
      icon = Icons.favorite;
    } else if (text.toLowerCase().contains("venceu") ||
        text.toLowerCase().contains("ganhou")) {
      textColor = const Color(0xFFFFCA28);
      icon = Icons.emoji_events;
    } else if (text.toLowerCase().contains("errou")) {
      textColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6.0,
      ), // Mais espaço entre linhas
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone pequeno para indicar linha
          if (icon != null)
            Icon(icon, color: textColor, size: 14)
          else
            const Icon(Icons.chevron_right, color: Colors.white54, size: 14),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              text,
              style: GoogleFonts.vt323(
                fontSize: 20,
                color: textColor,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoveSelection() {
    final moves =
        context.read<HunterProvider>().battleState?.availableMoves ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          decoration: const BoxDecoration(
            color: darkCardColor, // Fundo sólido
            border: Border(
              top: BorderSide(color: pixelPrimaryColor, width: 4),
            ), // Borda sólida
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SELECIONE O ATAQUE:", style: _pixelText),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.8,
                  ),
                  itemCount: moves.length,
                  itemBuilder: (context, index) {
                    final move = moves[index];
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getColorForAffinity(move.affinity),
                        foregroundColor: Colors.white,
                        shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(color: Colors.white54, width: 2),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _handleAction('move', moveId: move.id);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            move.name.toUpperCase(),
                            style: _pixelText.copyWith(fontSize: 8),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "<< VOLTAR",
                  style: _pixelText.copyWith(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEndDialog(bool win) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: darkCardColor,
        // Borda pixelada para o dialog
        shape: const BeveledRectangleBorder(
          side: BorderSide(color: Colors.white, width: 2),
        ),
        title: Text(
          win ? 'VITÓRIA!' : 'DERROTA...',
          textAlign: TextAlign.center,
          style: _pixelText.copyWith(
            color: win ? Colors.greenAccent : Colors.redAccent,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              win ? FontAwesomeIcons.trophy : FontAwesomeIcons.skull,
              size: 40,
              color: win ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              win
                  ? 'Inimigo derrotado!\nVocê ganhou XP e Ouro.'
                  : 'Você desmaiou...\nTente novamente.',
              textAlign: TextAlign.center,
              style: GoogleFonts.pixelifySans(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                shape: const BeveledRectangleBorder(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                context.read<HunterProvider>().clearBattle();
              },
              child: Text('VOLTAR', style: _pixelText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    Color color,
    VoidCallback? onPressed,
  ) {
    final bool isEnabled = onPressed != null && !_isProcessing;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? color
                : Color.fromARGB(255, 29, 29, 29),
            foregroundColor: isEnabled ? Colors.white : Colors.grey[600],
            padding: const EdgeInsets.symmetric(vertical: 14),
            // Botão Chanfrado (Pixelado)
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Colors.white24, width: 2),
            ),
            elevation: 0, // Sem sombra para ficar "flat"
          ),
          onPressed: isEnabled ? onPressed : null,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: _pixelText.copyWith(fontSize: 8)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 29, 29),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'ARENA DE BATALHA',
          style: _pixelText.copyWith(fontSize: 12),
        ),
        backgroundColor: const Color(0xFF8B0000),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _isProcessing
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        backgroundColor: const Color.fromARGB(255, 29, 29, 29),
                        shape: const BeveledRectangleBorder(
                          side: BorderSide(color: Colors.white),
                        ),
                        title: Text("FUGIR?", style: _pixelText),
                        content: Text(
                          "Escapar conta como derrota.",
                          style: GoogleFonts.pixelifySans(
                            color: Colors.white70,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: Text("FICAR", style: _pixelText),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(c);
                              context.read<HunterProvider>().clearBattle();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "CORRER",
                              style: _pixelText.copyWith(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
          ),
        ],
      ),
      body: Consumer<HunterProvider>(
        builder: (context, provider, child) {
          final state = provider.battleState;

          if (state == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          double enemyMax = 100.0;
          double playerMax = 100.0;
          double enemyPercent = (state.enemyHp / enemyMax).clamp(0.0, 1.0);
          double playerPercent = (state.playerHp / playerMax).clamp(0.0, 1.0);
          final isLoading = provider.isLoading;

          return Stack(
            children: [
              Column(
                children: [
                  // --- ÁREA SUPERIOR (GIF E HUD) ---
                  Expanded(
                    flex: 9,
                    child: AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        final double offset =
                            sin(_shakeController.value * pi * 6) * 8;
                        return Transform.translate(
                          offset: Offset(offset, 0),
                          child: child,
                        );
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              color: const Color.fromARGB(255, 29, 29, 29),
                              child: Image.asset(
                                'assets/images/battle.gif',
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            ),
                          ),

                          // BARRA INIMIGO (Design Pixelado)
                          Positioned(
                            top: 20,
                            left: 20,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(100, 0, 0, 0),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ), // Borda Branca grossa
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.opponentName.toUpperCase(),
                                    style: _pixelName,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 130,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        29,
                                        29,
                                        29,
                                      ),
                                      border: Border.all(color: Colors.white54),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: enemyPercent,
                                      child: Container(color: enemyColor),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "HP ${state.enemyHp}",
                                    style: _pixelText.copyWith(
                                      fontSize: 8,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // BARRA JOGADOR (Design Pixelado)
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(100, 0, 0, 0),
                                border: Border.all(
                                  color: pixelPrimaryColor,
                                  width: 2,
                                ), // Borda Ciano
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "VOCÊ",
                                    style: _pixelName.copyWith(
                                      color: pixelPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 130,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        29,
                                        29,
                                        29,
                                      ),
                                      border: Border.all(color: Colors.white54),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: playerPercent,
                                      child: Container(color: playerColor),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "HP ${state.playerHp}",
                                    style: _pixelText.copyWith(
                                      fontSize: 8,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- ÁREA INFERIOR (LOG E BOTÕES) ---
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 29, 29, 29),
                        border: Border(
                          top: BorderSide(color: Colors.white, width: 3),
                        ),
                      ),
                      child: Column(
                        children: [
                          // CAIXA DE TEXTO (REFEITA: Borda simples e fundo escuro)
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 29, 29, 29),
                                border: Border.all(
                                  color: pixelPrimaryColor,
                                  width: 2,
                                ), // Borda Ciano
                                // Sem sombras ou gradients
                              ),
                              child: _displayLog.isEmpty
                                  ? Center(
                                      child: Text(
                                        "A batalha começou!",
                                        style: GoogleFonts.vt323(
                                          color: Colors.white38,
                                          fontSize: 20,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      controller: _scrollController,
                                      itemCount: _displayLog.length,
                                      itemBuilder: (context, index) {
                                        return _buildLogText(
                                          _displayLog[index],
                                        );
                                      },
                                    ),
                            ),
                          ),

                          // BOTÕES
                          Row(
                            children: [
                              _buildActionButton(
                                "ATACAR",
                                const Color(0xFFB71C1C),
                                isLoading ? null : _showMoveSelection,
                              ),
                              _buildActionButton(
                                "DEFESA",
                                const Color(0xFF0D47A1),
                                isLoading
                                    ? null
                                    : () => _handleAction('defend'),
                              ),
                              _buildActionButton(
                                "ITEM",
                                const Color(0xFF1B5E20),
                                isLoading
                                    ? null
                                    : () => _handleAction('potion'),
                              ),
                              _buildActionButton(
                                "FUGIR",
                                const Color(0xFF424242),
                                isLoading
                                    ? null
                                    : () {
                                        showDialog(
                                          context: context,
                                          builder: (c) => AlertDialog(
                                            backgroundColor: darkCardColor,
                                            shape: const BeveledRectangleBorder(
                                              side: BorderSide(
                                                color: Colors.white,
                                              ),
                                            ),
                                            title: Text(
                                              "FUGIR?",
                                              style: _pixelText,
                                            ),
                                            content: Text(
                                              "Escapar conta como derrota.",
                                              style: GoogleFonts.pixelifySans(
                                                color: Colors.white70,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(c),
                                                child: Text(
                                                  "FICAR",
                                                  style: _pixelText,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(c);
                                                  context
                                                      .read<HunterProvider>()
                                                      .clearBattle();
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  "CORRER",
                                                  style: _pixelText.copyWith(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // CAMADA DE FLASH
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _flashController,
                  builder: (context, child) {
                    return Container(
                      color: _flashColor.withOpacity(_flashController.value),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
