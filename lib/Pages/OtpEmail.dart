import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OtpScreens extends StatefulWidget {
  final String email;
  OtpScreens({required this.email});

  @override
  _OtpScreensState createState() => _OtpScreensState();
}

class _OtpScreensState extends State<OtpScreens> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  String? _storedOtp;

  @override
  void initState() {
    super.initState();
    _sendOtp(); // Send OTP when screen loads
  }

  Future<void> _sendOtp() async {
    try {
      final result = await _functions.httpsCallable('sendOtpEmail').call({
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });

      if (result.data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP sent to ${widget.email}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send OTP")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final enteredOtp = _otpController.text;

    try {
      final doc = await FirebaseFirestore.instance.collection("otps").doc(widget.email).get();

      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP expired or incorrect")));
        return;
      }

      final storedOtp = doc.data()?['otp'];
      final expiresAt = doc.data()?['expiresAt'];

      if (storedOtp == enteredOtp && DateTime.now().millisecondsSinceEpoch < expiresAt) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP Verified!")));
        Navigator.pushReplacementNamed(context, "/home");

        // Optional: Delete OTP after successful verification
        await FirebaseFirestore.instance.collection("otps").doc(widget.email).delete();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid or expired OTP")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify OTP")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Enter OTP sent to ${widget.email}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(labelText: "Enter OTP"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _verifyOtp, child: Text("Verify OTP")),
          ],
        ),
      ),
    );
  }
}
