import 'package:dailyrpg/screens/add_contract_screen.dart';
import 'package:dailyrpg/screens/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'services/api_service.dart';
import 'models/hunter_user.dart';
import 'screens/login_screen.dart';

//widgets
import 'widgets/contract_list.dart';
import 'widgets/hunter_header.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily RPG',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _refreshHunterStats() {
    setState(() {
      _hunterStatsFuture = _apiService.fetchHunterStats();
    });
  }

  final _contractListKey = GlobalKey<ContractListState>();

  late Future<HunterUser> _hunterStatsFuture;
  final ApiService _apiService = ApiService();
  late HunterUser _cachedHunter;

  @override
  void initState() {
    super.initState();
    _hunterStatsFuture = _apiService.fetchHunterStats();
  }

  Future<void> _navigateToAddContract(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddContractScreen()),
    );
    if (result == true) {
      _refreshHunterStats();
      _contractListKey.currentState?.refreshContracts();
    }
  }

  void _navigateToShop(BuildContext context) async {
    final result = await Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => ShopScreen(hunter: _cachedHunter,onPurchaseSuccess: _refreshHunterStats))
    );
    if (result == true) {
      _refreshHunterStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: FutureBuilder<HunterUser>(
        future: _hunterStatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar dados: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.hasData) {
            _cachedHunter = snapshot.data!;
            final hunter = snapshot.data!;

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
                      onDataChanged: _refreshHunterStats,
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('Nenhum dado para mostrar.'));
        },
      ),
    );
  }
}