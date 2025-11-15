import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/models/item.dart';
import 'package:dailyrpg/models/enums.dart';


class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {

  IconData _getIconForItem(Item item) {
    switch (item.type) {
      case ItemType.Consumable:
        return Icons.local_drink;
      case ItemType.Equipment:
        if (item.equipType == EquipmentType.Weapon) {
          return AkarIcons.sword;
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

  String _getButtonText(Item item) {
    switch (item.type) {
      case ItemType.Consumable:
        return "Usar";
      case ItemType.Equipment:
        return "Equipar";
      case ItemType.Material:
        return "Material";
      default:
        return "Ver";
    }
  }

  void _useItem(BuildContext context, int slotId) async {
    final provider = context.read<HunterProvider>();
    
    try {
      await provider.useItem(slotId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item usado/equipado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao usar o item: ${provider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _spendPoint(BuildContext context, String skillName) async {
    final provider = context.read<HunterProvider>();
    try {
      await provider.spendAttributePoint(skillName);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Você aumentou $skillName!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao gastar ponto: ${provider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatRow(
    BuildContext context,
    HunterProvider provider,
    String label, 
    String skillName, 
    int statValue, 
    IconData icon, 
    Color color
  ) {
    final bool canSpend = provider.hunter!.attributePoints > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Text(statValue.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          
          if (canSpend)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: provider.isLoading 
                ? null 
                : () => _spendPoint(context, skillName),
            )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventário & Atributos'),
      ),
      body: Consumer<HunterProvider>(
        builder: (context, provider, child) {
          final hunter = provider.hunter;
          final inventory = provider.inventory;
          final isLoading = provider.isLoading;

          if (hunter == null) {
            return const Center(child: Text('Erro: Caçador não encontrado.'));
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Atributos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (hunter.attributePoints > 0)
                          Text(
                            "${hunter.attributePoints} Pontos Restantes",
                            style: TextStyle(fontSize: 16, color: Colors.green[400], fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                    const Divider(height: 20),

                    _buildStatRow(context, provider, 'Força', 'strength', hunter.strength, Icons.gavel, Colors.red[400]!),
                    _buildStatRow(context, provider, 'Destreza', 'dexterity', hunter.dexterity, Icons.flash_on, Colors.yellow[400]!),
                    _buildStatRow(context, provider, 'Inteligência', 'intelligence', hunter.intelligence,Icons.book, const Color.fromARGB(255, 81, 245, 66)!),
                    _buildStatRow(context, provider, 'Constituição', 'constitution', hunter.constitution, Icons.favorite, Colors.blue[400]!),
                    _buildStatRow(context, provider, 'Vigor', 'endurance', hunter.endurance, Icons.shield, Colors.grey[400]!),
                    
                    const Divider(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Dano: ${hunter.damage}', style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                        Text('HP: ${hunter.currentHp}/${hunter.maxHp}', style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                        Text('Defesa: ${hunter.defense}', style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
    

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mochila', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: inventory.length,
                  itemBuilder: (context, index) {
                    final slot = inventory[index];
                    final item = slot.item;
                    final bool canBeUsed = item.type != ItemType.Material;

                    return Card(
                      color: Color.fromARGB(92, 204, 98, 12),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                       
                        leading: Icon(_getIconForItem(item), size: 40, color: const Color.fromARGB(255, 255, 255, 255)),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Quantidade: ${slot.quantity}\n${item.description}'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 88, 88, 88),
                            foregroundColor: const Color.fromARGB(255, 255, 255, 255)
                          ),
                          onPressed: (isLoading || !canBeUsed)
                            ? null
                            : () => _useItem(context, slot.id),
                          child: Text(_getButtonText(item)),
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
    );
  }
}