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
  // --- Variável de Estado para o Filtro ---
  ItemType? _selectedFilter;

  // Mapa de filtros (ItemType, Rótulo) com apenas 3 opções
  static const Map<ItemType?, String> _itemFilters = {
    null: 'TUDO',
    ItemType.Equipment: 'EQUIPAMENTOS',
    ItemType.Material: 'MATERIAIS',
    // ItemType.Consumable e ItemType.XP foram removidos
  };
  // ------------------------------------------

  // --- Definições de Estilo (MANTIDAS) ---
  static const darkBackground = Color(0xFF1A1A1A);
  static const darkCardColor = Color(0xff2a2a2a);
  static const pixelPrimaryColor = Color.fromARGB(255, 77, 167, 209);

  // Cores dos Atributos
  static Color strengthColor = Colors.red[400]!;
  static Color dexterityColor = Colors.yellow[400]!;
  static Color intelligenceColor = const Color.fromARGB(255, 81, 245, 66);
  static Color constitutionColor = Colors.blue[400]!;
  static Color enduranceColor = Colors.grey[400]!;
  // -----------------------------

  TextStyle get _pixelTitleStyle =>
      GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white);

  TextStyle get _pixelSubtitleStyle =>
      GoogleFonts.pixelifySans(fontSize: 14, color: Colors.white70);

  TextStyle get _pixelStatValueStyle =>
      GoogleFonts.pressStart2p(fontSize: 12, fontWeight: FontWeight.bold);

  TextStyle get _pixelStatLabelStyle => GoogleFonts.pixelifySans(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HunterProvider>();
    });
  }

  // Mapeamento de Ícones (MANTIDO)
  IconData _getIconForItem(Item item) {
    switch (item.type) {
      case ItemType.XP:
        return AkarIcons.diamond;
      case ItemType.Consumable:
        return FontAwesomeIcons.flask;
      case ItemType.Equipment:
        if (item.equipType == EquipmentType.Weapon) {
          return AkarIcons.sword;
        } else if (item.equipType == EquipmentType.Armor) {
          return FontAwesomeIcons.shirt;
        }
        return FontAwesomeIcons.hatWizard;
      case ItemType.Material:
        return FontAwesomeIcons.gem;
      default:
        return FontAwesomeIcons.question;
    }
  }

  void _useItem(BuildContext context, int slotId) async {
    final provider = context.read<HunterProvider>();

    try {
      await provider.useItem(slotId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ação realizada com sucesso!',
            style: _pixelSubtitleStyle.copyWith(fontSize: 10),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Falha ao usar o item: ${provider.errorMessage}',
            style: _pixelSubtitleStyle.copyWith(fontSize: 10),
          ),
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
          content: Text(
            'Você aumentou $skillName!',
            style: _pixelSubtitleStyle.copyWith(fontSize: 10),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Falha ao gastar ponto: ${provider.errorMessage}',
            style: _pixelSubtitleStyle.copyWith(fontSize: 10),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Widget _buildStatRow (MANTIDO)
  Widget _buildStatRow(
    BuildContext context,
    HunterProvider provider,
    String label,
    String skillName,
    int statValue,
    IconData icon,
    Color color,
  ) {
    final bool canSpend = provider.hunter!.attributePoints > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 15),
              SizedBox(
                width: 120,
                child: Text(label, style: _pixelStatLabelStyle),
              ),
              const SizedBox(width: 15),
              Text(
                statValue.toString(),
                style: _pixelStatValueStyle.copyWith(color: color),
              ),
            ],
          ),
          if (canSpend)
            Container(
              decoration: BoxDecoration(
                color: darkCardColor,
                border: Border.all(color: Colors.white54, width: 1),
                shape: BoxShape.rectangle,
              ),
              child: IconButton(
                icon: const Icon(FontAwesomeIcons.plus, color: Colors.green),
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: provider.isLoading
                    ? null
                    : () => _spendPoint(context, skillName),
              ),
            ),
        ],
      ),
    );
  }

  // WIDGET PARA OS BOTÕES DE FILTRO (AGORA CENTRALIZADO)
  Widget _buildFilterButtons() {
    // Substituído SingleChildScrollView por Center
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centraliza os botões dentro do Row
          mainAxisSize: MainAxisSize.min, // Faz a Row ocupar o mínimo de espaço
          children: _itemFilters.entries.map((entry) {
            final isSelected = entry.key == _selectedFilter;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
              ), // Ajuste de padding
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = entry.key;
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
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: darkCardColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'INVENTÁRIO',
          style: _pixelTitleStyle.copyWith(fontSize: 16),
        ),
      ),
      body: Consumer<HunterProvider>(
        builder: (context, provider, child) {
          final hunter = provider.hunter;
          final inventory = provider.inventory;
          final isLoading = provider.isLoading;

          if (hunter == null) {
            return Center(
              child: Text(
                'ERRO: CAÇADOR NÃO ENCONTRADO.',
                style: _pixelSubtitleStyle,
                textAlign: TextAlign.center,
              ),
            );
          }

          // --- LÓGICA DE FILTRAGEM ---
          final filteredInventory = inventory.where((slot) {
            if (_selectedFilter == null) {
              return true; // Mostrar todos
            }

            if (_selectedFilter == ItemType.Equipment) {
              return slot.item.type == ItemType.Equipment;
            }

            // Filtro Material inclui Material, Consumível e XP
            if (_selectedFilter == ItemType.Material) {
              return slot.item.type != ItemType.Equipment;
            }

            return slot.item.type == _selectedFilter;
          }).toList();
          // ------------------------------------

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SEÇÃO DE ATRIBUTOS (MANTIDA) ---
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: darkCardColor,
                      border: Border.all(color: pixelPrimaryColor, width: 2),
                      shape: BoxShape.rectangle,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "ATRIBUTOS",
                              style: _pixelTitleStyle.copyWith(fontSize: 14),
                            ),
                            if (hunter.attributePoints > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  "${hunter.attributePoints} PTs",
                                  style: _pixelStatValueStyle.copyWith(
                                    fontSize: 10,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Divider(height: 20, color: Colors.white12),
                        _buildStatRow(
                          context,
                          provider,
                          'Força',
                          'strength',
                          hunter.strength,
                          FontAwesomeIcons.gavel,
                          strengthColor,
                        ),
                        _buildStatRow(
                          context,
                          provider,
                          'Destreza',
                          'dexterity',
                          hunter.dexterity,
                          FontAwesomeIcons.bolt,
                          dexterityColor,
                        ),
                        _buildStatRow(
                          context,
                          provider,
                          'Inteligência',
                          'intelligence',
                          hunter.intelligence,
                          FontAwesomeIcons.brain,
                          intelligenceColor,
                        ),
                        _buildStatRow(
                          context,
                          provider,
                          'Constituição',
                          'constitution',
                          hunter.constitution,
                          FontAwesomeIcons.heart,
                          constitutionColor,
                        ),
                        _buildStatRow(
                          context,
                          provider,
                          'Vigor',
                          'endurance',
                          hunter.endurance,
                          FontAwesomeIcons.handHoldingMedical,
                          enduranceColor,
                        ),
                        const Divider(height: 20, color: Colors.white12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Dano: ${hunter.damage}',
                              style: _pixelSubtitleStyle.copyWith(fontSize: 12),
                            ),
                            Text(
                              'HP: ${hunter.currentHp}/${hunter.maxHp}',
                              style: _pixelSubtitleStyle.copyWith(fontSize: 12),
                            ),
                            Text(
                              'Defesa: ${hunter.defense}',
                              style: _pixelSubtitleStyle.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- TÍTULO DA MOCHILA ---
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4.0,
                      right: 4.0,
                      bottom: 8.0,
                    ),
                    child: Text(
                      'MOCHILA',
                      style: _pixelTitleStyle.copyWith(fontSize: 14),
                    ),
                  ),

                  // --- FILTRO DE BOTÕES (CENTRALIZADO) ---
                  _buildFilterButtons(),
                  // ------------------------------

                  // Lista de Itens (usando a lista filtrada)
                  ...filteredInventory.map((slot) {
                    final item = slot.item;
                    final bool isEquipped =
                        (hunter.equippedWeaponSlotId == slot.id) ||
                        (hunter.equippedArmorSlotId == slot.id);

                    String buttonText;
                    Color buttonColor;
                    bool canBeUsed = true;

                    // Lógica para Consumível e XP (agora sob o filtro 'Materiais')
                    if (item.type == ItemType.Equipment) {
                      if (isEquipped) {
                        buttonText = 'DESEQUIPAR';
                        buttonColor = const Color(0xFF6A1B9A);
                      } else {
                        buttonText = 'EQUIPAR';
                        buttonColor = pixelPrimaryColor;
                      }
                    } else if (item.type == ItemType.Consumable) {
                      buttonText = 'USAR';
                      buttonColor = Colors.green[600]!;
                    } else if (item.type == ItemType.XP) {
                      // Se for XP, o botão deve ser USAR também, se a lógica permitir
                      buttonText = 'USAR XP';
                      buttonColor = Colors.yellow[600]!;
                    } else {
                      // ItemType.Material
                      buttonText = 'MATERIAL';
                      canBeUsed = false;
                      buttonColor = Colors.grey[700]!;
                    }

                    return Card(
                      color: darkCardColor,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(
                          color: isEquipped ? Colors.yellow : Colors.white24,
                          width: isEquipped ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getIconForItem(item),
                          size: 30,
                          color: Colors.white,
                        ),
                        title: Text(
                          item.name,
                          style: _pixelStatLabelStyle.copyWith(
                            color: isEquipped ? Colors.yellow : Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          'Qtd: ${slot.quantity}\n${item.description}',
                          style: _pixelSubtitleStyle.copyWith(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            shape: const BeveledRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          onPressed: (isLoading || !canBeUsed)
                              ? null
                              : () => _useItem(context, slot.id),
                          child: Text(
                            buttonText,
                            style: _pixelStatValueStyle.copyWith(fontSize: 8),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // Se a lista filtrada estiver vazia
                  if (filteredInventory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Center(
                        child: Text(
                          _selectedFilter == null
                              ? 'O INVENTÁRIO ESTÁ VAZIO.'
                              : 'NENHUM ITEM DO TIPO SELECIONADO.',
                          style: _pixelSubtitleStyle.copyWith(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
