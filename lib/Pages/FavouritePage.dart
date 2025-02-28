import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Category/ProductCard.dart';
import '../Common/FavoriteProvider.dart';

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Favorites")),
      body: favoriteProvider.favoriteProducts.isEmpty
          ? Center(child: Text("No favorites yet!"))
          : ListView.builder(
        itemCount: favoriteProvider.favoriteProducts.length,
        itemBuilder: (context, index) {
          return ProductCard(ad: favoriteProvider.favoriteProducts[index]);
        },
      ),
    );
  }
}
