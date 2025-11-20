import 'item.dart';
import 'enums.dart'; // Caso precise, mas o item.dart já deve resolver

class RecipeIngredient {
  final int quantityRequired;
  final Item material;

  RecipeIngredient({required this.quantityRequired, required this.material});

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      quantityRequired: json['quantityRequired'] ?? 1,

      // CORREÇÃO: Usamos o SEU Item.fromJson aqui
      // Se vier nulo, criamos um item "dummy" para não quebrar o app
      material: json['material'] != null
          ? Item.fromJson(json['material'])
          : Item(
              id: 0,
              name: 'Erro',
              description: '',
              type: ItemType.Material,
              equipType: EquipmentType.None,
              effectValue: 0,
              shopPrice: 0,
              skillAffinity: 'None',
            ),
    );
  }
}

class Recipe {
  final int id;
  final String name;
  final String description;
  final Item itemCreated;
  final List<RecipeIngredient> ingredients;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.itemCreated,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // 1. Proteção da Lista (O Backend manda 'recipeIngredients')
    var listData = json['recipeIngredients'] as List?;
    if (listData == null) listData = [];

    List<RecipeIngredient> ingredientsList = listData
        .map((i) => RecipeIngredient.fromJson(i))
        .toList();

    return Recipe(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sem Nome',
      description: json['description'] ?? '',

      // 2. CORREÇÃO PRINCIPAL: Converter o Map para o SEU Item
      itemCreated: json['itemCreated'] != null
          ? Item.fromJson(json['itemCreated'])
          : Item(
              id: 0,
              name: 'Erro Item',
              description: '',
              type: ItemType.Material,
              equipType: EquipmentType.None,
              effectValue: 0,
              shopPrice: 0,
              skillAffinity: 'None',
            ),

      ingredients: ingredientsList,
    );
  }
}
