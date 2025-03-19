import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<bool> checkIfEmailExists(String email) async {
    try {
      // Check Firebase Auth
      final authMethods = await _auth.fetchSignInMethodsForEmail(email);
      if (authMethods.isNotEmpty) return true;

      // Check Firestore
      final querySnapshot = await _firestore.collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking email existence: $e");
      return false;
    }
  }

  Future<bool> checkIfPhoneExists(String phone) async {
    try {
      final formattedPhone = "+92${phone.replaceAll(RegExp(r'[^0-9]'), '')}";
      final authEmail = "$formattedPhone@phone.com";

      // Check Firebase Auth
      final authMethods = await _auth.fetchSignInMethodsForEmail(authEmail);
      if (authMethods.isNotEmpty) return true;

      // Check Firestore
      final querySnapshot = await _firestore.collection('users')
          .where('phone', isEqualTo: formattedPhone)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking phone existence: $e");
      return false;
    }
  }

  Future<String?> signUpUser(String name, String phone, String email, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.sendEmailVerification();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

// Future<String?> signUpUser(String name, String phone, String email, String password) async {
//   try {
//     // Validate phone format
//     if (!RegExp(r'^\+92\d{10}$').hasMatch(phone)) {
//       return "Phone must be in +92XXXXXXXXXX format";
//     }
//     if (await checkIfEmailExists(email)) return "Email already in use";
//     if (await checkIfPhoneExists(phone)) return "Phone already in use";
//
//     final authEmail = "$phone@phone.com";
//
//     // Create Firebase user
//     UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//       email: authEmail,
//       password: password,
//     );
//
//     // Save user info in Firestore
//     await _firebaseService.saveUser(UserModel(
//       uid: userCredential.user!.uid,
//       name: name,
//       phone: phone,
//       email: email, // Store real email
//     ));
//
//     return null;
//   } catch (e) {
//     return e.toString();
//   }
// }

// Future<User?> signInWithEmail(String email, String password) async {
//   try {
//     UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//     return credential.user;
//   } on FirebaseAuthException catch (e) {
//     print("Auth Error: ${e.code} - ${e.message}");
//     return null;
//   }
// }

}
