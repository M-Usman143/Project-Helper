import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isaar/Home_Widgets/indicatorScreen.dart';
import 'package:isaar/Pages/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common/InternetChecker.dart';
import '../Firebase/auth_service.dart';
import '../Common/EmailVerificationDialog.dart';

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
  String? _phoneError;
  String? _emailError;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: buildGestureDetector(context),
    );
  }
//Main Body---------------------------------
  GestureDetector buildGestureDetector(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
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
                  // Full Name Field
                  _buildTextField(
                    label: "Full Name",
                    controller: _fullNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Full name is required";
                      }
                      return null;
                    },
                    // Add optional parameters with default values
                    errorText: null,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {},
                  ),
                  Row(
                    children: [
                      Container(
                        width: 70,
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
                            counterText: "",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
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
                            counterText: "",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Phone required";
                            if (value.length != 10) return "Number is incomplete";
                            return null;
                          },
                          onChanged: (value) async {
                            if (value.length == 10) {
                              final exists = await _authService.checkIfPhoneExists(value);
                              setState(() => _phoneError = exists ? "Number already in use" : null);
                            } else {
                              setState(() => _phoneError ="Number is incomplete");
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  _buildTextField(
                    label: "Email",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Email required";
                      if (!value.endsWith("@gmail.com")) return "Use @gmail.com";
                      return null;
                    },
                    onChanged: (value) async {
                      if (value.contains("@gmail.com")) {
                        final exists = await _authService.checkIfEmailExists(value);
                        setState(() => _emailError = exists ? "Email already in use" : null);
                      } else {
                        setState(() => _emailError = null);
                      }
                    },
                  ),
                  // Password Field
                  _buildTextField(
                    label: "Password",
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.text,
                    errorText: null,
                    onChanged: (value) {},
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Password required";
                      if (value.length < 8) return "At least 8 characters";
                      if (!RegExp(r'[A-Z]').hasMatch(value)) return "Uppercase letter required";
                      if (!RegExp(r'[0-9]').hasMatch(value)) return "Number required";
                      if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
                        return "Special character required";
                      }
                      return null;
                    },
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
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () {
                        checkInternetBeforeAction(context, _signUp, isLoading: _isLoading);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : Text("Sign Up", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())),
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
      ),
    );
  }
//Hanlding Textfields---------------------------------
  Widget _buildTextField({
    bool obscureText = false,
    required String label,
    required TextEditingController controller,
    required String? errorText,
    required TextInputType keyboardType,
    required String? Function(String?)? validator,
    required void Function(String)? onChanged,
    AutovalidateMode? autovalidateMode,
    Widget? suffixIcon,

  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        autovalidateMode: autovalidateMode,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
  //Handling Signups------------------------
  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_emailError != null || _phoneError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fix validation errors")),
        );
        return;
      }

      setState(() => _isLoading = true);

      final name = _fullNameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text.trim();

      try {
        // Final duplicate check
        final emailExists = await _authService.checkIfEmailExists(email);
        final phoneExists = await _authService.checkIfPhoneExists(phone);

        if (emailExists || phoneExists) {
          String message = "";
          if (emailExists) message = "Email already in use";
          if (phoneExists) message = "Phone already in use";
          if (emailExists && phoneExists) message = "Both email and phone are already in use";

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          setState(() => _isLoading = false);
          return;
        }

        // Sign up user
        final error = await _authService.signUpUser(name, phone, email, password);
        if (error == null) {
          // Show verification dialog directly
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => VerificationDialog(
              name: name,
              phone: phone,
              email: email,
            ),
          ).then((_) async {
            // Save login state after email verification
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);

            // Navigate to indicator screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => indicatorScreen()),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Signup failed: $error")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred. Please try again.")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

}