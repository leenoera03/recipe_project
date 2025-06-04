import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeService {
  static const String baseUrl = 'https://dummyjson.com/recipes';

  // Get all recipes
  static Future<Recipe> getAllRecipes() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        return Recipe.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get single recipe
  static Future<Recipes> getRecipeById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        return Recipes.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load recipe');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Add new recipe
  static Future<Recipes> addRecipe(Recipes recipe) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(recipe.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Recipes.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to add recipe');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update recipe
  static Future<Recipes> updateRecipe(int id, Recipes recipe) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(recipe.toJson()),
      );

      if (response.statusCode == 200) {
        return Recipes.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update recipe');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete recipe
  static Future<bool> deleteRecipe(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete recipe');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}