import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/hunter_user.dart';

//widgets
import 'widgets/xp_bar.dart';
import 'widgets/health_bar.dart';

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

            return Stack(
              fit: StackFit.expand,
              children: [
                
                Image.asset(
                  'assets/images/fundo.png',
                  fit: BoxFit.fitHeight,
                ),
            
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //Bloco 1
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [


                              Text(

                                'NÍVEL: ${hunter.level}',
                                style: const TextStyle(
                                  fontSize: 20, 
                                  color: Colors.black, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),

                              const SizedBox(height: 10,),

                              XpProgressBar(
                                currentXp: hunter.currentXp,
                                nextLevelXp: hunter.nextLevelXp,
                              )
                            ],
                          ),
                        ),

                        const SizedBox(width: 20,),

                        //Bloco 2
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.favorite_border_outlined,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 5,),
                                  LifeBar(currentHp: hunter.currentHp, maxHp: hunter.maxHp),
                                ],
                              ),                   
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Nenhum dado para mostrar.'));
        },
      ),
    );
  }
}