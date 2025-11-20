import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/models/item.dart';
import 'package:dailyrpg/models/enums.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  ItemType? _selectedFilter;

  static const Map<ItemType?, String> _itemFilters = {
    null: 'TUDO',
    ItemType.Equipment: 'EQUIP.',
    ItemType.Material: 'ITEMS',
  };

  // --- CORES E ESTILOS ---
  static const darkBackground = Color(0xFF121212); // Fundo quase preto
  static const panelColor = Color(0xFF1E1E1E); // Cinza escuro para painéis
  static const pixelPrimaryColor = Color(0xFF4DA7D1); // Ciano
  static const goldColor = Color(0xFFFFD700); // Dourado para itens equipados
  static const accentRed = Color(0xFFFF5555);
  static const accentGreen = Color(0xFF55FF55);

  // Cores Atributos
  final Color strColor = const Color(0xFFFF4444);
  final Color dexColor = const Color(0xFFFFEB3B);
  final Color intColor = const Color(0xFF00E676);
  final Color conColor = const Color(0xFF2979FF);
  final Color endColor = const Color(0xFFB0BEC5);

  TextStyle get _pixelTitleStyle =>
      GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white);

  TextStyle get _pixelBodyStyle =>
      GoogleFonts.pixelifySans(fontSize: 14, color: Colors.white70);

  TextStyle get _pixelValueStyle =>
      GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HunterProvider>();
    });
  }

  IconData _getIconForItem(Item item) {
    switch (item.type) {
      case ItemType.XP:
        return AkarIcons.diamond;
      case ItemType.Consumable:
        return FontAwesomeIcons.flask;
      case ItemType.Equipment:
        if (item.equipType == EquipmentType.Weapon) return AkarIcons.sword;
        if (item.equipType == EquipmentType.Armor)
          return FontAwesomeIcons.shirt;
        return FontAwesomeIcons.hatWizard;
      case ItemType.Material:
        return FontAwesomeIcons.gem;
      default:
        return FontAwesomeIcons.boxOpen;
    }
  }

  // Lógica de Uso (Mantida)
  void _useItem(BuildContext context, int slotId) async {
    final provider = context.read<HunterProvider>();
    try {
      await provider.useItem(slotId);
      if (!mounted) return;
      _showFeedback(context, 'Item utilizado!', Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showFeedback(context, 'Erro: ${provider.errorMessage}', Colors.red);
    }
  }

  void _spendPoint(BuildContext context, String skillName) async {
    final provider = context.read<HunterProvider>();
    try {
      await provider.spendAttributePoint(skillName);
      if (!mounted) return;
      _showFeedback(context, '$skillName aumentado!', Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showFeedback(context, 'Erro: ${provider.errorMessage}', Colors.red);
    }
  }

  void _showFeedback(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: _pixelBodyStyle.copyWith(fontSize: 12)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: const BeveledRectangleBorder(),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'PERSONAGEM',
          style: _pixelTitleStyle.copyWith(fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.white24, height: 1.0),
        ),
      ),
      body: Consumer<HunterProvider>(
        builder: (context, provider, child) {
          final hunter = provider.hunter;
          final inventory = provider.inventory;
          final isLoading = provider.isLoading;

          if (hunter == null) {
            return Center(
              child: Text('Carregando dados...', style: _pixelBodyStyle),
            );
          }

          // Filtragem
          final filteredInventory = inventory.where((slot) {
            if (_selectedFilter == null) return true;
            if (_selectedFilter == ItemType.Equipment) {
              return slot.item.type == ItemType.Equipment;
            }
            if (_selectedFilter == ItemType.Material) {
              return slot.item.type != ItemType.Equipment;
            }
            return slot.item.type == _selectedFilter;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. FICHA DE PERSONAGEM (STATUS HEADER)
                _buildCharacterSheet(context, provider, hunter),

                const SizedBox(height: 24),

                // 2. TÍTULO E FILTROS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('MOCHILA', style: _pixelTitleStyle),
                    Text(
                      '${filteredInventory.length} ITEMS',
                      style: _pixelBodyStyle.copyWith(
                        fontSize: 10,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFilterBar(),
                const SizedBox(height: 16),

                // 3. LISTA DE ITENS (Grid/Lista Visual)
                if (filteredInventory.isEmpty)
                  Container(
                    height: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white12,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Text(
                      "Vazio...",
                      style: _pixelBodyStyle.copyWith(color: Colors.white24),
                    ),
                  )
                else
                  ...filteredInventory.map((slot) {
                    return _buildInventorySlot(
                      context,
                      slot,
                      hunter,
                      isLoading,
                    );
                  }).toList(),

                // Espaço extra no final para não colar na borda
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildCharacterSheet(
    BuildContext context,
    HunterProvider provider,
    dynamic hunter,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: panelColor,
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          // HUD Topo (HP, DEF, DMG)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.black26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHudStat(
                  'HP',
                  '${hunter.currentHp}/${hunter.maxHp}',
                  accentRed,
                  FontAwesomeIcons.heart,
                ),
                Container(width: 1, height: 20, color: Colors.white12),
                _buildHudStat(
                  'ATK',
                  '${hunter.damage}',
                  pixelPrimaryColor,
                  AkarIcons.sword,
                ),
                Container(width: 1, height: 20, color: Colors.white12),
                _buildHudStat(
                  'DEF',
                  '${hunter.defense}',
                  Colors.grey,
                  FontAwesomeIcons.shield,
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.white12),

          // Atributos Principais
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ATRIBUTOS",
                      style: _pixelTitleStyle.copyWith(
                        fontSize: 10,
                        color: Colors.white54,
                      ),
                    ),
                    if (hunter.attributePoints > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentGreen.withOpacity(0.2),
                          border: Border.all(color: accentGreen),
                        ),
                        child: Text(
                          "+${hunter.attributePoints} PONTOS",
                          style: _pixelValueStyle.copyWith(
                            fontSize: 8,
                            color: accentGreen,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  provider,
                  'FORÇA',
                  'strength',
                  hunter.strength,
                  FontAwesomeIcons.gavel,
                  strColor,
                ),
                _buildStatRow(
                  context,
                  provider,
                  'DESTREZA',
                  'dexterity',
                  hunter.dexterity,
                  FontAwesomeIcons.wind,
                  dexColor,
                ),
                _buildStatRow(
                  context,
                  provider,
                  'INTELIGÊNCIA',
                  'intelligence',
                  hunter.intelligence,
                  FontAwesomeIcons.brain,
                  intColor,
                ),
                _buildStatRow(
                  context,
                  provider,
                  'CONSTITUIÇÃO',
                  'constitution',
                  hunter.constitution,
                  FontAwesomeIcons.heartPulse,
                  conColor,
                ),
                _buildStatRow(
                  context,
                  provider,
                  'VIGOR',
                  'endurance',
                  hunter.endurance,
                  FontAwesomeIcons.personRunning,
                  endColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHudStat(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 4),
            Text(value, style: _pixelValueStyle.copyWith(color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    HunterProvider provider,
    String label,
    String skillKey,
    int value,
    IconData icon,
    Color color,
  ) {
    final canSpend = provider.hunter!.attributePoints > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: _pixelBodyStyle.copyWith(color: Colors.white),
            ),
          ),
          Text('$value', style: _pixelValueStyle.copyWith(color: color)),
          if (canSpend) ...[
            const SizedBox(width: 12),
            SizedBox(
              width: 24,
              height: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  FontAwesomeIcons.plusSquare,
                  size: 16,
                  color: Colors.white,
                ),
                onPressed: provider.isLoading
                    ? null
                    : () => _spendPoint(context, skillKey),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _itemFilters.entries.map((entry) {
          final isSelected = entry.key == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => setState(() => _selectedFilter = entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  border: Border.all(color: Colors.white),
                ),
                child: Text(
                  entry.value,
                  style: _pixelTitleStyle.copyWith(
                    fontSize: 10,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInventorySlot(
    BuildContext context,
    dynamic slot,
    dynamic hunter,
    bool isLoading,
  ) {
    final item = slot.item;
    final bool isEquipped =
        (hunter.equippedWeaponSlotId == slot.id) ||
        (hunter.equippedArmorSlotId == slot.id);

    // Definição das cores e textos do botão
    String btnText = "USAR";
    Color btnColor = Colors.white24;
    Color textColor = Colors.white;
    bool canUse = true;

    if (item.type == ItemType.Equipment) {
      if (isEquipped) {
        btnText = "TIRAR";
        btnColor = Colors.deepPurple.withOpacity(0.5);
      } else {
        btnText = "EQUIPAR";
        btnColor = pixelPrimaryColor.withOpacity(0.2);
        textColor = pixelPrimaryColor;
      }
    } else if (item.type == ItemType.Material) {
      btnText = "INFO";
      canUse = false;
    } else {
      // Consumíveis e XP
      btnColor = accentGreen.withOpacity(0.2);
      textColor = accentGreen;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isEquipped ? goldColor.withOpacity(0.05) : panelColor,
        border: Border.all(
          color: isEquipped ? goldColor : Colors.white12,
          width: 1,
        ),
        // Estilo chanfrado igual ao ContractList
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        children: [
          // Ícone Box
          Container(
            width: 60,
            height: 70, // Altura fixa para alinhar
            color: Colors.black26,
            child: Center(
              child: Icon(
                _getIconForItem(item),
                color: isEquipped ? goldColor : Colors.white,
                size: 24,
              ),
            ),
          ),

          // Detalhes
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: _pixelTitleStyle.copyWith(
                            fontSize: 10,
                            color: isEquipped ? goldColor : Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "x${slot.quantity}",
                        style: _pixelBodyStyle.copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: _pixelBodyStyle.copyWith(
                      fontSize: 10,
                      color: Colors.white38,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Botão de Ação
          SizedBox(
            height: 70,
            width: 80,
            child: ElevatedButton(
              onPressed: (isLoading || !canUse)
                  ? null
                  : () => _useItem(context, slot.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                foregroundColor: textColor,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ), // Botão quadrado
                padding: EdgeInsets.zero,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isEquipped)
                    const Icon(
                      FontAwesomeIcons.shieldHalved,
                      size: 12,
                      color: Colors.white70,
                    ),
                  if (isEquipped) const SizedBox(height: 4),
                  Text(
                    btnText,
                    style: _pixelTitleStyle.copyWith(
                      fontSize: 8,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
