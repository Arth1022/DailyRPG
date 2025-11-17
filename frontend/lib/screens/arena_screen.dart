import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/widgets/boss_status_bar.dart';
import 'package:google_fonts/google_fonts.dart'; // Para fontes pixeladas
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Para ícones temáticos

class ArenaScreen extends StatelessWidget {
  const ArenaScreen({super.key});

  // --- Estilos de Tema ---
  static const darkBackground = Color(0xFF1A1A1A);
  static const darkCardColor = Color(0xff2a2a2a);
  static const pixelPrimaryColor = Color.fromARGB(255, 77, 167, 209);
  static const xpColor = Color.fromARGB(255, 85, 166, 82);
  static const goldColor = Colors.amber;
  static const bossRed = Color(0xFF8B0000); // Vermelho escuro para AppBar
  // ------------------------

  // Estilo para o texto do corpo
  TextStyle get _bodyTextStyle =>
      GoogleFonts.pixelifySans(fontSize: 14, color: Colors.white70);

  // Estilo para o título do AppBar e cabeçalhos
  TextStyle get _pixelTitleStyle =>
      GoogleFonts.pressStart2p(fontSize: 14, color: Colors.white);

  // Estilo de título secundário
  TextStyle get _sectionTitleStyle =>
      GoogleFonts.pressStart2p(fontSize: 10, color: pixelPrimaryColor);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: Text(
          'ARENA DO CHEFE',
          style: _pixelTitleStyle.copyWith(fontSize: 12),
        ),
        backgroundColor: bossRed,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<HunterProvider>(
        builder: (context, provider, child) {
          // Supondo que bossStatus é do tipo BossStatus e tem rewardCoin/rewardXp
          final bossStatus = provider.bossStatus;

          if (bossStatus == null) {
            return const Center(
              child: CircularProgressIndicator(color: bossRed),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Container da Imagem do Boss
                Container(
                  width: double.infinity,
                  height: 250,
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: darkCardColor,
                    borderRadius: BorderRadius
                        .zero, // Estilo Pixel Art (sem arredondamento)
                    border: Border.all(color: Colors.white30, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: bossRed.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/boss.gif'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Barra de Status do Boss (Mantida a BossStatusBar existente)
                const BossStatusBar(),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título da Seção
                      Text(
                        'RECOMPENSAS PELA DERROTA:',
                        style: _sectionTitleStyle.copyWith(
                          color: goldColor,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Card de Recompensa: Moedas
                      Card(
                        color: darkCardColor,
                        elevation: 4,
                        shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(color: goldColor, width: 1),
                        ),
                        child: ListTile(
                          leading: Icon(
                            FontAwesomeIcons.coins,
                            color: goldColor,
                          ),
                          title: Text(
                            'Moedas (Gold)',
                            style: _bodyTextStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            '${bossStatus.rewardCoin} G',
                            style: _bodyTextStyle.copyWith(
                              color: goldColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Card de Recompensa: Experiência
                      Card(
                        color: darkCardColor,
                        elevation: 4,
                        shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(color: xpColor, width: 1),
                        ),
                        child: ListTile(
                          leading: Icon(
                            FontAwesomeIcons.diamond,
                            color: xpColor,
                          ),
                          title: Text(
                            'Experiência',
                            style: _bodyTextStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            '${bossStatus.rewardXp} XP',
                            style: _bodyTextStyle.copyWith(
                              color: xpColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botão de Ataque (Exemplo)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Lógica de Ataque aqui
                    },
                    icon: const Icon(AkarIcons.sword, color: Colors.white),
                    label: Text(
                      'COMPLETE CONTRATOS PARA ATACAR',
                      style: _pixelTitleStyle.copyWith(fontSize: 10),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bossRed,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: const BeveledRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(color: Colors.white54, width: 2),
                      ),
                      elevation: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
