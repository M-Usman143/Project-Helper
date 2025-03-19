import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Common/InternetChecker.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    checkInternetBeforeAction(context, () async {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
        _showDialog("Success", "A password reset link has been sent to your email.");
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (title == "Success") {
                Navigator.pop(context); // Go back to the login screen
              }
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InternetChecker(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Forgot Password"),
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Enter your email to receive a password reset link",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  errorText: _errorMessage,
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _resetPassword,
                child: Text("Reset Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
