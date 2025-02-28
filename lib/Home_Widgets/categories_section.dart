import 'package:flutter/material.dart';
import 'AdDetail.dart';

class CategoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {"name": "Food", "icon": Icons.fastfood, "color": Colors.orange.shade100},
    {"name": "Clothes", "icon": Icons.checkroom, "color": Colors.blue.shade100},
    {"name": "Needy Essentials", "icon": Icons.volunteer_activism, "color": Colors.green.shade100},
    {"name": "Medicines", "icon": Icons.medical_services, "color": Colors.purple.shade100},
    {"name": "Blood Donation", "icon": Icons.bloodtype, "color": Colors.redAccent},
    {"name": "Others", "icon": Icons.category, "color": Colors.grey.shade300},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Categories",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdDetailsScreen(
                          categoryName: categories[index]["name"],
                          categoryIcon: categories[index]["icon"],
                          categoryColor: categories[index]["color"],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: categories[index]["color"],
                        child: Icon(categories[index]["icon"], size: 30, color: Colors.black87),
                      ),
                      SizedBox(height: 5),
                      Text(
                        categories[index]["name"],
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
