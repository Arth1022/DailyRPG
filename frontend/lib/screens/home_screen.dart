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

  Future<void> _navigateToAddContract(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddContractScreen()),
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

  void _onNavBarTapped(int index) {
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
        _navigateToCrafting(context);
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
        // Adicionando um esquema de cores para manter o estilo dark
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
          title: const Text(
            "DAILY RPG", // Título em Caps lock para o estilo pressStart2p
          ),
          actions: [
            // Menu de Ações (PopupMenuButton)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              color: appBarColor, // Fundo escuro para o menu
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
        floatingActionButton: Container(
          // Container para a Borda Pixelada do FAB
          decoration: BoxDecoration(
            color: primaryPixelColor,
            border: Border.all(
              color: const Color.fromARGB(255, 30, 100, 130),
              width: 3,
            ),
            boxShadow: const [
              // Sombra superior/esquerda (Luz)
              BoxShadow(
                color: Color.fromARGB(255, 120, 200, 240),
                offset: Offset(-2, -2),
                blurRadius: 0,
                spreadRadius: 0,
              ),
              // Sombra inferior/direita (Sombra)
              BoxShadow(
                color: Color.fromARGB(255, 30, 100, 130),
                offset: Offset(2, 2),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => _navigateToAddContract(context),
            tooltip: 'Novo Contrato',
            backgroundColor: const Color.fromARGB(
              255,
              29,
              29,
              29,
            ), // Cor interna do botão escura
            foregroundColor: Colors.white,
            elevation: 0, // Remover elevação padrão
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide.none,
            ),
            child: const Icon(FontAwesomeIcons.plus),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: BottomNavigationBar(
          onTap: _onNavBarTapped,
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryPixelColor,
          unselectedItemColor: Colors.grey[600],
          backgroundColor: navBarColor,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'INÍCIO',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket_outlined),
              activeIcon: Icon(Icons.shopping_basket),
              label: 'LOJA',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.security_outlined),
              activeIcon: Icon(Icons.security),
              label: 'ARENA',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.fireplace_outlined),
              activeIcon: Icon(Icons.fireplace),
              label: 'FORJA',
            ),
          ],
        ),
        body: Consumer<HunterProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.hunter == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Erro ao carregar dados: ${provider.errorMessage}',
                    style: GoogleFonts.pixelifySans(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final hunter = provider.hunter!;

            // REMOÇÃO DO SafeArea e ajuste de Padding
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // HunterHeader (Assumimos que ele está estilizado)
                  HunterHeader(hunter: hunter),
                  const SizedBox(height: 24),
                  // Título da Seção (Pixelado)
                  Text(
                    "SEUS CONTRATOS",
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10, // Menor para encaixar
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Divider(height: 20, color: Colors.white12),
                  // Lista de Contratos (Já estilizada)
                  const ContractList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
