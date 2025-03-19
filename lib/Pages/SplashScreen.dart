import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home_Widgets/indicatorScreen.dart';
import 'OnBoardingScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _imageAnimation;
  late Animation<Offset> _textAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _imageAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _textAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    // Check if the user is already logged in
    _checkLoginStatus();
  }


  void _checkLoginStatus() async {
    // Check Firebase Auth state
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Also check SharedPreferences as a backup
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedInPref = prefs.getBool('isLoggedIn') ?? false;

    bool isLoggedIn = currentUser != null || isLoggedInPref;

    print("Auth check - Firebase user: ${currentUser?.uid ?? 'null'}");
    print("Auth check - SharedPreferences: $isLoggedInPref");

    // If Firebase shows logged in but SharedPreferences doesn't, update SharedPreferences
    if (currentUser != null && !isLoggedInPref) {
      await prefs.setBool('isLoggedIn', true);
      print("Updated SharedPreferences login state to true");
    }

    Timer(Duration(seconds: 4), () {
      if (isLoggedIn) {
        print("User is logged in, navigating to indicatorScreen");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => indicatorScreen()),
        );
      } else {
        print("User is not logged in, navigating to OnboardingScreen");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      }
    });
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: _imageAnimation,
                child: Image.asset('assets/images/logo.jpg', width: 200, height: 150),
              ),
              SizedBox(height: 20),
              SlideTransition(
                position: _textAnimation,
                child: Text(
                  'Isaar Foundation',
                  style:TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}