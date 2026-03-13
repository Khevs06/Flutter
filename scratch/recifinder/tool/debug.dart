// ignore_for_file: avoid_print
import 'package:recifinder/services/api_service.dart';

Future<void> main() async {
  final api = ApiService();

  for (var cat in ['Vegetables', 'Vegetarian', 'Seafood', 'Beef']) {
    print('category $cat');
    final list = await api.filterMealsByCategory(cat);
    print('  count: ${list.length}');
  }

  print('ingredient eggplant');
  final ing = await api.filterMealsByIngredient('eggplant');
  print('  count: ${ing.length}');
}
