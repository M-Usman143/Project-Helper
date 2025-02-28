import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Firebase/firebase_service.dart';
import '../Home_Widgets/CategoryListview.dart';
import '../Home_Widgets/categories_section.dart';
import '../models/AdModel.dart';
import '../models/users_info.dart';


class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Loading...";
  final FirebaseService _firebaseService = FirebaseService();
  final FirestoreService _firestoreService = FirestoreService();
  List<AdModel> ads = [];
  List<AdModel> filteredAds = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchAds();

  }

  void _fetchAds() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      List<AdModel> fetchedAds = await _firestoreService.fetchAds(currentUserId);
      setState(() {
        ads = fetchedAds;
        filteredAds = fetchedAds;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching ads: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterAds(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredAds = ads
          .where((ad) =>
      ad.title.toLowerCase().contains(searchQuery) ||
          ad.description.toLowerCase().contains(searchQuery))
          .toList();
    });
  }

  // Group ads by category
  Map<String, List<AdModel>> _groupAdsByCategory(List<AdModel> adList) {
    Map<String, List<AdModel>> categoryMap = {};
    for (var ad in adList) {
      if (ad.category.isEmpty) {
        print("Missing category for ad: ${ad.title}");
      }
      categoryMap.putIfAbsent(ad.category, () => []).add(ad);
    }
    return categoryMap;
  }

  @override
  Widget build(BuildContext context) {
    var categorizedAds = _groupAdsByCategory(filteredAds);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.red,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            CategoriesSection(),
            SizedBox(height: 10),
            for (var entry in categorizedAds.entries)
              CategoryListView(categoryTitle: entry.key, categoryAds: entry.value),

          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(130),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserGreeting(),
                SizedBox(height: 10),
                _buildSearchBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        onChanged: _filterAds,
        decoration: InputDecoration(
          hintText: "Search...",
          prefixIcon: Icon(Icons.search, color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }


  Widget _buildUserGreeting() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Hello, $userName",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Image.asset(
          'assets/images/logo.jpg',
          height: 40,
        ),
      ],
    );
  }

  // Fetch username from Firestore
  Future<void> _fetchUserName() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid; // Get current user ID
      UserModel? user = await _firebaseService.getUser(uid);
      if (user != null) {
        setState(() {
          userName = user.name; // Set the retrieved name
        });
      } else {
        setState(() {
          userName = "User Not Found";
        });
      }
    } catch (e) {
      print("Error fetching user: $e");
      setState(() {
        userName = "Error Loading";
      });
    }
  }

}
