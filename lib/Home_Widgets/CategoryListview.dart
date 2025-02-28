import 'package:flutter/material.dart';
import '../Category/ProductCard.dart';
import '../Pages/SeeAllCategories.dart';
import '../models/AdModel.dart';

class CategoryListView extends StatelessWidget {
  final String categoryTitle;
  final List<AdModel> categoryAds;

  CategoryListView({required this.categoryTitle, required this.categoryAds});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Title with "See All"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SeeAllPage(ad: categoryAds,
                        categoryName: categoryTitle)),
                  );
                },
                child: Text(
                  "See All",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),

          // Horizontal ListView for Products
          SizedBox(
            height: 290, // Adjust height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categoryAds.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 200,
                  margin: EdgeInsets.only(right: 12),
                  child: ProductCard(ad: categoryAds[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
