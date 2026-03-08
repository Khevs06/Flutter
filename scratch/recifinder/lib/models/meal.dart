// lib/models/meal.dart
class Meal {
  final String idMeal;
  final String strMeal;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strMealThumb;
  final List<String> ingredients;
  final List<String> measures;

  Meal({
    required this.idMeal,
    required this.strMeal,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    required this.ingredients,
    required this.measures,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measures = [];

    // The API returns strIngredient1 to strIngredient20 and strMeasure1 to strMeasure20
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient);
        measures.add(measure ?? '');
      }
    }

    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? 'Unknown Meal',
      strCategory: json['strCategory'] ?? 'Unknown Category',
      strArea: json['strArea'] ?? 'Unknown Area',
      strInstructions: json['strInstructions'] ?? 'No instructions provided.',
      strMealThumb: json['strMealThumb'] ?? '',
      ingredients: ingredients,
      measures: measures,
    );
  }
}
