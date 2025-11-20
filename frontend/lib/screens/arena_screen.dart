import 'package:dailyrpg/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/widgets/boss_status_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:akar_icons_flutter/akar_icons_flutter.dart';

class ArenaScreen extends StatelessWidget {
  const ArenaScreen({super.key});

  // --- PALETA "DUNGEON & BLOOD" ---
  static const Color _bgDark = Color(0xFF050505); // Escuridão total
  static const Color _stoneDark = Color(0xFF1C1C1C); // Pedra escura
  static const Color _stoneLight = Color(0xFF333333); // Pedra iluminada
  static const Color _bloodRed = Color(0xFF8a0b0b); // Vermelho sangue seco
  static const Color _brightRed = Color(0xFFFF1744); // Vermelho alerta
  static const Color _ironGrey = Color(0xFF546E7A); // Ferro enferrujado
  static const Color _gold = Color(0xFFFFD700);

  // Estilos de Texto
  TextStyle get _rpgHeader =>
      GoogleFonts.pressStart2p(fontSize: 16, color: Colors.white);
  TextStyle get _rpgSubHeader =>
      GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white54);
  TextStyle get _rpgBody =>
      GoogleFonts.pixelifySans(fontSize: 14, color: Colors.white70);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _stoneDark,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FontAwesomeIcons.skull, color: Colors.white38, size: 16),
            const SizedBox(width: 12),
            Text("CÂMARA DO CHEFE", style: _rpgHeader),
            const SizedBox(width: 12),
            const Icon(FontAwesomeIcons.skull, color: Colors.white38, size: 16),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_stoneDark, _bloodRed, _stoneDark],
              ),
            ),
          ),
        ),
      ),
      body: Consumer<HunterProvider>(
        builder: (context, provider, child) {
          final bossStatus = provider.bossStatus;

          if (bossStatus == null) {
            return const Center(
              child: CircularProgressIndicator(color: _bloodRed),
            );
          }

          return Column(
            children: [
              // 1. MOLDURA DO CHEFE (Estilo Portão de Masmorra)
              Expanded(
                flex: 6,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Fundo/Imagem do Boss
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: _stoneLight, width: 4),
                        borderRadius: BorderRadius.circular(4),
                        // --- ALTERAÇÃO: SOMBRA REMOVIDA ---
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: _bloodRed.withOpacity(0.2),
                        //     blurRadius: 30,
                        //     spreadRadius: 5,
                        //   )
                        // ],
                        // ----------------------------------
                        image: const DecorationImage(
                          image: AssetImage('assets/images/boss.gif'),
                          fit: BoxFit.cover,
                          opacity: 0.8,
                        ),
                      ),
                      child: Container(
                        // Vinheta escura interna
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            radius: 1.2,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.9),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Informações Sobrepostas (HUD flutuante)
                    Positioned(
                      top: 30,
                      left: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _bloodRed,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              "PERIGO IMINENTE",
                              style: _rpgSubHeader.copyWith(
                                fontSize: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "O DESTRUIDOR",
                            style: _rpgHeader.copyWith(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Barra de Vida (Integrada na parte inferior da moldura)
                    Positioned(
                      bottom: 25,
                      left: 25,
                      right: 25,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "HP",
                                style: _rpgSubHeader.copyWith(
                                  color: _brightRed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: _ironGrey, width: 2),
                            ),
                            child: const BossStatusBar(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. PAINEL DE PEDRA (Stats e Ações)
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: _stoneDark,
                    border: Border(top: BorderSide(color: _ironGrey, width: 4)),
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/stone_texture.png',
                      ), // Opcional se tiver textura
                      fit: BoxFit.cover,
                      opacity: 0.05,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.crown,
                            color: _gold,
                            size: 14,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "ESPÓLIOS DA VITÓRIA",
                            style: _rpgSubHeader.copyWith(color: _gold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Grid de Recompensas (Cards de Pedra)
                      Row(
                        children: [
                          Expanded(
                            child: _buildStoneCard(
                              label: "OURO",
                              value: "+${bossStatus.rewardCoin}",
                              icon: FontAwesomeIcons.coins,
                              accent: _gold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStoneCard(
                              label: "EXP",
                              value: "+${bossStatus.rewardXp}",
                              icon: FontAwesomeIcons.solidStar,
                              accent: Colors.greenAccent,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // 3. BOTÃO DE AÇÃO (Estilo Portão/Laje)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF2b0505,
                            ), // Vermelho muito escuro
                            foregroundColor: Colors.redAccent,
                            elevation: 5,
                            shape: const BeveledRectangleBorder(
                              side: BorderSide(color: _bloodRed, width: 1),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(FontAwesomeIcons.scroll, size: 20),
                              const SizedBox(width: 12),
                              Text("REALIZAR CONTRATOS", style: _rpgSubHeader),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "ENFRAQUEÇA O CHEFE COMPLETANDO MISSÕES",
                          style: _rpgBody.copyWith(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStoneCard({
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: accent.withOpacity(0.5)),
            ),
            child: Center(child: Icon(icon, color: accent, size: 18)),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: _rpgSubHeader.copyWith(
                  fontSize: 8,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: _rpgHeader.copyWith(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
