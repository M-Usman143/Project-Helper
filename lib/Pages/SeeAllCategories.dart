import 'package:flutter/material.dart';
import 'package:isaar/models/AdModel.dart';
import '../Category/ProductCard.dart';

class SeeAllPage extends StatefulWidget {
  final List<AdModel> ad;
  final String categoryName;
  SeeAllPage({required this.ad, required this.categoryName});

  @override
  State<SeeAllPage> createState() => _SeeAllPageState();
}

class _SeeAllPageState extends State<SeeAllPage> {
  List<AdModel> filteredAds = [];
  String searchQuery = "";


  @override
  void initState() {
    super.initState();
    filteredAds = widget.ad; // Initialize filteredAds with all ads
  }

  void _filterAds(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredAds = widget.ad
          .where((ad) =>
      ad.title.toLowerCase().contains(searchQuery) ||
          ad.description.toLowerCase().contains(searchQuery))
          .toList();
    });
  }


  Widget _buildSearchBar() {
    return Container(
      height: 50, // Increased height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        onChanged: _filterAds, // Apply search filter
        decoration: InputDecoration(
          hintText: "Search products...",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display number of results
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Showing ${filteredAds.length} results for \"${widget.categoryName}\"",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          // Product Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.6, // Adjust for better UI
                ),
                itemCount: filteredAds.length,
                itemBuilder: (context, index) {
                  return ProductCard(ad: filteredAds[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom App Bar with increased height
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(80),
      child: AppBar(
        backgroundColor: Colors.red,
        title: _buildSearchBar(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
