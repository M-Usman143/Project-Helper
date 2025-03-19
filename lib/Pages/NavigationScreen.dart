import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Home_Widgets/bottom_navbar.dart';
import '../Common/InternetChecker.dart';
import 'AboutUsScreen.dart';
import 'HomeScreen.dart';
import 'ProfileScreen.dart';
import 'DonationScreen.dart';


class Navigationscreen extends StatefulWidget {
  final int initialIndex;

  // Constructor with optional initialIndex parameter
  Navigationscreen({this.initialIndex = 0});

  @override
  State<Navigationscreen> createState() => _NavigationscreenState();
}

class _NavigationscreenState extends State<Navigationscreen> {
  late int _selectedIndex;
  // List of pages for navigation
  final List<Widget> _pages = [
    HomeScreen(),
    MyAdsScreen(),
    AboutUsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Use the initialIndex provided by the widget
    _selectedIndex = widget.initialIndex;
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      // If not on the home tab, go to the home tab
      setState(() {
        _selectedIndex = 0;
      });
      return false; // Don't exit the app
    }
    return true; // Allow exiting the app if already on home tab
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.red,
      statusBarIconBrightness: Brightness.light,
    ));

    return WillPopScope(
      onWillPop: _onWillPop,
      child: InternetChecker(
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onNavBarTapped,
          ),
        ),
      ),
    );
  }
}
