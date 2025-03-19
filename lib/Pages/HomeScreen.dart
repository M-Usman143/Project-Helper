import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isaar/Common/InternetChecker.dart';
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
  User? get currentUser => FirebaseAuth.instance.currentUser;

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



  // Fetch username from Firestore
  void _fetchUserName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      // Debug the current user state
      print("Current user: ${currentUser?.uid ?? 'null'}");
      print("Current user email: ${currentUser?.email ?? 'null'}");
      print("Is user verified: ${currentUser?.emailVerified ?? 'null'}");

      if (currentUser == null) {
        print("User not logged in");
        setState(() {
          userName = "Guest";
        });
        return;
      }

      String uid = currentUser.uid; // Get current user ID
      print("Fetching user with UID: $uid");
      UserModel? user = await _firebaseService.getUser(uid);
      if (user != null) {
        setState(() {
          userName = user.name;
        });
        print("User name fetched: ${user.name}");
      } else {
        print("User not found in database");
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


  @override
  Widget build(BuildContext context) {
    var categorizedAds = _groupAdsByCategory(filteredAds);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.red,
      statusBarIconBrightness: Brightness.light,
    ));

    return InternetChecker(
      child: Scaffold(
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


  void _fetchAds() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print("User not logged in, can't fetch ads");
        setState(() {
          isLoading = false;
        });
        return;
      }

      String currentUserId = currentUser.uid;
      print("Fetching ads for user: $currentUserId");

      List<AdModel> fetchedAds = await _firestoreService.fetchAds(currentUserId);
      print("Fetched ${fetchedAds.length} ads");

      if (mounted) {
        setState(() {
          ads = fetchedAds;
          filteredAds = fetchedAds;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching ads: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
}
