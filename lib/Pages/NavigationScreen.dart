import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Home_Widgets/CategoryListview.dart';
import '../Home_Widgets/bottom_navbar.dart';
import '../Home_Widgets/categories_section.dart';
import '../ProductData/ProductData.dart';
import 'AboutUsScreen.dart';
import 'DonationScreen.dart';
import 'HomeScreen.dart';
import 'ProfileScreen.dart';


class Navigationscreen extends StatefulWidget {
  @override
  State<Navigationscreen> createState() => _NavigationscreenState();
}

class _NavigationscreenState extends State<Navigationscreen> {
  int _selectedIndex = 0;
  // List of pages for navigation
  final List<Widget> _pages = [
    HomeScreen(),
    MyAdsScreen(),
    AboutUsScreen(),
    ProfileScreen(),
  ];
  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.red,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavBarTapped,
      ),
    );
  }

}
