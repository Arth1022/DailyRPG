import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dailyrpg/models/enums.dart';

import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/models/recipe.dart';
import 'package:dailyrpg/models/inventory_slot.dart';

enum CraftingFilter { equipamentos, itens }

class CraftingScreen extends StatefulWidget {
  const CraftingScreen({super.key});

  @override
  State<CraftingScreen> createState() => _CraftingScreenState();
}

class _CraftingScreenState extends State<CraftingScreen> {
  bool _craftingAttempted = false;
  CraftingFilter _currentFilter = CraftingFilter.equipamentos;

  // --- Lógica de Tema (Forja vs Alquimia) ---
  bool get _isAlchemy => _currentFilter == CraftingFilter.itens;

  // Paleta de Cores Clássica RPG (Medieval)
  Color get _bgDark => const Color(0xFF1A1A1A); // Fundo geral escuro
  Color get _woodDark => const Color(0xFF3E2723); // Madeira escura
  Color get _woodMedium => const Color(0xFF5D4037); // Madeira média
  Color get _metalDark => const Color(0xFF212121); // Metal/Ferro escuro
  Color get _stoneDark => const Color(0xFF333333); // Pedra escura
  Color get _goldColor => const Color(0xFFFFD700); // Dourado

  // Cores Temáticas para Forja e Alquimia
  Color get _forjaPrimary =>
      const Color(0xFF8D6E63); // Marrom acinzentado de ferro/pedra
  Color get _forjaAccent => const Color(0xFFD32F2F); // Vermelho fogo
  Color get _forjaText => const Color(0xFFF5F5F5); // Cinza claro

  Color get _alchemyPrimary => const Color(0xFF6A1B9A); // Roxo profundo
  Color get _alchemyAccent => const Color(0xFF8BC34A); // Verde claro (poção)
  Color get _alchemyText => const Color(0xFFE0E0E0); // Cinza bem claro

  // Cores dinâmicas baseadas no filtro
  Color get _themePrimary => _isAlchemy ? _alchemyPrimary : _forjaPrimary;
  Color get _themeAccent => _isAlchemy ? _alchemyAccent : _forjaAccent;
  Color get _themeText => _isAlchemy ? _alchemyText : _forjaText;
  Color get _themeCardBg => _isAlchemy
      ? _metalDark.withOpacity(0.8)
      : _woodDark.withOpacity(0.8); // Fundo mais escuro/sólido para cards

  // Ícone e Título do Cabeçalho
  IconData get _headerIcon =>
      _isAlchemy ? FontAwesomeIcons.flask : FontAwesomeIcons.hammer;

  String get _headerTitle =>
      _isAlchemy ? "MESA DE ALQUIMIA" : "FORJA DO FERREIRO";

  // Estilos de texto
  TextStyle get _rpgTitle =>
      GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white);
  TextStyle get _rpgSubtitle =>
      GoogleFonts.pressStart2p(fontSize: 9, color: Colors.white70);
  TextStyle get _rpgBody => GoogleFonts.pixelifySans(
    fontSize: 14,
    color: Colors.white70,
  ); // Mantendo pixelify para body por ser fácil de ler

  // --- Métodos de Verificação ---
  bool _canCraft(Recipe recipe, List<InventorySlot> inventory) {
    for (var req in recipe.ingredients) {
      int currentQty = 0;
      for (var slot in inventory) {
        if (slot.item.id == req.material.id) {
          currentQty = slot.quantity;
          break;
        }
      }
      if (currentQty < req.quantityRequired) return false;
    }
    return true;
  }

  // Helper para verificar quantidade de um ingrediente específico
  String _getIngredientStatus(
    dynamic ingredient,
    List<InventorySlot> inventory,
  ) {
    int currentQty = 0;
    for (var slot in inventory) {
      if (slot.item.id == ingredient.material.id) {
        currentQty = slot.quantity;
        break;
      }
    }
    return "$currentQty/${ingredient.quantityRequired}";
  }

  void _craftItem(BuildContext context, Recipe recipe) async {
    final provider = context.read<HunterProvider>();
    try {
      await provider.craftItem(recipe.id);
      setState(() {
        _craftingAttempted = true;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(FontAwesomeIcons.check, color: Colors.white, size: 14),
              const SizedBox(width: 10),
              Text('CRIADO: ${recipe.itemCreated.name}!', style: _rpgSubtitle),
            ],
          ),
          backgroundColor: Colors.green[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('FALHA: ${provider.errorMessage}', style: _rpgBody),
          backgroundColor: Colors.red[900],
        ),
      );
    }
  }

  IconData _getIconForItem(ItemType itemType, EquipmentType? equipType) {
    switch (itemType) {
      case ItemType.Consumable:
        return FontAwesomeIcons.flask;
      case ItemType.Equipment:
        if (equipType == EquipmentType.Weapon) return AkarIcons.sword;
        if (equipType == EquipmentType.Armor)
          return FontAwesomeIcons.shieldHalved;
        return FontAwesomeIcons.hatWizard;
      case ItemType.Material:
        return FontAwesomeIcons.gem;
      default:
        return FontAwesomeIcons.scroll;
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
      child: AnimatedTheme(
        data: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: _bgDark,
          colorScheme: ColorScheme.dark(
            primary: _themePrimary,
            secondary: _themeAccent,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: _woodDark, // AppBar de madeira escura
            titleTextStyle: _rpgTitle.copyWith(fontSize: 14),
            centerTitle: true,
            elevation: 0,
          ),
        ),
        duration: const Duration(milliseconds: 300),
        child: Scaffold(
          appBar: AppBar(
            title: Text(_headerTitle),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: _themePrimary.withOpacity(
                  0.7,
                ), // Borda da AppBar com o tema
                height: 2.0,
              ),
            ),
          ),
          body: Consumer<HunterProvider>(
            builder: (context, provider, child) {
              final recipes = provider.recipes;
              final inventory = provider.inventory;
              final isLoading = provider.isLoading;

              if (recipes.isEmpty) {
                return Center(
                  child: Text('Sem conhecimento de receitas.', style: _rpgBody),
                );
              }

              final filteredRecipes = _filterRecipes(recipes);

              return Column(
                children: [
                  // 1. HEADER DE AMBIENTAÇÃO (BANCADA)
                  _buildAtmosphereHeader(),

                  // 2. ABAS DE CATEGORIA
                  _buildShelfTabs(),

                  // 3. LISTA DE RECEITAS (LIVRO)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: _woodDark, // Fundo da lista como madeira
                        border: Border(
                          left: BorderSide(
                            color: _themePrimary.withOpacity(0.5),
                            width: 4,
                          ),
                          right: BorderSide(
                            color: _themePrimary.withOpacity(0.5),
                            width: 4,
                          ),
                          bottom: BorderSide(
                            color: _themePrimary.withOpacity(0.5),
                            width: 4,
                          ),
                        ),
                      ),
                      child: filteredRecipes.isEmpty
                          ? Center(
                              child: Text(
                                "Nenhuma receita encontrada.",
                                style: _rpgBody.copyWith(color: Colors.white38),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: filteredRecipes.length,
                              separatorBuilder: (ctx, i) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return _buildRecipeCard(
                                  context,
                                  filteredRecipes[index],
                                  inventory,
                                  isLoading,
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAtmosphereHeader() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: 100,
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _themeCardBg, // Cor sólida para o header
        border: Border.all(color: _themePrimary, width: 2),
        boxShadow: [
          BoxShadow(
            color: _themePrimary.withOpacity(0.2),
            blurRadius: 0,
            spreadRadius: 2,
            offset: const Offset(4, 4),
          ),
        ],
        image: DecorationImage(
          // Imagem de fundo para a atmosfera
          image: AssetImage(
            _isAlchemy ? 'assets/images/mage.png' : 'assets/images/forja.png',
          ),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _headerIcon,
            size: 40,
            color: _themeAccent,
          ), // Ícone com a cor de acento
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MESA DE TRABALHO",
                style: _rpgSubtitle.copyWith(
                  fontSize: 8,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isAlchemy ? "Brumas e Essências..." : "Forja e Metal...",
                style: _rpgTitle.copyWith(fontSize: 14, color: _themeAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShelfTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTab(
            FontAwesomeIcons.hammer,
            "FORJA",
            CraftingFilter.equipamentos,
          ),
          const SizedBox(width: 4),
          _buildTab(FontAwesomeIcons.flask, "ALQUIMIA", CraftingFilter.itens),
        ],
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, CraftingFilter filter) {
    final bool isSelected = _currentFilter == filter;

    Color tabColor = filter == CraftingFilter.itens
        ? _alchemyPrimary // Roxo para Alquimia
        : _forjaPrimary; // Marrom acinzentado para Forja

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentFilter = filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isSelected ? 45 : 35,
          decoration: BoxDecoration(
            color: isSelected ? tabColor : _woodMedium, // Abas de madeira
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            border: Border.all(color: Colors.black, width: 1),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : Colors.white54,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: _rpgSubtitle.copyWith(
                  fontSize: 9,
                  color: isSelected ? Colors.white : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(
    BuildContext context,
    Recipe recipe,
    List<InventorySlot> inventory,
    bool isLoading,
  ) {
    final item = recipe.itemCreated;
    final bool canCraft = _canCraft(recipe, inventory);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _themeCardBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: canCraft ? _themeAccent.withOpacity(0.7) : Colors.white10,
          width: 1,
        ),
        boxShadow: canCraft
            ? [BoxShadow(color: _themeAccent.withOpacity(0.1), blurRadius: 8)]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: canCraft ? _themeAccent : Colors.grey),
            ),
            child: Icon(
              _getIconForItem(item.type, item.equipType),
              size: 30,
              color: canCraft ? _themeAccent : Colors.grey,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: _rpgTitle.copyWith(fontSize: 12, color: _themeText),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: recipe.ingredients.map((ing) {
                    final status = _getIngredientStatus(ing, inventory);
                    final parts = status.split('/');
                    final hasEnough =
                        int.parse(parts[0]) >= int.parse(parts[1]);

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: hasEnough
                              ? Colors.green[800]!
                              : Colors.red[900]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "${ing.material.name}: $status",
                        style: _rpgBody.copyWith(
                          fontSize: 11,
                          color: hasEnough
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                  width: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canCraft
                          ? _themePrimary
                          : Colors.grey[800],
                      foregroundColor: Colors.white,
                      elevation: canCraft ? 4 : 0,
                      shape: const BeveledRectangleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: (isLoading || !canCraft)
                        ? null
                        : () => _craftItem(context, recipe),
                    child: isLoading
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            _isAlchemy
                                ? FontAwesomeIcons.flaskVial
                                : FontAwesomeIcons.hammer,
                            size: 16,
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                if (canCraft)
                  Text(
                    "CRIAR",
                    style: _rpgSubtitle.copyWith(
                      fontSize: 8,
                      color: _themeAccent,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    if (_currentFilter == CraftingFilter.equipamentos) {
      return recipes
          .where((r) => r.itemCreated.type == ItemType.Equipment)
          .toList();
    } else {
      return recipes
          .where(
            (r) =>
                r.itemCreated.type == ItemType.Consumable ||
                r.itemCreated.type == ItemType.Material,
          )
          .toList();
    }
  }
}
