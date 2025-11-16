import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:akar_icons_flutter/akar_icons_flutter.dart';

import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/models/item.dart';

import 'package:dailyrpg/models/enums.dart';


enum ShopFilter { todos, equipamentos, itens }

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool _purchaseMade = false;

  Set<ShopFilter> _currentFilter = {ShopFilter.todos};

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
        return FontAwesomeIcons.flask;
      case ItemType.Equipment:
        if (item.equipType == EquipmentType.Weapon) {
          return AkarIcons.sword;
        } else if (item.equipType == EquipmentType.Armor) {
          return FontAwesomeIcons.shield;
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

            final ShopFilter selectedFilter = _currentFilter.first;
            final List<Item> filteredItems; 

            if (selectedFilter == ShopFilter.equipamentos) {
      
              filteredItems = shopItems.where((item) {
                return item.type == ItemType.Equipment;
              }).toList();
            } else if (selectedFilter == ShopFilter.itens) {
              filteredItems = shopItems.where((item) {
                return item.type == ItemType.Consumable ||
                    item.type == ItemType.Material;
              }).toList();
            } else {
          
              filteredItems = shopItems;
            }

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10),
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
                        FontAwesomeIcons.coins,
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
               
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SegmentedButton<ShopFilter>(
                    segments: const <ButtonSegment<ShopFilter>>[
                      ButtonSegment(
                        value: ShopFilter.todos,
                        label: Text('Todos'),
                        icon: Icon(Icons.apps),
                      ),
                      ButtonSegment(
                        value: ShopFilter.equipamentos,
                        label: Text('Equip.'), 
                        icon: Icon(AkarIcons.sword),
                      ),
                      ButtonSegment(
                        value: ShopFilter.itens,
                        label: Text('Itens'), 
                        icon: Icon(FontAwesomeIcons.flask),
                      ),
                    ],
              
                    selected: _currentFilter,
                    onSelectionChanged: (Set<ShopFilter> newSelection) {
                      setState(() {
            
                        _currentFilter = newSelection;
                      });
                    },
                  
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white70,
                      selectedForegroundColor: Colors.white,
                      selectedBackgroundColor:
                          const Color.fromARGB(255, 77, 167, 209),
                    ),
                  ),
                ),
                 const Divider(height: 20),
                Expanded(
                  child: ListView.builder(
          
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
           
                      final item = filteredItems[index];
                      final bool canAfford =
                          hunter.currentCoins >= item.shopPrice;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Icon(_getIconForItem(item),
                              size: 40,
                              color: const Color.fromARGB(255, 77, 167, 209)),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              '${item.description}\nPreço: ${item.shopPrice} Moedas'),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 29, 29, 29),
                                foregroundColor: Colors.white),
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