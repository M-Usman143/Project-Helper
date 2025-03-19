import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isaar/models/AdModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider with ChangeNotifier {
  final List<AdModel> _favoriteProducts = [];

  final Set<String> _favoriteIds = {};
  static const String _favoritesKey = 'favorite_ads';

  FavoriteProvider() {
    _loadFavorites();
  }
  List<AdModel> get favoriteProducts => _favoriteProducts;
  Set<String> get favoriteIds => _favoriteIds;

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList(_favoritesKey) ?? [];

    _favoriteIds.clear();
    _favoriteProducts.clear();

    for (String jsonAd in savedFavorites) {
      try {
        _favoriteIds.add(jsonDecode(jsonAd)["adId"]);
        _favoriteProducts.add(AdModel.fromJson(jsonDecode(jsonAd)));
      } catch (e) {
        print("Error loading favorite ad: $e");
      }
    }

    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favList = _favoriteProducts.map((ad) => jsonEncode(ad.toMap())).toList();
    await prefs.setStringList(_favoritesKey, favList);
  }

  void toggleFavorite(AdModel ad) {
    if (_favoriteIds.contains(ad.adId)) {
      _favoriteIds.remove(ad.adId);
      _favoriteProducts.removeWhere((item) => item.adId == ad.adId);
    } else {
      _favoriteIds.add(ad.adId);
      _favoriteProducts.add(ad);
    }

    _saveFavorites();
    notifyListeners();
  }


  bool isFavorite(AdModel ad) {
    return _favoriteIds.contains(ad.adId);
  }
}
