import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../widgets/contract_list.dart';
import '../widgets/hunter_header.dart';

import '../screens/add_contract_screen.dart';
import '../screens/shop_screen.dart';

import '../providers/hunter_provider.dart';
import '../models/hunter_user.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _contractListKey = GlobalKey<ContractListState>();

  void _refreshAllData() {
    context.read<HunterProvider>().loadInitialData();
    _contractListKey.currentState?.refreshContracts();
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
    if(hunter == null) return;

    final result = await Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => ShopScreen(
          hunter: hunter,
          onPurchaseSuccess: _refreshAllData,
        ))
    );
    
    if (result == true) {
      _refreshAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily RPG"),
        actions: [
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
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        direction: SpeedDialDirection.up,
        backgroundColor: const Color.fromARGB(255, 43, 9, 194),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.shopping_basket_outlined),
            label: 'Loja',
            backgroundColor: Colors.purple,
            onTap: () => _navigateToShop(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.description),
            label: 'Novo Contrato',
            backgroundColor: Colors.green,
            onTap: () => _navigateToAddContract(context),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      
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
                  const SizedBox(height: 5,),
                  HunterHeader(hunter: hunter), 
                  const SizedBox(height: 20),
                  ContractList(
                    key: _contractListKey,
                    onDataChanged: _refreshAllData, 
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