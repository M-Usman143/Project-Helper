import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:isaar/Pages/LoginScreen.dart';
import 'package:isaar/Common//Privacy Policy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Firebase/firebase_service.dart';
import '../models/users_info.dart';
import '../Common/InternetChecker.dart';
import 'NavigationScreen.dart';
import 'FavouritePage.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userName = "Loading...";
  String userEmail = "example@gmail.com";
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print("Profile: User not logged in");
        setState(() {
          userName = "Guest";
          userEmail = "Please log in";
        });
        return;
      }

      String uid = currentUser.uid;
      print("Profile: Fetching user with UID: $uid");
      UserModel? user = await _firebaseService.getUser(uid);
      if (user != null) {
        setState(() {
          userName = user.name;
          userEmail = user.email;
        });
        print("Profile: User data fetched: ${user.name}, ${user.email}");
      } else {
        print("Profile: User not found in database");
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

  void _showChangeNameDialog() {
    _nameController.text = userName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change Name"),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: "New Name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await _updateUserName(_nameController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserName(String newName) async {
    setState(() => _isLoading = true);
    try {
      String uid = _auth.currentUser!.uid;
      bool success = await _firebaseService.updateUserName(uid, newName);
      if (success) {
        setState(() {
          userName = newName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Name updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update name")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account"),
        content: Text("Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => _isLoading = true);
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;

        // Delete user from Firestore
        await _firebaseService.deleteUser(uid);

        // Delete user from Firebase Authentication
        await user.delete();

        // Clear shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to NavigationScreen with Home tab selected
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Navigationscreen(initialIndex: 0)),
        );
        return false; // Prevent default back behavior
      },
      child: InternetChecker(
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.red,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Navigate to NavigationScreen with Home tab selected
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Navigationscreen(initialIndex: 0)),
                );
              },
            ),
            title: Text(
              "Profile",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.red))
              : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
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
                        ElevatedButton.icon(
                          icon: Icon(Icons.edit, size: 16),
                          label: Text("Edit Profile"),
                          onPressed: _showChangeNameDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),
                  // Settings List
                  Padding(
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
                        ListTile(
                          leading: Icon(Icons.delete_forever, color: Colors.red),
                          title: Text("Delete Account", style: TextStyle(color: Colors.red, fontSize: 16)),
                          onTap: _showDeleteAccountDialog,
                        ),
                        // Add extra space at the bottom to ensure everything is visible with keyboard
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void logout(BuildContext context) async {
    checkInternetBeforeAction(context, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await FirebaseAuth.instance.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }
}
