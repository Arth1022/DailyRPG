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
  ShopFilter _currentFilter = ShopFilter.todos;

  // --- PALETA DE CORES RPG ---
  static const Color bgDark = Color(0xFF121212);
  static const Color woodDark = Color(0xFF3E2723); // Madeira escura (sombra)
  static const Color woodMedium = Color(0xFF5D4037); // Madeira base
  static const Color woodLight = Color(0xFF8D6E63); // Madeira luz
  static const Color goldColor = Color(0xFFFFD700);
  static const Color goldShadow = Color(0xFFC6A700);
  static const Color priceRed = Color(0xFFFF5252);
  static const Color priceGreen = Color(0xFF69F0AE);

  // Fontes cacheadas
  TextStyle get _pixelTitle =>
      GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white);
  TextStyle get _pixelBody =>
      GoogleFonts.pixelifySans(fontSize: 14, color: Colors.white70);

  void _buyItem(BuildContext context, Item item) async {
    final provider = context.read<HunterProvider>();
    try {
      await provider.buyItem(item.id);
      setState(() {
        _purchaseMade = true;
      });
      if (!mounted) return;
      // Feedback visual sutil em vez de snackbar intrusivo se possível,
      // mas manteremos o snackbar estilizado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ADQUIRIDO: ${item.name}',
            style: _pixelTitle.copyWith(fontSize: 10),
          ),
          backgroundColor: Colors.green[800],
          behavior: SnackBarBehavior.floating,
          shape: const BeveledRectangleBorder(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ERRO: ${provider.errorMessage}', style: _pixelBody),
          backgroundColor: Colors.red[900],
        ),
      );
    }
  }

  IconData _getIconForItem(Item item) {
    switch (item.type) {
      case ItemType.Consumable:
        return FontAwesomeIcons.flask; // Ícone mais RPG
      case ItemType.Equipment:
        if (item.equipType == EquipmentType.Weapon) return AkarIcons.sword;
        if (item.equipType == EquipmentType.Armor)
          return FontAwesomeIcons.shieldHalved;
        return FontAwesomeIcons.hatWizard;
      case ItemType.Material:
        return FontAwesomeIcons.gem;
      default:
        return FontAwesomeIcons.box;
    }
  }

  // Helper para definir cor de raridade baseada no preço (Visual Only)
  Color _getRarityColor(int price) {
    if (price < 50) return Colors.grey;
    if (price < 150) return Colors.blue;
    if (price < 500) return Colors.purple;
    return Colors.orange; // Lendário
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _purchaseMade);
        return true;
      },
      child: Scaffold(
        backgroundColor: bgDark,
        appBar: AppBar(
          backgroundColor: woodDark,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text('MERCADOR', style: _pixelTitle.copyWith(fontSize: 16)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Colors.black,
              height: 4.0,
            ), // Borda inferior da AppBar
          ),
        ),
        body: Consumer<HunterProvider>(
          builder: (context, provider, child) {
            final hunter = provider.hunter;
            final shopItems = provider.shopItems;
            final isLoading = provider.isLoading;

            if (hunter == null)
              return const Center(
                child: CircularProgressIndicator(color: goldColor),
              );

            final filteredItems = _filterItems(shopItems);

            return Column(
              children: [
                // 1. BANNER DA LOJA COM MOEDAS INTEGRADAS
                _buildShopHeader(hunter),

                const SizedBox(height: 16),

                // 2. ABAS DE MADEIRA (PLACARES)
                _buildShelfTabs(),

                // 3. LISTA DE ITENS (ESTANTE)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A1A1A), // Fundo da estante
                      border: Border(
                        left: BorderSide(color: woodMedium, width: 6),
                        right: BorderSide(color: woodMedium, width: 6),
                        bottom: BorderSide(color: woodMedium, width: 6),
                      ),
                    ),
                    child: ClipRect(
                      child: filteredItems.isEmpty
                          ? _buildEmptyShelf()
                          : ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: filteredItems.length,
                              separatorBuilder: (ctx, i) => const SizedBox(
                                height: 16,
                              ), // Espaço entre prateleiras
                              itemBuilder: (context, index) {
                                return _buildShelfItem(
                                  context,
                                  filteredItems[index],
                                  hunter,
                                  isLoading,
                                );
                              },
                            ),
                    ),
                  ),
                ),
                // Rodapé da estante
                Container(height: 10, color: bgDark),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildShopHeader(dynamic hunter) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Imagem de Fundo
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            border: const Border(
              bottom: BorderSide(color: woodLight, width: 2),
            ),
            image: const DecorationImage(
              image: AssetImage('assets/images/shop.gif'),
              fit: BoxFit.cover,
              opacity: 0.6,
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
        ),
        // Texto do Mercador
        Positioned(
          bottom: 10,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BEM-VINDO,",
                style: _pixelTitle.copyWith(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "O QUE VAI LEVAR?",
                style: _pixelTitle.copyWith(fontSize: 14, color: goldColor),
              ),
            ],
          ),
        ),
        // Display de Moedas (Estilo Etiqueta Pendurada)
        Positioned(
          bottom: -15,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: woodDark,
              border: Border.all(color: goldColor, width: 2),
              borderRadius: BorderRadius.circular(0), // Quadrado pixelado
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  offset: Offset(2, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FontAwesomeIcons.coins, color: goldColor, size: 14),
                const SizedBox(width: 8),
                Text(
                  '${hunter.currentCoins}',
                  style: _pixelTitle.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyShelf() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.boxOpen, size: 40, color: Colors.white24),
          const SizedBox(height: 10),
          Text(
            "ESTOQUE VAZIO",
            style: _pixelTitle.copyWith(color: Colors.white24, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // --- TAB SYSTEM ---
  Widget _buildShelfTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildWoodTab('GERAL', ShopFilter.todos),
          const SizedBox(width: 4),
          _buildWoodTab('ARMAS', ShopFilter.equipamentos),
          const SizedBox(width: 4),
          _buildWoodTab('ITENS', ShopFilter.itens),
        ],
      ),
    );
  }

  Widget _buildWoodTab(String title, ShopFilter filter) {
    final bool isSelected = _currentFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentFilter = filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isSelected ? 45 : 35,
          decoration: BoxDecoration(
            color: isSelected ? woodLight : woodMedium,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            border: Border.all(color: Colors.black, width: 1),
            boxShadow: isSelected
                ? []
                : [
                    const BoxShadow(
                      color: Colors.black45,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // Textura simulada (linhas)
              Positioned(
                top: 5,
                left: 5,
                right: 5,
                height: 1,
                child: Container(color: Colors.white10),
              ),

              // Prego visual
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Center(
                child: Text(
                  title,
                  style: _pixelTitle.copyWith(
                    fontSize: 9,
                    color: isSelected ? Colors.white : Colors.white54,
                    shadows: [
                      const Shadow(color: Colors.black, offset: Offset(1, 1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ITEM CARD (PRATELEIRA) ---
  Widget _buildShelfItem(
    BuildContext context,
    Item item,
    dynamic hunter,
    bool isLoading,
  ) {
    final bool canAfford = hunter.currentCoins >= item.shopPrice;
    final rarityColor = _getRarityColor(item.shopPrice);

    return Stack(
      children: [
        // Base da Prateleira (Visual 3D simples)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 8,
          child: Container(
            decoration: const BoxDecoration(
              color: woodDark,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),

        // O Card do Item em si
        Container(
          margin: const EdgeInsets.only(
            bottom: 4,
          ), // Espaço para a prateleira aparecer
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF252525),
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              // 1. ÍCONE COM RARIDADE
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color: rarityColor.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: rarityColor.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _getIconForItem(item),
                    color: rarityColor,
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 2. INFORMAÇÕES
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: _pixelTitle.copyWith(fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: _pixelBody.copyWith(
                        fontSize: 10,
                        color: Colors.white54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Preço
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.coins,
                          size: 10,
                          color: canAfford ? goldColor : priceRed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.shopPrice} G',
                          style: _pixelTitle.copyWith(
                            fontSize: 10,
                            color: canAfford ? goldColor : priceRed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. BOTÃO DE COMPRA
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: (isLoading || !canAfford)
                      ? null
                      : () => _buyItem(context, item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford ? woodMedium : Colors.grey[800],
                    foregroundColor: Colors.white,
                    elevation: canAfford ? 4 : 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: const BeveledRectangleBorder(
                      side: BorderSide(color: Colors.black26),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "COMPRAR",
                          style: _pixelTitle.copyWith(
                            fontSize: 8,
                            color: canAfford ? goldColor : Colors.white38,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Item> _filterItems(List<Item> items) {
    if (_currentFilter == ShopFilter.equipamentos) {
      return items.where((item) => item.type == ItemType.Equipment).toList();
    } else if (_currentFilter == ShopFilter.itens) {
      return items
          .where(
            (item) =>
                item.type == ItemType.Consumable ||
                item.type == ItemType.Material,
          )
          .toList();
    }
    return items;
  }
}
