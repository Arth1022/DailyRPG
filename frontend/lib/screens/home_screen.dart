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
        context, MaterialPageRoute(builder: (context) => const ShopScreen()));

    if (result == true && mounted) {
      _refreshAllData();
    }
  }

  Future<void> _navigateToArena(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ArenaScreen(),
      ),
    );
  }

  Future<void> _navigateToCrafting(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CraftingScreen(),
      ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Daily RPG",
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'settings') {
                print('Configurações selecionadas');
              } else if (value == 'about') {
                print('Sobre selecionado');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'about',
                child: Text('Sobre'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair (Logout)',
            onPressed: () {
              context.read<HunterProvider>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddContract(context),
        tooltip: 'Novo Contrato',
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4.0,
        child: const Icon(FontAwesomeIcons.plus),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onNavBarTapped,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: colorScheme.surface,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket_outlined),
            activeIcon: Icon(Icons.shopping_basket),
            label: 'Loja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security_outlined),
            activeIcon: Icon(Icons.security),
            label: 'Arena',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fireplace_outlined),
            activeIcon: Icon(Icons.fireplace),
            label: 'Forja',
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
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final hunter = provider.hunter!;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  HunterHeader(hunter: hunter),
                  const SizedBox(height: 24),
                  Text(
                    "Seus Contratos",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ContractList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}