import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:dailyrpg/models/enums.dart'; 

import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/models/recipe.dart';
import 'package:dailyrpg/models/inventory_slot.dart';

enum CraftingFilter { todos, equipamentos, itens }

class CraftingScreen extends StatefulWidget {
  const CraftingScreen({super.key});

  @override
  State<CraftingScreen> createState() => _CraftingScreenState();
}

class _CraftingScreenState extends State<CraftingScreen> {
  bool _craftingAttempted = false;

  Set<CraftingFilter> _currentFilter = {CraftingFilter.todos};

  String _buildIngredientsList(Recipe recipe) {
    return recipe.ingredients.map((ing) {
      return '${ing.quantityRequired}x ${ing.material.name}';
    }).join(', ');
  }

  bool _canCraft(Recipe recipe, List<InventorySlot> inventory) {
    for (var req in recipe.ingredients) {
      bool found = false;
      for (var slot in inventory) {
        if (slot.item.id == req.material.id) {
          if (slot.quantity >= req.quantityRequired) {
            found = true;
          }
          break;
        }
      }
      if (!found) return false;
    }
    return true;
  }

  void _craftItem(BuildContext context, Recipe recipe) async {
    final provider = context.read<HunterProvider>();

    try {
      await provider.craftItem(recipe.id);
      _craftingAttempted = true;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Você criou: ${recipe.itemCreated.name}!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao criar: ${provider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        Navigator.pop(context, _craftingAttempted);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forja do Caçador'),
        ),
        body: Consumer<HunterProvider>(
          builder: (context, provider, child) {
            final recipes = provider.recipes; 
            final inventory = provider.inventory;
            final isLoading = provider.isLoading;

            if (recipes.isEmpty) {
              return const Center(child: Text('Nenhuma receita encontrada.'));
            }

            final CraftingFilter selectedFilter = _currentFilter.first;
            final List<Recipe> filteredRecipes; 

            if (selectedFilter == CraftingFilter.equipamentos) {
              filteredRecipes = recipes.where((recipe) {
                return recipe.itemCreated.type == ItemType.Equipment;
              }).toList();
            } else if (selectedFilter == CraftingFilter.itens) {
              filteredRecipes = recipes.where((recipe) {
                return recipe.itemCreated.type == ItemType.Consumable ||
                    recipe.itemCreated.type == ItemType.Material;
              }).toList();
            } else {
              filteredRecipes = recipes;
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: SegmentedButton<CraftingFilter>(
                    segments: const <ButtonSegment<CraftingFilter>>[
                      ButtonSegment(
                        value: CraftingFilter.todos,
                        label: Text('Todos'),
                        icon: Icon(Icons.apps),
                      ),
                      ButtonSegment(
                        value: CraftingFilter.equipamentos,
                        label: Text('Equip.'),
                        icon: Icon(AkarIcons.sword),
                      ),
                      ButtonSegment(
                        value: CraftingFilter.itens,
                        label: Text('Itens'),
                        icon: Icon(FontAwesomeIcons.flask),
                      ),
                    ],
                    selected: _currentFilter,
                    onSelectionChanged: (Set<CraftingFilter> newSelection) {
                      setState(() {
                        _currentFilter = newSelection;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white70,
                      selectedForegroundColor: Colors.white,
                      selectedBackgroundColor: Colors.orange[700], // Cor tema da forja
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    // ATUALIZADO: Usar a lista filtrada
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      // ATUALIZADO: Usar a lista filtrada
                      final recipe = filteredRecipes[index];
                      final item = recipe.itemCreated;

                      final bool canCraft = _canCraft(recipe, inventory);
                      final String ingredients = _buildIngredientsList(recipe);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.fireplace_outlined,
                              size: 40, color: Colors.orange),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              'Cria: ${item.description}\nRequer: $ingredients'),
                          trailing: ElevatedButton(
                            onPressed: (isLoading || !canCraft)
                                ? null
                                : () => _craftItem(context, recipe),
                            child: Text(isLoading
                                ? '...'
                                : (canCraft ? 'Criar' : 'Faltam Itens')),
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