import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Mantido
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
    context.read<HunterProvider>().loadInitialData();
  }

  Future<void> _navigateToAddContract(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddContractScreen()),
    );
    if (result == true) {
      _refreshAllData();
    }
  }

  Future<void> _navigateToShop(BuildContext context) async {
    final hunter = context.read<HunterProvider>().hunter;
    if (hunter == null) return;

    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ShopScreen()));

    if (result == true) {
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

    if (result == true) {
      _refreshAllData();
    }
  }

  void _onNavBarTapped(int index) {
    switch (index) {
      case 0:
        _navigateToShop(context);
        break;
      case 1:
        _navigateToArena(context);
        break;
      case 2:
        _navigateToCrafting(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily RPG"),
        actions: [
          // NOVO: Menu Popup (três pontos)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert), // Ícone de três pontos
            onSelected: (value) {
              // Lógica para lidar com a seleção do menu
              if (value == 'settings') {
                print('Configurações selecionadas');
                // Ex: Navigator.push(context, MaterialPageRoute(builder: (c) => SettingsScreen()));
              } else if (value == 'about') {
                print('Sobre selecionado');
                // Ex: showAboutDialog(context: context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Configurações'),
              ),
              const PopupMenuItem<String>(
                value: 'about',
                child: Text('Sobre'),
              ),
            ],
          ),

          // Botão de Logout (MANTIDO)
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
        backgroundColor: Colors.blueGrey,
        elevation: 0.0,
        child: const Icon(FontAwesomeIcons.plus),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onNavBarTapped,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.grey[700],
        unselectedItemColor: Colors.grey[700],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket_outlined),
            label: 'Loja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security_outlined),
            label: 'Arena',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fireplace_outlined),
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
              child: Text(
                'Erro ao carregar dados: ${provider.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final hunter = provider.hunter!;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  HunterHeader(hunter: hunter),
                  const SizedBox(height: 20),
                  ContractList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}