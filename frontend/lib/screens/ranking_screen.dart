import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dailyrpg/services/api_service.dart';
import 'package:dailyrpg/models/ranking.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final ApiService _apiService = ApiService();
  List<RankingProfile> _ranking = [];
  bool _isLoading = true;

  // --- Paleta "Golden Hall" (Ajustada) ---
  // Fundo mais claro (Tom de Pedra/Madeira escura, não preto)
  static const Color _bgDark = Color(0xFF2E2A26);
  static const Color _cardBg = Color(
    0xFF1A1A1A,
  ); // Cards permanecem escuros para contraste

  // Metais (Cores Sólidas)
  static const Color _gold = Color(0xFFFFD700);
  static const Color _goldDark = Color(0xFFB8860B);
  static const Color _silver = Color(0xFFE0E0E0);
  static const Color _bronze = Color(0xFFCD7F32);
  static const Color _iron = Color(0xFF607D8B);

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    try {
      final list = await _apiService.fetchRanking();
      if (mounted) {
        setState(() {
          _ranking = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  TextStyle get _pixelTitle =>
      GoogleFonts.pressStart2p(fontSize: 14, color: _gold);
  TextStyle get _pixelText =>
      GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white);
  TextStyle get _pixelLabel =>
      GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white54);

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return _gold;
      case 1:
        return _silver;
      case 2:
        return _bronze;
      default:
        return _iron;
    }
  }

  IconData _getRankIcon(int index) {
    switch (index) {
      case 0:
        return FontAwesomeIcons.crown;
      case 1:
        return FontAwesomeIcons.medal;
      case 2:
        return FontAwesomeIcons.medal;
      default:
        return FontAwesomeIcons.userShield;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: const Color(
          0xFF1F1B16,
        ), // Um tom levemente mais escuro que o fundo
        title: Text("HALL DA FAMA", style: _pixelTitle),
        centerTitle: true,
        iconTheme: const IconThemeData(color: _gold),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(color: _goldDark, height: 4),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : Column(
              children: [
                // --- 1. ÁREA DO TROFÉU (HEADER) ---
                _buildTrophyHeader(),

                // --- 2. LISTA DE RANKING ---
                Expanded(
                  child: _ranking.isEmpty
                      ? Center(
                          child: Text(
                            "O Hall está vazio.",
                            style: _pixelText.copyWith(color: Colors.white38),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          itemCount: _ranking.length,
                          separatorBuilder: (ctx, i) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildRankCard(index, _ranking[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // Widget do Troféu/Destaque
  Widget _buildTrophyHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: _bgDark,
        // Apenas uma linha divisória sólida
        border: Border(bottom: BorderSide(color: _goldDark, width: 2)),
      ),
      child: Column(
        children: [
          // Espaço para a Imagem do Troféu (Sem sombra/brilho)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(
                0xFF151515,
              ), // Fundo escuro sólido para o ícone
              shape: BoxShape.circle,
              border: Border.all(color: _gold, width: 3),
              // Sombra removida aqui
            ),
            child: const Center(
              child: Icon(FontAwesomeIcons.trophy, color: _gold, size: 40),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "RANKING GLOBAL",
            style: _pixelLabel.copyWith(
              color: _gold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankCard(int index, RankingProfile profile) {
    final int rank = index + 1;
    final Color rankColor = _getRankColor(index);
    final bool isTop3 = index < 3;

    final double cardHeight = isTop3 ? 75 : 60;

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: _cardBg,
        // Borda Sólida
        border: isTop3
            ? Border.all(color: rankColor, width: 2)
            : Border(
                left: BorderSide(color: _iron, width: 4),
                bottom: const BorderSide(color: Colors.black, width: 2),
                top: const BorderSide(color: Colors.white10, width: 1),
                right: const BorderSide(color: Colors.white10, width: 1),
              ),
        // Sombra dura apenas para dar volume ao card (estilo bloco)
        boxShadow: const [
          BoxShadow(color: Colors.black45, offset: Offset(0, 4), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          // 1. POSIÇÃO (Badge)
          Container(
            width: 60,
            height: double.infinity,
            color: Colors.black26,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getRankIcon(index),
                  color: rankColor,
                  size: isTop3 ? 20 : 16,
                ),
                const SizedBox(height: 4),
                Text(
                  "#$rank",
                  style: _pixelText.copyWith(
                    fontSize: isTop3 ? 12 : 10,
                    color: rankColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 2. NOME
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.hunterName.toUpperCase(),
                    style: _pixelTitle.copyWith(
                      fontSize: isTop3 ? 12 : 10,
                      color: isTop3 ? _gold : Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isTop3 && index == 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      "LÍDER DA GUILDA",
                      style: _pixelLabel.copyWith(
                        fontSize: 7,
                        color: _goldDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 3. NÍVEL E INFO
          Container(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "NÍVEL",
                  style: _pixelLabel.copyWith(color: Colors.white38),
                ),
                const SizedBox(height: 4),
                Text(
                  "${profile.level}",
                  style: _pixelTitle.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
