import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  OtpScreen({required this.phoneNumber});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    _sendOtp(); // Send OTP when the screen loads
  }

  Future<void> _sendOtp() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Auto sign-in successful")),
        );
        Navigator.pushReplacementNamed(context, "/home");
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP Sent")),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP verification failed. Try again.")),
      );
      return;
    }

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: _otpController.text,
    );

    try {
      await _auth.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Verified!")),
      );
     // Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E9C9),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
        Text(
        "Enter OTP sent to ${widget.phoneNumber}",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () {}, // Add functionality if needed
                ),
              ),
              Image.asset(
                'assets/lock.png', // Replace with actual asset
                height: 80,
              ),
              const SizedBox(height: 10),
              const Text(
                "Enter OTP Code",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, "
                    "sed do eiusmod tempor incididunt ut labore.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              PinCodeTextField(
                controller: _otpController,
                length: 6,
                appContext: context,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 45,
                  inactiveColor: Colors.grey[300]!,
                  activeColor: Colors.black,
                  selectedColor: Colors.black,
                  inactiveFillColor: Colors.white,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  borderWidth: 1,
                ),
                enableActiveFill: true,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {}, // Add resend functionality
                child: const Text(
                  "Resend Code",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _verifyOtp,
                  child: const Text(
                    "Verify Code",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
       ]
      ),
    ),
    );
  }
}




// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(title: Text("Verify OTP")),
//     body: Padding(
//       padding: EdgeInsets.all(20.0),
//       child: Column(
//         children: [
//           Text(
//             "Enter OTP sent to ${widget.phoneNumber}",
//             style: TextStyle(fontSize: 16),
//           ),
//           SizedBox(height: 20),
//           TextField(
//             controller: _otpController,
//             decoration: InputDecoration(labelText: "Enter OTP"),
//             keyboardType: TextInputType.number,
//           ),
//           SizedBox(height: 10),
//           ElevatedButton(
//             onPressed: _verifyOtp,
//             child: Text("Verify OTP"),
//           ),
//         ],
//       ),
//     ),
//   );
// }

