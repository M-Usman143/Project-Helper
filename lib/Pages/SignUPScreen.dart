import 'package:flutter/material.dart';
import 'package:isaar/Pages/LoginScreen.dart';
import 'package:isaar/Pages/OtpEmail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Firebase/auth_service.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController(text: "+92");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _phoneError; // Holds the error message for phone input

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Create Account",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),

                // Full Name
                _buildTextField("Full Name", _fullNameController, validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Full name is required";
                  }
                  return null;
                }),
                Row(
                  children: [
                    Container(
                      width: 70, // Fixed width for country code
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: TextField(
                        controller: countryCodeController,
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.center,
                        maxLength: 4,
                        decoration: InputDecoration(
                          counterText: "", // Hides the counter text
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        maxLength: 10, // Restrict to 10 digits
                        decoration: InputDecoration(
                          hintText: "31**********",
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          errorText: _phoneError,
                          counterText: "", // Hides the counter text
                        ),
                        onChanged: (value) {
                          setState(() {
                            _phoneError = (value.length < 10)
                                ? "Number is incomplete"
                                : null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                // Email
                _buildTextField("Email", _emailController,
                    keyboardType: TextInputType.emailAddress, validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email is required";
                      }
                      if (!value.contains("@gmail.com")) {
                        return "Invalid email. Use '@gmail.com'";
                      }
                      return null;
                    }),

                // Password
                _buildTextField("Password", _passwordController, obscureText: true, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password is required";
                  }
                  if (value.length < 8) {
                    return "Password must be at least 8 characters";
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return "Password must have at least one uppercase letter";
                  }
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return "Password must have at least one number";
                  }
                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return "Password must have at least one special character";
                  }
                  return null;
                }),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _signUp,
                  child: Text("Sign Up"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                SizedBox(height: 20),

                // Already have an account? Navigate to Login Page
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    "Already have an account? Log in",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to build Text Fields with validation
  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text, int maxLines = 1, String? Function(String?)? validator}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  // Sign-up function with validation
  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      String name = _fullNameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String phone = "${countryCodeController.text}${_phoneController.text.trim()}";

      if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required")),
      );
      return;
    }
      // Sign up the user
      String? uid = await _authService.signUpUser(name, phone, email, password);

      if (uid != null) {
        await _authService.sendOtpEmail(uid);

        // Store login state in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-up successful!")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreens(email: email),
          ),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-up failed! Try again.")),
        );
      }
    }
  }
}
