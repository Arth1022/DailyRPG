import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Mapa de filtros para a loja
  static const Map<ShopFilter, String> _shopFilters = {
    ShopFilter.todos: 'TODOS',
    ShopFilter.equipamentos: 'EQUIPAMENTOS',
    ShopFilter.itens: 'ITENS',
  };

  ShopFilter _currentFilter = ShopFilter.todos;

  // --- Estilos e Cores Pixelados (Copiados da InventoryScreen) ---
  static const darkCardColor = Color.fromARGB(
    255,
    40,
    40,
    40,
  ); // Cor de fundo do Card/Botão Não Selecionado
  static const pixelPrimaryColor = Color.fromARGB(
    255,
    77,
    167,
    209,
  ); // Cor de destaque
  static const darkBackgroundColor = Color.fromARGB(
    255,
    30,
    30,
    30,
  ); // Fundo da tela

  TextStyle get _pixelStatValueStyle =>
      GoogleFonts.pressStart2p(fontSize: 12, fontWeight: FontWeight.bold);
  // ------------------------------------------------------------------

  void _buyItem(BuildContext context, Item item) async {
    final provider = context.read<HunterProvider>();

    try {
      await provider.buyItem(item.id);
      _purchaseMade = true;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comprado! Você adquiriu: ${item.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha na compra: ${provider.errorMessage}'),
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

  // Novo Widget de Botões de Filtro Centralizado
  Widget _buildFilterButtons() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: _shopFilters.entries.map((entry) {
            final isSelected = entry.key == _currentFilter;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentFilter = entry.key;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? pixelPrimaryColor
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
                  // Usando o estilo de fonte pixelado
                  style: _pixelStatValueStyle.copyWith(
                    fontSize: 10,
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

  @override
  Widget build(BuildContext context) {
    const goldColor = Colors.amber;

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBackgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: darkBackgroundColor,
          titleTextStyle: GoogleFonts.pressStart2p(
            fontSize: 14,
            color: Colors.white,
          ),
          centerTitle: true,
        ),
      ),
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, _purchaseMade);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Loja do Caçador')),
          body: Consumer<HunterProvider>(
            builder: (context, provider, child) {
              final hunter = provider.hunter;
              final shopItems = provider.shopItems;
              final isLoading = provider.isLoading;

              if (hunter == null) {
                return const Center(
                  child: Text('Erro ao carregar os dados do caçador.'),
                );
              }

              final ShopFilter selectedFilter =
                  _currentFilter; // Usando _currentFilter diretamente
              final List<Item> filteredItems;

              if (selectedFilter == ShopFilter.equipamentos) {
                filteredItems = shopItems
                    .where((item) => item.type == ItemType.Equipment)
                    .toList();
              } else if (selectedFilter == ShopFilter.itens) {
                filteredItems = shopItems
                    .where(
                      (item) =>
                          item.type == ItemType.Consumable ||
                          item.type == ItemType.Material,
                    )
                    .toList();
              } else {
                filteredItems = shopItems;
              }

              return Column(
                children: [
                  // CONTAINER DE IMAGEM
                  Container(
                    height: 190,
                    width: double.infinity,
                    margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.zero,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/shop.gif'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.white54, width: 2),
                    ),
                  ),

                  // MOEDAS
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          FontAwesomeIcons.coins,
                          color: goldColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${hunter.currentCoins}G',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 12,
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // NOVO FILTRO DE BOTÕES PERSONALIZADO
                  _buildFilterButtons(),

                  const Divider(height: 20, color: Colors.white12),

                  // Lista de Itens (Card com Botão Pixelado Restaurado)
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final bool canAfford =
                            hunter.currentCoins >= item.shopPrice;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: const BeveledRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(color: Colors.white24, width: 1),
                          ),
                          color:
                              darkCardColor, // Usando darkCardColor para fundo do item
                          child: ListTile(
                            leading: Icon(
                              _getIconForItem(item),
                              size: 40,
                              color: pixelPrimaryColor,
                            ),
                            title: Text(
                              item.name,
                              style: GoogleFonts.pressStart2p(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            subtitle: Text(
                              '${item.description}\nPreço: ${item.shopPrice}G',
                              style: GoogleFonts.pixelifySans(fontSize: 12),
                            ),
                            trailing: Container(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    29,
                                    29,
                                    29,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  shape: const BeveledRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                    side: BorderSide(color: pixelPrimaryColor),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: (isLoading || !canAfford)
                                    ? null
                                    : () => _buyItem(context, item),
                                child: Text(
                                  isLoading
                                      ? '...'
                                      : (canAfford ? 'COMPRAR' : 'SEM OURO'),
                                  style: GoogleFonts.pressStart2p(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w300,
                                  ),
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
