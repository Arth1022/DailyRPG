// lib/main.dart

import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/hunter_user.dart';

//widgets
import 'widgets/xp_bar.dart';
import 'widgets/health_bar.dart';
import 'widgets/contract_list.dart';

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
      home: const HomeScreen(),
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
  
  late Future<HunterUser> _hunterStatsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _hunterStatsFuture = _apiService.fetchHunterStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            
            final hunter = snapshot.data!;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    const SizedBox(height: 60.0), 

                    Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Color(0xFFE53935),
                          size: 25.0,
                        ),
                        const SizedBox(width: 10.0), 

                        Expanded(
                          child: LifeBar(
                            currentHp: hunter.currentHp, 
                            maxHp: hunter.maxHp
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20.0),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'CONTRACT PROGRESS',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 207, 207, 207),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 2.0,
                                  offset: Offset(1.0,1.0)
                                )
                              ]
                            ),
                          ),
                          SizedBox(height: 7,),

                          Row(
                            children: [
                              const Icon(
                                Icons.auto_stories,
                                color: Color(0xFFA67C52),
                                size: 25.0,
                              ),
                              const SizedBox(width: 10.0),

                              Expanded(
                                child: XpProgressBar(
                                  currentXp: hunter.currentXp,
                                  nextLevelXp: hunter.nextLevelXp,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Text(
                            'LVL: ${hunter.level} (${hunter.currentXp}/${hunter.nextLevelXp})',
                            style: const TextStyle(
                              fontSize: 16, 
                              color: Color.fromARGB(255, 207, 207, 207), 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 20.0),

                    // --- A LISTA DE TAREFAS ---
                    const ContractList(),

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