// lib/providers/recipe_provider.dart
import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../services/api_service.dart';

class RecipeProvider with ChangeNotifier {
  final ApiService _apiService;

  /// Accept a custom [ApiService] for testing; defaults to real implementation.
  RecipeProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  List<Meal> _searchResults = [];
  List<Meal> get searchResults => _searchResults;

  Meal? _selectedMeal;
  Meal? get selectedMeal => _selectedMeal;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedArea = 'All';
  String get selectedArea => _selectedArea;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  Future<void> filterByArea(String area) async {
    _selectedArea = area;
    _selectedCategory = null; // Clear sub-category filter when area changes
    if (area == 'All') {
      // Clear filter by searching for default or empty. We'll load the default 'chicken'
      searchRecipes('chicken');
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _apiService.filterMealsByArea(area);
      // area is known, but category may still be missing on filter results
      await _fillMissingAreasAndCategories();
    } catch (e) {
      _errorMessage = 'Failed to fetch recipes by area.';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByCategory(String label, String endpointQuery, bool isIngredient) async {
    // ingredient filters should not be restricted by cuisine area
    if (isIngredient) {
      _selectedArea = 'All';
    }
    _selectedCategory = label;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isIngredient) {
        _searchResults = await _apiService.filterMealsByIngredient(endpointQuery);
      } else {
        _searchResults = await _apiService.filterMealsByCategory(endpointQuery);
      }
      // after getting base list, ensure each meal has a valid area *and*
      // category by fetching details when necessary (filter endpoints may
      // omit those fields)
      await _fillMissingAreasAndCategories();
    } catch (e) {
      _errorMessage = 'Failed to fetch recipes by category.';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fillMissingAreasAndCategories() async {
    // fetch details for any meal with missing area *or* missing category; the
    // filter endpoints often omit these fields, which leads to "Unknown"
    // labels in the UI (e.g. Beef Mechado showed up with no category).  We
    // are already performing an extra request here; it's a reasonable cost to
    // make the UX less confusing.
    final needsDetail = _searchResults.where((m) {
      return m.strArea.isEmpty || m.strArea == 'Unknown Area' ||
          m.strCategory.isEmpty || m.strCategory == 'Unknown Category';
    }).toList();
    if (needsDetail.isEmpty) return;

    for (var meal in needsDetail) {
      try {
        final detail = await _apiService.getMealDetails(meal.idMeal);
        if (detail != null) {
          final index = _searchResults.indexWhere((m) => m.idMeal == meal.idMeal);
          if (index != -1) {
            _searchResults[index] = detail;
          }
        }
      } catch (_) {
        // ignore individual failures
      }
    }
  }

  Future<void> searchRecipes(String query) async {
    _selectedArea = 'All'; // Reset filter explicitly
    _selectedCategory = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchMeals(query);
    } catch (e) {
      _errorMessage = 'Failed to fetch recipes. Please try again later.';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMealDetails(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedMeal = await _apiService.getMealDetails(id);
    } catch (e) {
      _errorMessage = 'Failed to fetch meal details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearSelectedMeal() {
    _selectedMeal = null;
    notifyListeners();
  }
}
