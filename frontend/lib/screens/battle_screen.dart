import 'dart:math';
import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/models/battle_state.dart';
import 'package:dailyrpg/models/enums.dart';
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

  // --- Animações ---
  late AnimationController _flashController;
  Color _flashColor = Colors.transparent;
  late AnimationController _shakeController;

  // --- Paleta "Dungeon Battle" ---
  static const Color _bgDark = Color(0xFF050505);
  static const Color _stoneDark = Color(0xFF1C1C1C); // Fundo dos painéis
  static const Color _ironGrey = Color(0xFF455A64); // Bordas
  static const Color _hpRed = Color(0xFFD32F2F);
  static const Color _hpGreen = Color(0xFF388E3C);
  static const Color _gold = Color(0xFFFFD700);

  TextStyle get _pixelText =>
      GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white);
  TextStyle get _pixelLog =>
      GoogleFonts.vt323(fontSize: 18, color: Colors.white70);

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
          int start = count > 4 ? count - 4 : 0;
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

  // --- Efeitos Visuais ---
  void _triggerShake() {
    _shakeController.forward(from: 0.0);
  }

  void _triggerFlash(Color color) {
    setState(() => _flashColor = color);
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

  // --- Lógica de Ação ---
  void _handleAction(String type, {String? moveId, int? itemId}) async {
    if (_isProcessing) return;

    if (type == 'move') {
      _triggerFlash(Colors.white.withOpacity(0.2));
    } else if (type == 'item') {
      _triggerFlash(Colors.green.withOpacity(0.3));
    } else if (type == 'defend') {
      _triggerFlash(Colors.blue.withOpacity(0.3));
    }

    setState(() => _isProcessing = true);

    final provider = context.read<HunterProvider>();

    try {
      await provider.battleAction(type, moveId: moveId, itemId: itemId);
      final newState = provider.battleState;

      if (newState != null) {
        final newMessages = newState.log;

        // Limpa log antigo para mostrar fluxo recente
        setState(() => _displayLog.clear());

        for (String message in newMessages) {
          if (message.toLowerCase().contains("sofreu") ||
              message.toLowerCase().contains("dano")) {
            _triggerShake();
            _triggerFlash(Colors.red.withOpacity(0.4));
          }

          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;

          setState(() => _displayLog.add(message));
          _scrollToBottom();
        }

        if (newState.finished == true && mounted) {
          await Future.delayed(const Duration(milliseconds: 1000));
          _showEndDialog(newState.win);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _displayLog.add("Erro de conexão..."));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // --- INVENTÁRIO PADRONIZADO ---
  void _showInventory() {
    final provider = context.read<HunterProvider>();
    final inventory = provider.inventory
        .where(
          (slot) => slot.item.type == ItemType.Consumable && slot.quantity > 0,
        )
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent, // Transparente para ver o Container estilizado
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: _stoneDark, // Fundo de Pedra
            border: Border(
              top: BorderSide(color: _ironGrey, width: 4),
            ), // Borda de Ferro no topo
          ),
          child: Column(
            children: [
              // Cabeçalho do Inventário
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    FontAwesomeIcons.sackDollar,
                    color: _gold,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "ITENS DE COMBATE",
                    style: _pixelText.copyWith(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(height: 2, width: 100, color: _ironGrey),

              const SizedBox(height: 20),

              if (inventory.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          FontAwesomeIcons.boxOpen,
                          color: Colors.white24,
                          size: 40,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "MOCHILA VAZIA",
                          style: _pixelText.copyWith(color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemCount: inventory.length,
                    itemBuilder: (context, index) {
                      final slot = inventory[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _handleAction('item', itemId: slot.item.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            border: Border.all(color: Colors.white12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              // Ícone do Item
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border.all(color: _ironGrey),
                                ),
                                child: const Center(
                                  child: Icon(
                                    FontAwesomeIcons.flask,
                                    color: Colors.greenAccent,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Detalhes
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(slot.item.name, style: _pixelText),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Recupera vida instantaneamente", // Descrição fixa ou slot.item.description
                                      style: GoogleFonts.pixelifySans(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Quantidade
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _ironGrey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  "x${slot.quantity}",
                                  style: _pixelText.copyWith(color: _gold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 10),
              // Botão Fechar
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "FECHAR MOCHILA",
                    style: _pixelText.copyWith(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2C0404), // Vermelho Escuro Sangue
        title: Text(
          "CAMPO DE BATALHA",
          style: _pixelText.copyWith(fontSize: 14),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: _ironGrey, height: 2), // Borda cinza ferro
        ),
        actions: [
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.personRunning,
              color: Colors.white70,
              size: 18,
            ),
            onPressed: _isProcessing ? null : _confirmFlee,
          ),
        ],
      ),
      body: Consumer<HunterProvider>(
        builder: (context, provider, child) {
          final state = provider.battleState;
          if (state == null) {
            return const Center(
              child: CircularProgressIndicator(color: _hpRed),
            );
          }

          final double enemyPct = (state.enemyHp / 100.0).clamp(0.0, 1.0);
          final double playerPct = (state.playerHp / 100.0).clamp(0.0, 1.0);

          return Stack(
            children: [
              Column(
                children: [
                  // 1. ÁREA VISUAL (INIMIGO E BARRAS)
                  Expanded(
                    flex: 6,
                    child: Stack(
                      children: [
                        // Fundo e Animação de Shake
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _shakeController,
                            builder: (context, child) {
                              final double dx =
                                  sin(_shakeController.value * pi * 4) * 5;
                              return Transform.translate(
                                offset: Offset(dx, 0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _ironGrey,
                                        width: 4,
                                      ),
                                    ),
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'assets/images/battle.gif',
                                      ),
                                      fit: BoxFit.cover,
                                      opacity: 0.8,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // HUD INIMIGO (Topo Esquerda)
                        Positioned(
                          top: 20,
                          left: 20,
                          child: _buildHudBar(
                            name: state.opponentName,
                            current: state.enemyHp,
                            pct: enemyPct,
                            color: _hpRed,
                            alignment: CrossAxisAlignment.start,
                          ),
                        ),

                        // HUD JOGADOR (Baixo Direita)
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: _buildHudBar(
                            name: "VOCÊ",
                            current: state.playerHp,
                            pct: playerPct,
                            color: _hpGreen,
                            alignment: CrossAxisAlignment.end,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. ÁREA DE CONTROLE (LOG E BOTÕES)
                  Expanded(
                    flex: 4,
                    child: Container(
                      color: _stoneDark,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // LOG (PERGAMINHO DIGITAL)
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: _ironGrey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: _displayLog.length,
                                itemBuilder: (ctx, i) => Text(
                                  "> ${_displayLog[i]}",
                                  style: _pixelLog.copyWith(
                                    color: _getLogColor(_displayLog[i]),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // BOTÕES DE AÇÃO
                          Row(
                            children: [
                              _buildBattleBtn(
                                "ATACAR",
                                AkarIcons.sword,
                                const Color(0xFFB71C1C), // Vermelho Escuro
                                _isProcessing ? null : _showMoveSelection,
                              ),
                              const SizedBox(width: 8),
                              _buildBattleBtn(
                                "DEFENDER",
                                FontAwesomeIcons.shieldHalved,
                                const Color(0xFF0D47A1), // Azul Escuro
                                _isProcessing
                                    ? null
                                    : () => _handleAction('defend'),
                              ),
                              const SizedBox(width: 8),
                              _buildBattleBtn(
                                "MOCHILA",
                                FontAwesomeIcons.sackDollar,
                                Colors.brown[800]!, // Marrom Couro
                                _isProcessing ? null : _showInventory,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // FLASH OVERLAY (DANO/CURA)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _flashController,
                  builder: (context, child) => Container(
                    color: _flashColor.withOpacity(_flashController.value),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildHudBar({
    required String name,
    required int current,
    required double pct,
    required Color color,
    required CrossAxisAlignment alignment,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          name.toUpperCase(),
          style: _pixelText.copyWith(
            shadows: [const Shadow(blurRadius: 2, color: Colors.black)],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 140,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.black54,
            border: Border.all(color: Colors.white30),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: pct,
            child: Container(color: color),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "$current HP",
          style: _pixelText.copyWith(fontSize: 8, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildBattleBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape: BeveledRectangleBorder(
              side: const BorderSide(color: Colors.white24),
              borderRadius: BorderRadius.circular(2),
            ),
            elevation: 4,
          ),
          onPressed: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16),
              const SizedBox(height: 4),
              Text(label, style: _pixelText.copyWith(fontSize: 8)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLogColor(String text) {
    if (text.toLowerCase().contains("dano")) return Colors.redAccent;
    if (text.toLowerCase().contains("curou")) return Colors.greenAccent;
    if (text.toLowerCase().contains("venceu")) return _gold;
    return Colors.white70;
  }

  void _confirmFlee() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: _stoneDark,
        shape: const BeveledRectangleBorder(
          side: BorderSide(color: Colors.white),
        ),
        title: Text("FUGIR?", style: _pixelText),
        content: Text(
          "Escapar conta como derrota.",
          style: GoogleFonts.pixelifySans(color: Colors.white70),
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
              Navigator.pop(context);
            },
            child: Text(
              "CORRER",
              style: _pixelText.copyWith(color: Colors.red),
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
      backgroundColor: Colors.transparent, // Para usar container customizado
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        height: 280,
        decoration: const BoxDecoration(
          color: _stoneDark,
          border: Border(top: BorderSide(color: _ironGrey, width: 4)),
        ),
        child: Column(
          children: [
            Text("ESCOLHA O ATAQUE", style: _pixelText),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: moves.length,
                itemBuilder: (ctx, i) {
                  final move = moves[i];
                  Color moveColor = Colors.grey[800]!;
                  // Cores baseadas no tipo (exemplo)
                  if (move.affinity == 'Strength')
                    moveColor = const Color(0xFFB71C1C);
                  if (move.affinity == 'Intelligence')
                    moveColor = const Color(0xFF4A148C);
                  if (move.affinity == 'Dexterity')
                    moveColor = const Color(0xFF1B5E20);

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: moveColor,
                      shape: const BeveledRectangleBorder(
                        side: BorderSide(color: Colors.white12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _handleAction('move', moveId: move.id);
                    },
                    child: Text(
                      move.name,
                      style: _pixelText.copyWith(fontSize: 8),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEndDialog(bool win) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: _stoneDark,
        shape: const BeveledRectangleBorder(
          side: BorderSide(color: Colors.white),
        ),
        title: Text(
          win ? "VITÓRIA!" : "DERROTA...",
          style: _pixelText.copyWith(
            color: win ? Colors.green : Colors.red,
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              win ? FontAwesomeIcons.trophy : FontAwesomeIcons.skull,
              size: 40,
              color: win ? _gold : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              win ? "Inimigo derrotado!" : "Você caiu em combate...",
              style: GoogleFonts.pixelifySans(color: Colors.white70),
              textAlign: TextAlign.center,
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
                Navigator.pop(c);
                Navigator.pop(context);
                context.read<HunterProvider>().clearBattle();
              },
              child: Text("VOLTAR", style: _pixelText),
            ),
          ),
        ],
      ),
    );
  }
}
