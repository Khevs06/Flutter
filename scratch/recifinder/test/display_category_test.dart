import 'package:flutter_test/flutter_test.dart';
import 'package:recifinder/widgets/recipe_card.dart';

void main() {
  test('vegetarian category shown as Vegetables for Filipino area', () {
    expect(RecipeCard.displayCategory('Vegetarian', 'Filipino'), 'Vegetables');
    expect(RecipeCard.displayCategory('vegetarian', 'Filipino'), 'Vegetables');
    expect(RecipeCard.displayCategory('Vegetarian', 'American'), 'Vegetarian');
  });
}
