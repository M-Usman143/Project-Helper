import 'package:flutter/material.dart';
import 'dart:async';
import 'package:isaar/Pages/NavigationScreen.dart';


class indicatorScreen extends StatefulWidget {
  @override
  _indicatorScreenState createState() => _indicatorScreenState();
}

class _indicatorScreenState extends State<indicatorScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Navigationscreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to red
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.red, // Progress indicator color
        ),
      ),
    );
  }
}
