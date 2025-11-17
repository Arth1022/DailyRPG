import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // Import necessário
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

  // Alterado para um único valor para corresponder à lógica do filtro de botões
  CraftingFilter _currentFilter = CraftingFilter.todos;

  // --- Estilos e Cores Pixelados ---
  static const darkCardColor = Color.fromARGB(255, 40, 40, 40); // Fundo do Item
  static const darkBackgroundColor = Color.fromARGB(
    255,
    30,
    30,
    30,
  ); // Fundo da Tela
  static const pixelAccentColor =
      Colors.orange; // Cor de destaque da forja (Laranja/Fogo)
  static const pixelButtonColor = Color.fromARGB(
    255,
    77,
    167,
    209,
  ); // Cor primária (azul/aço)

  TextStyle get _pixelTitleStyle =>
      GoogleFonts.pressStart2p(fontSize: 14, color: Colors.white);
  TextStyle get _pixelButtonTextStyle =>
      GoogleFonts.pressStart2p(fontSize: 10, fontWeight: FontWeight.bold);
  TextStyle get _pixelItemTitleStyle =>
      GoogleFonts.pressStart2p(fontSize: 12, fontWeight: FontWeight.w400);
  TextStyle get _pixelItemSubtitleStyle =>
      GoogleFonts.pixelifySans(fontSize: 12);

  static const Map<CraftingFilter, String> _craftingFilters = {
    CraftingFilter.todos: 'TODOS',
    CraftingFilter.equipamentos: 'EQUIPAMENTOS',
    CraftingFilter.itens: 'ITENS',
  };
  // ------------------------------------

  String _buildIngredientsList(Recipe recipe) {
    return recipe.ingredients
        .map((ing) {
          return '${ing.quantityRequired}x ${ing.material.name}';
        })
        .join(', ');
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

  // Widget de Botões de Filtro Personalizado (semelhante ao da ShopScreen)
  Widget _buildFilterButtons() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: _craftingFilters.entries.map((entry) {
            final isSelected = entry.key == _currentFilter;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentFilter = entry.key; // Atualiza para o filtro único
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? pixelAccentColor
                      : darkCardColor,
                  foregroundColor: isSelected ? darkCardColor : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(
                      color: isSelected ? Colors.white : Colors.white54,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  elevation: isSelected ? 5 : 0,
                ),
                child: Text(
                  entry.value,
                  // Usando o estilo de fonte pixelado para o botão
                  style: _pixelButtonTextStyle.copyWith(
                    fontSize: 9, // Ajustado para o Row
                    color: isSelected ? darkCardColor : Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Função utilitária para obter o ícone do item criado (pode ser útil)
  IconData _getIconForItem(ItemType itemType, EquipmentType? equipType) {
    switch (itemType) {
      case ItemType.Consumable:
        return FontAwesomeIcons.flask;
      case ItemType.Equipment:
        if (equipType == EquipmentType.Weapon) {
          return AkarIcons.sword;
        } else if (equipType == EquipmentType.Armor) {
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
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBackgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: darkBackgroundColor,
          titleTextStyle: _pixelTitleStyle,
          centerTitle: true,
        ),
      ),
      child: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) return;
          Navigator.pop(context, _craftingAttempted);
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Forja do Caçador')),
          body: Consumer<HunterProvider>(
            builder: (context, provider, child) {
              final recipes = provider.recipes;
              final inventory = provider.inventory;
              final isLoading = provider.isLoading;

              if (recipes.isEmpty) {
                return Center(
                  child: Text(
                    'Nenhuma receita encontrada.',
                    style: _pixelItemTitleStyle.copyWith(fontSize: 10),
                  ),
                );
              }

              final CraftingFilter selectedFilter = _currentFilter;
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
                  // Filtro de Botões Personalizado
                  _buildFilterButtons(),

                  const Divider(height: 20, color: Colors.white12),

                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = filteredRecipes[index];
                        final item = recipe.itemCreated;

                        final bool canCraft = _canCraft(recipe, inventory);
                        final String ingredients = _buildIngredientsList(
                          recipe,
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: darkCardColor, // Aplicando cor pixelada
                          shape: const BeveledRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(
                              color: Colors.white24,
                              width: 1,
                            ), // Borda pixelada
                          ),
                          child: ListTile(
                            leading: Icon(
                              _getIconForItem(item.type, item.equipType),
                              size: 40,
                              color:
                                  pixelAccentColor, // Cor de destaque da forja
                            ),
                            title: Text(
                              item.name,
                              style: _pixelItemTitleStyle, // Estilo pixelado
                            ),
                            subtitle: Text(
                              'Cria: ${item.description}\nRequer: $ingredients',
                              style: _pixelItemSubtitleStyle, // Estilo pixelado
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  29,
                                  29,
                                  29,
                                ), // Fundo escuro do botão
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                shape: const BeveledRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                  side: BorderSide(
                                    color: pixelButtonColor,
                                  ), // Borda pixelada
                                ),
                                elevation: 0,
                              ),
                              onPressed: (isLoading || !canCraft)
                                  ? null
                                  : () => _craftItem(context, recipe),
                              child: Text(
                                isLoading
                                    ? '...'
                                    : (canCraft ? 'CRIAR' : 'FALTAM ITENS'),
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 9, // Estilo pixelado
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
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
      ),
    );
  }
}
