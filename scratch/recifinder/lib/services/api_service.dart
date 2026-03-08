// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class ApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Meal>> filterMealsByArea(String area) async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?a=$area'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List).map((json) {
          json['strArea'] = area; // Inject known area from filter
          return Meal.fromJson(json);
        }).toList();
      } else {
        return []; // No meals found
      }
    } else {
      throw Exception('Failed to filter meals by area');
    }
  }

  Future<List<Meal>> filterMealsByIngredient(String ingredient) async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?i=$ingredient'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List).map((json) => Meal.fromJson(json)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to filter meals by ingredient');
    }
  }

  Future<List<Meal>> filterMealsByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?c=$category'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List).map((json) => Meal.fromJson(json)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to filter meals by category');
    }
  }

  Future<List<Meal>> searchMeals(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search.php?s=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List).map((json) => Meal.fromJson(json)).toList();
      } else {
        return []; // No meals found
      }
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<Meal?> getMealDetails(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/lookup.php?i=$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null && (data['meals'] as List).isNotEmpty) {
        return Meal.fromJson(data['meals'][0]);
      }
      return null;
    } else {
      throw Exception('Failed to load meal details');
    }
  }
}
