import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/widgets/boss_status_bar.dart'; 

class ArenaScreen extends StatelessWidget {
  const ArenaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arena do Chefe'),
        backgroundColor: Colors.red[900], 
      ),
      body: Consumer<HunterProvider>(
        builder: (context, provider, child) {
          
          final bossStatus = provider.bossStatus;

          if (bossStatus == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView( 
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 250, 
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                    image: AssetImage('assets/images/boss.gif'),
                    fit: BoxFit.cover,
                    ),
                  ),
                ),

                const BossStatusBar(),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recompensas pela Derrota:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Card(
                        color: Colors.grey[850],
                        child: ListTile(
                          leading: Icon(Icons.monetization_on, color: Colors.amber[300]),
                          title: Text('Moedas'),
                          subtitle: Text('${bossStatus.rewardCoin} G'),
                        ),
                      ),
                      Card(
                        color: Colors.grey[850],
                        child: ListTile(
                          leading: Icon(Icons.auto_stories, color: Colors.blue[300]),
                          title: Text('Experiência'),
                          subtitle: Text('${bossStatus.rewardXp} XP'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}