import 'item.dart';

class RecipeIngredient {
  final int quantityRequired; 

  final Item material; 

  RecipeIngredient({
    required this.quantityRequired,
    required this.material,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      quantityRequired: json['quantityRequired'],

      material: Item.fromJson(json['material']),
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

    final List<dynamic> ingredientsJson = json['ingredients'] as List;

    final List<RecipeIngredient> ingredientsList = ingredientsJson
        .map((ingJson) => RecipeIngredient.fromJson(ingJson))
        .toList();


    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      
      itemCreated: Item.fromJson(json['itemCreated']),
      
      ingredients: ingredientsList,
    );
  }
}