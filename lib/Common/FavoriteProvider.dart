import 'package:flutter/material.dart';
import 'package:isaar/models/AdModel.dart';

class FavoriteProvider with ChangeNotifier {
  final List<AdModel> _favoriteProducts = [];

  List<AdModel> get favoriteProducts => _favoriteProducts;

  void toggleFavorite(AdModel ad) {
    if (_favoriteProducts.contains(ad)) {
      _favoriteProducts.remove(ad);
    } else {
      _favoriteProducts.add(ad);
    }
    notifyListeners();
  }

  bool isFavorite(AdModel ad) {
    return _favoriteProducts.contains(ad);
  }
}
