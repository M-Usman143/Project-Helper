import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:isaar/Firebase/auth_service.dart';
import 'package:isaar/Home_Widgets/indicatorScreen.dart';
import 'package:isaar/Pages/SignUPScreen.dart';
import '../Common/InternetChecker.dart';
import '../Common/EmailVerificationDialog.dart';
import '../Firebase/google_auth.dart';
import '../Firebase/firebase_service.dart';
import '../models/users_info.dart';
import 'ForgetPassward.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final TextEditingController _identifiercontroller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _emailError = false;
  bool _passwordError = false;
  String _errorMessage = "";
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: MainBody(context),
    );
  }
//Main Body----------------------------------
  Stack MainBody(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            "assets/images/logoimg.jpg",
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: 70),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: _identifiercontroller,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.black54),
                        prefixIcon: Icon(Icons.email, color: Colors.black54),
                        errorText: _emailError ? "Enter 10-digit number after +92" : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black54),
                        prefixIcon: Icon(Icons.email, color: Colors.black54),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: _passwordError ? "Please enter password" : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_errorMessage.isNotEmpty)
                      Center(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () {checkInternetBeforeAction(context, _handleLogin, isLoading: _isLoading);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Center(
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Login',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // // Divider with text
                    // Row(
                    //   children: [
                    //     Expanded(child: Divider(color: Colors.grey.shade400)),
                    //     Padding(
                    //       padding: EdgeInsets.symmetric(horizontal: 10),
                    //       child: Text("OR", style: TextStyle(color: Colors.grey.shade600)),
                    //     ),
                    //     Expanded(child: Divider(color: Colors.grey.shade400)),
                    //   ],
                    // ),
                    //
                    // SizedBox(height: 20),

                    // // Updated Google Sign-In Button
                    // Center(
                    //   child: ElevatedButton.icon(
                    //     icon: Image.asset(
                    //       'assets/images/google.png',
                    //       height: 24.0,
                    //       width: 24.0,
                    //     ),
                    //     label: Text(
                    //       '--------Sign up With Google-------',
                    //       style: TextStyle(fontSize: 16, color: Colors.black87),
                    //     ),
                    //     onPressed: () => checkInternetBeforeAction(
                    //         context,
                    //             () => _handleGoogleSignIn(context),
                    //         isLoading: _isLoading
                    //     ),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.white,
                    //       foregroundColor: Colors.black,
                    //       minimumSize: Size(double.infinity, 50), // Match login button width
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(10),
                    //         side: BorderSide(color: Colors.grey.shade300),
                    //       ),
                    //       padding: EdgeInsets.symmetric(vertical: 15),
                    //     ),
                    //   ),
                    // ),

                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpPage()),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

//Login Handling----------------
  void _handleLogin() async {
    final email = _identifiercontroller.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _emailError = false;
      _passwordError = false;
      _errorMessage = "";
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _emailError = email.isEmpty;
        _passwordError = password.isEmpty;
        _errorMessage = "Please fill all fields";
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use signInWithEmailAndPassword instead of signUpUser for login
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        print("Login successful: ${user.uid}");

        // Store login state in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => indicatorScreen()),
        );
      } else {
        setState(() {
          _errorMessage = "Invalid credentials";
          _emailError = true;
          _passwordError = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      print("Login error: ${e.code} - ${e.message}");
      setState(() {
        _errorMessage = _mapAuthError(e.code);
        _emailError = true;
        _passwordError = true;
      });
    } catch (e) {
      print("Unexpected login error: $e");
      setState(() {
        _errorMessage = "Authentication failed";
        _emailError = true;
        _passwordError = true;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
//error Message Auth's----------------
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return "Account not found";
      case 'wrong-password':
        return "Incorrect password";
      case 'invalid-email':
        return "Invalid email/phone format";
      default:
        return "Authentication failed";
    }
  }



  void _handleGoogleSignIn(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      User? user = await _googleAuthService.signInWithGoogle();

      if (user != null) {
        print("Google sign-in successful: ${user.uid}");

        // Store login state in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        // Check if email is verified
        await user.reload();
        if (user.emailVerified) {
          // Email is verified, navigate to indicator screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => indicatorScreen()),
          );
        } else {
          // Email is not verified, show verification dialog
          UserModel? userModel = await FirebaseService().getUser(user.uid);

          if (userModel != null) {
            setState(() => _isLoading = false);

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => VerificationDialog(
                name: userModel.name,
                phone: userModel.phone,
                email: userModel.email,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to retrieve user data")),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign-In failed!")),
        );
      }
    } catch (e) {
      print("Google sign-in error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
