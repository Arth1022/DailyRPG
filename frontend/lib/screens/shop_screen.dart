import 'package:flutter/material.dart';
import 'package:dailyrpg/widgets/hunter_header.dart';

class _ShopItem {
  final String id;
  final String name;
  final String description;
  final int cost;
  final IconData icon;

  _ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.icon,
  });
}


class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<_ShopItem> _shopItems = [
    _ShopItem(
      id: 'p_001',
      name: 'Poção de Vida Pequena',
      description: 'Restaura 20 HP.',
      cost: 50,
      icon: Icons.local_drink_sharp, 
    ),
    _ShopItem(
      id: 'p_002',
      name: 'Poção de Vida Média',
      description: 'Restaura 50 HP.',
      cost: 120,
      icon: Icons.local_drink_sharp,
    ),
    _ShopItem(
      id: 'e_001',
      name: 'Adaga de Prata',
      description: 'Eficaz contra monstros (Dano +5).',
      cost: 300,
      icon: Icons.gpp_good_sharp, 
    ),
    _ShopItem(
      id: 'b_001',
      name: 'Bomba "Samum"',
      description: 'Cega oponentes numa pequena área.',
      cost: 250,
      icon: Icons.whatshot, 
    ),
  ];
  void _buyItem(_ShopItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Você comprou: ${item.name}!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja do Caçador'),
      ),
      body: ListView.builder(
        itemCount: _shopItems.length,

        itemBuilder: (context, index) {

          final item = _shopItems[index];


          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(item.icon, size: 40, color: Colors.purple[200]),
              
              title: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              
              subtitle: Text('${item.description}\nPreço: ${item.cost} Moedas'),
              
              trailing: ElevatedButton(
                onPressed: () => _buyItem(item),
                child: const Text('Comprar'),
              ),
            ),
          );
        },
      ),
    );
  }
}