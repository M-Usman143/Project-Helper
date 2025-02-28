import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:isaar/Pages/LoginScreen.dart';
import 'package:isaar/Common//Privacy Policy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Firebase/firebase_service.dart';
import '../models/users_info.dart';
import 'FavouritePage.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String userName = "Loading...";
  String userEmail = "example@gmail.com";



  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }


  Future<void> _fetchUserName() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      UserModel? user = await _firebaseService.getUser(uid);
      if (user != null) {
        setState(() {
          userName = user.name;
          userEmail = user.email;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Profile Section
          Center(
            child: Column(
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/images/profileimagee.png"),
                ),
                SizedBox(height: 10),
                Text(
                  userName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    child: Text("Edit Profile", style: TextStyle(color: Colors.black, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),
          // Settings List
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  buildMenuItem(context, Icons.privacy_tip, "Privacy Policy", () {
                    showPrivacyPolicy(context);
                  }),
                  buildMenuItem(context, Icons.favorite, "Favourite", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FavoritePage()),
                    );

                  }),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey),
                  SizedBox(height: 10),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text("Logout", style: TextStyle(color: Colors.red, fontSize: 16)),
                    onTap: () => logout(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
