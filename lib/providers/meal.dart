import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meal_app_provider/models/meal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dummy_data.dart';

class MealProvider with ChangeNotifier {
  Map<String, bool> filters = {
    'gluten': false,
    'lactose': false,
    'vegan': false,
    'vegetarian': false,
  };
  List<String> allKeys = [];
  var availableMeals = DUMMY_MEALS;
  List<Meal> favoriteMeals = [];

  void setFilters() async {
    availableMeals = DUMMY_MEALS.where((meal) {
      if ((filters['gluten'] ?? false) && !meal.isGlutenFree) {
        return false;
      }
      if ((filters['lactose'] ?? false) && !meal.isLactoseFree) {
        return false;
      }
      if ((filters['vegan'] ?? false) && !meal.isVegan) {
        return false;
      }
      if ((filters['vegetarian'] ?? false) && !meal.isVegetarian) {
        return false;
      }
      return true;
    }).toList();
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('gluten', filters['gluten'] ?? false);
    prefs.setBool('lactose', filters['lactose'] ?? false);
    prefs.setBool('vegan', filters['vegan'] ?? false);
    prefs.setBool('vegetarian', filters['vegetarian'] ?? false);
    notifyListeners();

  }

  getFilterData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    filters['gluten'] = prefs.getBool('gluten');
    filters['lactose'] = prefs.getBool('lactose');
    filters['vegan'] = prefs.getBool('vegan');
    filters['vegetarian'] = prefs.getBool('vegetarian');
    allKeys = prefs.getStringList('allKeys') ?? [];
    for (var mealId in allKeys) {
      final int existingIndex =
          favoriteMeals.indexWhere((element) => element.id == mealId);
      if (existingIndex < 0) {
        favoriteMeals
            .add(DUMMY_MEALS.where((element) => element.id == mealId).first);
      }
    }
    notifyListeners();
  }

  bool isMealFavoriteV;
  void toggleFavorite(String mealId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final int existingIndex =
        favoriteMeals.indexWhere((meal) => meal.id == mealId);
    if (existingIndex >= 0) {
      favoriteMeals.removeAt(existingIndex);
      allKeys.remove(mealId);
    } else {
      favoriteMeals.add(
        DUMMY_MEALS.firstWhere((meal) => meal.id == mealId),
      );
      allKeys.add(mealId);
    }

    notifyListeners();
    prefs.setStringList('allKeys', allKeys);
    notifyListeners();

  }

  bool isMealFavorite(String id) {
    isMealFavoriteV = favoriteMeals.any((meal) => meal.id == id);

    return isMealFavoriteV;
  }
}
