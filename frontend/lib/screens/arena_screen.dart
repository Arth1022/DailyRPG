import 'package:flutter/material.dart';
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
      body: SingleChildScrollView( 
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 250, // Altura fixa para a imagem
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                // image: DecorationImage(
                //   image: AssetImage('assets/images/boss_image.png'),
                //   fit: BoxFit.cover,
                // ),
              ),
              child: const Center(
                child: Text(
                  '(Local da Imagem do Chefe)',
                  style: TextStyle(color: Colors.grey),
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
                  
                  // (Aqui pode ir uma lista de recompensas
                  //  ou itens que o chefe "dropa")
                  Card(
                    color: Colors.grey[850],
                    child: ListTile(
                      leading: Icon(Icons.shield, color: Colors.blue[300]),
                      title: Text('Armadura do Dragão (Placeholder)'),
                      subtitle: Text('Defesa +20'),
                    ),
                  ),
                  Card(
                    color: Colors.grey[850],
                    child: ListTile(
                      leading: Icon(Icons.gavel, color: Colors.red[300]),
                      title: Text('Espada do Dragão (Placeholder)'),
                      subtitle: Text('Dano +15'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}