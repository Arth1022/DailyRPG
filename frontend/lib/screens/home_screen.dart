import 'package:dailyrpg/screens/guild_board_screen.dart'; // Verifique se o nome do arquivo é este (maiusculas/minusculas)
import 'package:dailyrpg/screens/ranking_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../widgets/contract_list.dart';
import '../widgets/hunter_header.dart';

import '../screens/add_contract_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/craft_screen.dart';
import '../screens/arena_screen.dart';
import '../screens/battle_screen.dart';

import '../providers/hunter_provider.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _refreshAllData() {
    if (mounted) {
      context.read<HunterProvider>().loadInitialData();
    }
  }

  Future<bool> _showBattleConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 40, 40, 40),
              shape: const BeveledRectangleBorder(
                side: BorderSide(color: Colors.white, width: 2),
              ),
              title: Text(
                'ENTRAR NO CAMPO DE BATALHA?',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 12,
                  color: Colors.redAccent,
                ),
              ),
              content: Text(
                'Você tem certeza que deseja iniciar o combate?',
                textAlign: TextAlign.center,
                style: GoogleFonts.pixelifySans(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'NÃO',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'SIM, LUTAR!',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _navigateToAddContract(BuildContext context) async {
    // Agora vai para o Quadro da Guilda em vez do formulário manual direto
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GuildBoardScreen()),
    );
    if (result == true && mounted) {
      _refreshAllData();
    }
  }

  Future<void> _navigateToShop(BuildContext context) async {
    final hunter = context.read<HunterProvider>().hunter;
    if (hunter == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShopScreen()),
    );

    if (result == true && mounted) {
      _refreshAllData();
    }
  }

  Future<void> _navigateToArena(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ArenaScreen()),
    );
  }

  Future<void> _navigateToCrafting(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CraftingScreen()),
    );

    if (result == true && mounted) {
      _refreshAllData();
    }
  }

  Future<void> _navigateToBattle(BuildContext context) async {
    // 1. Tenta iniciar a batalha no servidor
    final success = await context.read<HunterProvider>().startPvPBattle();

    if (success && context.mounted) {
      // 2. Se sucesso, vai para a tela de luta
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BattleScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao encontrar oponente! Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToRanking(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RankingScreen()),
    );

    if (result == true && mounted) {
      _refreshAllData();
    }
  }

  void _onNavBarTapped(int index) async {
    switch (index) {
      case 0:
        _refreshAllData();
        break;
      case 1:
        _navigateToShop(context);
        break;
      case 2:
        _navigateToArena(context);
        break;
      case 3:
        final bool confirm = await _showBattleConfirmation();
        if (confirm && mounted) {
          _navigateToBattle(context);
        }
        break;
      case 4:
        _navigateToCrafting(context);
      case 5:
        _navigateToRanking(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // CORES E ESTILOS PIXEL
    const darkBackgroundColor = Color.fromARGB(255, 30, 30, 30);
    const primaryPixelColor = Color.fromARGB(255, 77, 167, 209);
    const appBarColor = Color.fromARGB(255, 40, 40, 40);
    const navBarColor = Color.fromARGB(255, 40, 40, 40);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBackgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: appBarColor,
          titleTextStyle: GoogleFonts.pressStart2p(
            fontSize: 16,
            color: Colors.white,
          ),
          centerTitle: true,
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: primaryPixelColor,
          onPrimary: Colors.black,
          surface: navBarColor,
          onSurface: Colors.white,
          background: darkBackgroundColor,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("DAILY RPG"),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              color: appBarColor,
              onSelected: (value) {
                if (value == 'about') {
                  // Ação "Sobre"
                } else if (value == 'logout') {
                  context.read<HunterProvider>().logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'about',
                  child: Text(
                    'Sobre',
                    style: GoogleFonts.pixelifySans(color: Colors.white),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text(
                    'Sair',
                    style: GoogleFonts.pixelifySans(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),

        // --- FAB PIXELADO ---
        floatingActionButton: Container(
          decoration: BoxDecoration(
            color: primaryPixelColor,
            border: Border.all(
              color: const Color.fromARGB(255, 30, 100, 130),
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 120, 200, 240),
                offset: Offset(-2, -2),
                blurRadius: 0,
              ),
              BoxShadow(
                color: Color.fromARGB(255, 30, 100, 130),
                offset: Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => _navigateToAddContract(context),
            tooltip: 'Novo Contrato',
            backgroundColor: const Color.fromARGB(255, 29, 29, 29),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: const Icon(FontAwesomeIcons.plus, size: 20),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        // --- BARRA DE NAVEGAÇÃO ---
        bottomNavigationBar: BottomNavigationBar(
          onTap: _onNavBarTapped,
          currentIndex: 0, // Mantém fixo no 0 pois é a Home
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryPixelColor,
          unselectedItemColor: Colors.grey[600],
          backgroundColor: navBarColor,
          selectedLabelStyle: GoogleFonts.pressStart2p(fontSize: 8),
          unselectedLabelStyle: GoogleFonts.pressStart2p(fontSize: 8),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'INÍCIO',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket_outlined),
              activeIcon: Icon(Icons.shopping_basket),
              label: 'LOJA',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.security_outlined),
              activeIcon: Icon(Icons.security),
              label: 'ARENA',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.dungeon),
              activeIcon: Icon(FontAwesomeIcons.dungeon),
              label: 'BATALHA',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fireplace_outlined),
              activeIcon: Icon(Icons.fireplace),
              label: 'FORJA',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.trophy),
              activeIcon: Icon(FontAwesomeIcons.trophy),
              label: 'RANK',
            ),
          ],
        ),

        // --- CORPO DA TELA ---
        body: Consumer<HunterProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.hunter == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.hunter == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Erro ao carregar dados: ${provider.errorMessage}',
                    style: GoogleFonts.pixelifySans(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final hunter = provider.hunter!;
            final bool hasStreak = hunter.currentStreak > 0;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    HunterHeader(hunter: hunter),

                    const SizedBox(height: 12),

                    // --- BARRA DE STREAK ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252525),
                        border: Border.all(
                          color: hasStreak ? Colors.orange : Colors.grey[700]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: hasStreak
                            ? [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.fire,
                            color: hasStreak
                                ? Colors.orangeAccent
                                : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "COMBO DIÁRIO: ${hunter.currentStreak} ${hunter.currentStreak == 1 ? 'DIA' : 'DIAS'}",
                            style: GoogleFonts.pressStart2p(
                              fontSize: 10,
                              color: hasStreak ? Colors.orange : Colors.grey,
                            ),
                          ),
                          if (hasStreak) ...[
                            const SizedBox(width: 8),
                            Text(
                              "(BÔNUS ATIVO!)",
                              style: GoogleFonts.pixelifySans(
                                fontSize: 10,
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // -----------------------
                    const SizedBox(height: 24),

                    Text(
                      "SEUS CONTRATOS",
                      style: GoogleFonts.pressStart2p(
                        fontSize: 12,
                        color: primaryPixelColor,
                      ),
                    ),
                    const Divider(height: 20, color: Colors.white12),

                    const ContractList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
