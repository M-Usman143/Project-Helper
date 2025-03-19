import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Firebase/firebase_service.dart';
import '../Home_Widgets/indicatorScreen.dart';
import '../models/users_info.dart';

class VerificationDialog extends StatefulWidget {
  final String name;
  final String phone;
  final String email;

  const VerificationDialog({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
  });

  @override
  _VerificationDialogState createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<VerificationDialog> {
  bool _isVerified = false;
  Timer? _timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _checkVerification();
    });
    _checkVerification();
  }

  Future<void> _checkVerification() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        if (_timer?.isActive ?? false) {
          _timer?.cancel();
        }

        // Save user to Firestore
        final userModel = UserModel(
          uid: user.uid,
          name: widget.name,
          phone: widget.phone,
          email: widget.email,
        );

        await FirebaseService().saveUser(userModel);

        if (mounted) {
          setState(() {
            _isVerified = true;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: FractionallySizedBox(
        widthFactor: 0.9, // Increased width
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25), // Increased padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Please Verify Your Email",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Increased font size
              ),
              const SizedBox(height: 25),
              Icon(
                _isVerified ? Icons.verified : Icons.pending_actions,
                color: _isVerified ? Colors.green : Colors.grey,
                size: 65, // Increased icon size
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_isVerified) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => indicatorScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please verify your email first"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(
                  "Proceed",
                  style: TextStyle(color: Colors.white, fontSize: 18), // Increased text size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
