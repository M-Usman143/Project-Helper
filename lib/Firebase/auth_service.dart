import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/users_info.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  // Sign Up User & Store Data in Firestore
  Future<String?> signUpUser(String name, String phone, String email, String password) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Create user model
      UserModel newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
      );

      // Store user data in Firestore
      await _firebaseService.saveUser(newUser);

      return uid; // Return the UID upon success
    } catch (e) {
      return e.toString(); // Return error message if failure occurs
    }
  }

  // Sign In User
  Future<String?> signInUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } catch (e) {
      return e.toString(); // Error message
    }
  }

  Future<void> sendOtpEmail(String uid) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendOtpEmail');
      final response = await callable.call({'userId': uid});

      if (response.data['success']) {
        print("OTP sent successfully.");
      } else {
        print("Failed to send OTP: ${response.data['message']}");
      }
    } catch (e) {
      print("Error calling Cloud Function: $e");
    }
  }
}
