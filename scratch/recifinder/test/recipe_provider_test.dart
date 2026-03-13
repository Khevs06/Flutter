import 'package:flutter_test/flutter_test.dart';
import 'package:recifinder/models/meal.dart';
import 'package:recifinder/providers/recipe_provider.dart';
import 'package:recifinder/services/api_service.dart';

class FakeApiService extends ApiService {
  @override
  Future<List<Meal>> filterMealsByArea(String area) async {
    // return one meal with missing category
    return [
      Meal(
        idMeal: '1',
        strMeal: 'Beef Mechado',
        strCategory: '',
        strArea: area,
        strInstructions: '',
        strMealThumb: '',
        ingredients: [],
        measures: [],
      )
    ];
  }

  @override
  Future<List<Meal>> filterMealsByCategory(String category) async {
    // return a dummy meal tagged with the requested category
    return [
      Meal(
        idMeal: '2',
        strMeal: 'Veggie Dish',
        strCategory: category,
        strArea: 'Filipino',
        strInstructions: '',
        strMealThumb: '',
        ingredients: [],
        measures: [],
      )
    ];
  }

  @override
  Future<Meal?> getMealDetails(String id) async {
    // return same meal with category filled in
    return Meal(
      idMeal: id,
      strMeal: 'Beef Mechado',
      strCategory: 'Beef',
      strArea: 'Filipino',
      strInstructions: 'Cook beef.',
      strMealThumb: '',
      ingredients: [],
      measures: [],
    );
  }
}

void main() {
  test('filterByArea fills missing category from details', () async {
    final provider = RecipeProvider(apiService: FakeApiService());
    await provider.filterByArea('Filipino');
    expect(provider.searchResults, isNotEmpty);
    expect(provider.searchResults.first.strCategory, 'Beef');
  });

  test('vegetables chip uses category filter', () async {
    final provider = RecipeProvider(apiService: FakeApiService());
    // UI label 'Vegetables' corresponds to API query 'Vegetarian'.  The
    // provider should remember the user-friendly category name but we still
    // issue the proper endpoint query.
    await provider.filterByCategory('Vegetables', 'Vegetarian', false);
    expect(provider.searchResults, isNotEmpty);
    // the fake API echoes the query string into the returned meal category
    expect(provider.searchResults.first.strCategory, 'Vegetarian');
    expect(provider.selectedCategory, 'Vegetables');
  });
}
