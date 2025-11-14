import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/models/item.dart';
import 'package:dailyrpg/models/enums.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool _purchaseMade = false;

  void _buyItem(BuildContext context, Item item) async {
    final provider = context.read<HunterProvider>();

    try {
      await provider.buyItem(item.id);
      _purchaseMade = true;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Você comprou: ${item.name}!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao comprar: ${provider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  IconData _getIconForItem(Item item) {
    switch (item.type) {
      case ItemType.Consumable:
        return Icons.local_drink;
      case ItemType.Equipment:
        if (item.equipType == EquipmentType.Weapon) {
          return Icons.gavel;
        } else if (item.equipType == EquipmentType.Armor) {
          return Icons.shield;
        }
        return Icons.style;
      case ItemType.Material:
        return Icons.category;
      default:
        return Icons.question_mark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _purchaseMade);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Loja do Aventureiro'),
        ),
        body: Consumer<HunterProvider>(
          builder: (context, provider, child) {
            final hunter = provider.hunter;
            final shopItems = provider.shopItems;
            final isLoading = provider.isLoading;

            if (hunter == null) {
              return const Center(child: Text('Erro ao carregar o caçador.'));
            }

            return Column(
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
                      const Spacer(),
                      Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                      ),
                      Text(
                        ' ${hunter.currentCoins}G',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.yellow,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: shopItems.length,
                    itemBuilder: (context, index) {
                      final item = shopItems[index];
                      final bool canAfford = hunter.currentCoins >= item.shopPrice;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Icon(_getIconForItem(item), size: 40, color: Colors.purple[200]),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item.description}\nPreço: ${item.shopPrice} Moedas'
                          ),
                          trailing: ElevatedButton(
                            onPressed: (isLoading || !canAfford)
                              ? null
                              : () => _buyItem(context, item),
                            
                            child: Text(isLoading
                                ? '...'
                                : (canAfford ? 'Comprar' : 'Sem Ouro')),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}