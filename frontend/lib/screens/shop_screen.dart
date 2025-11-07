import 'package:flutter/material.dart';
import 'package:dailyrpg/models/hunter_user.dart';
import '../services/api_service.dart';

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
  final HunterUser hunter;
  final VoidCallback onPurchaseSuccess;

  const ShopScreen({
    super.key,
    required this.hunter,
    required this.onPurchaseSuccess,
    });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late HunterUser _currentHunter;

  @override
  void initState(){
    super.initState();
    _currentHunter = widget.hunter;
  }

  final List<_ShopItem> _shopItems = [
    _ShopItem(
      id: 'heal', // ver id que esta na API
      name: 'Poção de Vida Pequena',
      description: 'Restaura 20 HP.',
      cost: 50,
      icon: Icons.favorite_border,
    ),
    _ShopItem(
      id: 'xpdoubler', //Ver id que esta na api
      name: 'Poção de XP',
      description: 'Dobra seu XP de um contrato.',
      cost: 120,
      icon: Icons.flash_on,
    ),
  ];

  void _buyItem(_ShopItem item) async {
    setState(() {
      _isLoading = true;
    });
    try{
      await _apiService.buyItem(item.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Você comprou: ${item.name}!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onPurchaseSuccess();
      final updatedhunter = await _apiService.fetchHunterStats();
      setState(() {
        _currentHunter = updatedhunter;
      });

    }catch (e){
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao comprar: ${item.name}!'),
          backgroundColor: Colors.red,
        ),
      );
    }finally{
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Loja do Aventureiro',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 55,),
                Icon(
                  Icons.monetization_on,
                  color: Colors.amber,),
                Text(
                  '${_currentHunter.currentCoins}G',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.yellow,
                  ),
                ),
                SizedBox(width: 40,)
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _shopItems.length,
              itemBuilder: (context, index) {
                final item = _shopItems[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(item.icon, size: 40, color: Colors.purple[200]),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle:
                        Text('${item.description}\nPreço: ${item.cost} Moedas'),
                    trailing: ElevatedButton(
                      onPressed: () => _buyItem(item),
                      child: const Text('Comprar'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}