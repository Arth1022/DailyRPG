import 'dart:math'; // Para rotação aleatória
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/services/api_service.dart';
import 'add_contract_screen.dart';

class GuildBoardScreen extends StatefulWidget {
  const GuildBoardScreen({super.key});

  @override
  State<GuildBoardScreen> createState() => _GuildBoardScreenState();
}

class _GuildBoardScreenState extends State<GuildBoardScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _boardItems = [];
  bool _isLoading = true;

  // --- Paleta "Guild Board" ---
  static const Color _woodDark = Color(0xFF3E2723); // Fundo do quadro
  static const Color _woodFrame = Color(0xFF281813); // Moldura da AppBar
  static const Color _gold = Color(0xFFFFD700);

  // Cores de Pergaminho (Envelhecido)
  static const Color _paperEasy = Color(0xFFFFF59D); // Amarelo Palha
  static const Color _paperHard = Color(0xFFFFCCBC); // Avermelhado
  static const Color _paperLegendary = Color(0xFFE1BEE7); // Roxo Pálido
  static const Color _paperMedium = Color(0xFFF5F5F5); // Branco Sujo

  @override
  void initState() {
    super.initState();
    _loadBoard();
  }

  Future<void> _loadBoard() async {
    setState(() => _isLoading = true);
    // Simulação de delay se a API for muito rápida
    try {
      final items = await _apiService.fetchGuildBoard();
      if (mounted) {
        setState(() {
          _boardItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptContract(Map<String, dynamic> item) async {
    final provider = context.read<HunterProvider>();

    setState(() => _isLoading = true);

    final contractData = {
      'title': item['title'],
      'description': item['description'],
      'difficulty': item['difficulty'],
    };

    final bool success = await provider.createContract(contractData);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      setState(() {
        _boardItems.remove(item);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Missão "${item['title']}" aceita!'),
          backgroundColor: Colors.green,
        ),
      );

      if (_boardItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quadro limpo por hoje! Bom trabalho caçador.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Erro ao aceitar.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getPaperColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return _paperEasy;
      case 'hard':
        return _paperHard;
      case 'legendary':
        return _paperLegendary;
      default:
        return _paperMedium;
    }
  }

  Color _getInkColor(String difficulty) {
    if (difficulty.toLowerCase() == 'legendary') return Colors.purple[900]!;
    if (difficulty.toLowerCase() == 'hard') return Colors.red[900]!;
    return const Color(0xFF212121); // Preto Tinta
  }

  String _translateDiff(String diff) {
    switch (diff) {
      case 'easy':
        return 'FÁCIL';
      case 'medium':
        return 'NORMAL';
      case 'hard':
        return 'DIFÍCIL';
      case 'legendary':
        return 'ÉPICO';
      default:
        return diff;
    }
  }

  double _getRandomRotation(int index) {
    final random = Random(index);
    return (random.nextDouble() * 0.1) - 0.05;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _woodDark,
      appBar: AppBar(
        backgroundColor: _woodFrame,
        title: Text(
          "QUADRO DE AVISOS",
          style: GoogleFonts.pressStart2p(fontSize: 14, color: _gold),
        ),
        centerTitle: true,
        elevation: 10,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            color: const Color(0xFF1A1A1A),
            height: 4,
          ), // Sombra da moldura
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : _boardItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    FontAwesomeIcons.spider,
                    size: 50,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Nada por aqui...\nVolte amanhã, caçador.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.vt323(
                      fontSize: 24,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75, // Papel alongado (Portrait)
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _boardItems.length,
                itemBuilder: (context, index) {
                  final item = _boardItems[index];
                  return Transform.rotate(
                    angle: _getRandomRotation(index),
                    child: _buildPaperCard(item, index),
                  );
                },
              ),
            ),

      // Botão Flutuante (Pena e Tinteiro)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2C0404), // Vermelho Lacre
        shape: const BeveledRectangleBorder(
          side: BorderSide(color: _gold, width: 1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        icon: const Icon(
          FontAwesomeIcons.featherPointed,
          color: _gold,
          size: 18,
        ),
        label: Text(
          "ESCREVER PRÓPRIO",
          style: GoogleFonts.pressStart2p(fontSize: 8, color: _gold),
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const AddContractScreen()),
          );
          if (result == true && mounted) {
            Navigator.pop(context, true);
          }
        },
      ),
    );
  }

  Widget _buildPaperCard(Map<String, dynamic> item, int index) {
    final paperColor = _getPaperColor(item['difficulty']);
    final inkColor = _getInkColor(item['difficulty']);

    return GestureDetector(
      onTap: () => _showConfirmDialog(item),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        decoration: BoxDecoration(
          color: paperColor,
          boxShadow: [
            const BoxShadow(
              color: Colors.black54,
              blurRadius: 6,
              offset: Offset(3, 3),
            ),
          ],
          // Borda irregular simulada (apenas cantos)
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(2),
            bottomLeft: Radius.circular(2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // O "Prego" no topo
            Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF8D6E63), // Cor de ferro enferrujado
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black38),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 1,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Título (Estilo Impresso)
            Text(
              item['title'].toUpperCase(),
              style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: inkColor,
                height: 1.2,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),
            Divider(color: inkColor.withOpacity(0.3), thickness: 1),

            // Descrição (Estilo Manuscrito/Máquina)
            Expanded(
              child: Text(
                item['description'],
                style: GoogleFonts.vt323(
                  fontSize: 18,
                  color: Colors.black87,
                  height: 1.1,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 6,
              ),
            ),

            // Rodapé: Selo de Dificuldade
            Align(
              alignment: Alignment.bottomRight,
              child: Transform.rotate(
                angle: -0.2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: inkColor, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _translateDiff(item['difficulty']),
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7,
                      color: inkColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A), // Fundo pedra escura
        shape: const BeveledRectangleBorder(
          side: BorderSide(color: Colors.white38),
        ),
        title: Row(
          children: [
            const Icon(FontAwesomeIcons.scroll, color: _gold, size: 18),
            const SizedBox(width: 10),
            Text(
              "ACEITAR?",
              style: GoogleFonts.pressStart2p(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'],
                style: GoogleFonts.vt323(fontSize: 22, color: _gold),
              ),
              const SizedBox(height: 10),
              Text(
                item['description'],
                style: GoogleFonts.vt323(fontSize: 18, color: Colors.white70),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(
              "IGNORAR",
              style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              shape: const BeveledRectangleBorder(),
            ),
            onPressed: () {
              Navigator.pop(c);
              _acceptContract(item);
            },
            child: Text(
              "PEGAR MISSÃO",
              style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
