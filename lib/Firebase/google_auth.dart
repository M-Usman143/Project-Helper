import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/users_info.dart';
import 'firebase_service.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseService _firebaseService = FirebaseService();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check if this is a new user
        bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

        // If new user or we need to verify email
        if (isNewUser || !user.emailVerified) {
          // Send email verification if not already verified
          if (!user.emailVerified) {
            await user.sendEmailVerification();
          }

          // Save user data to Firestore
          UserModel newUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? "No Name",
            email: user.email ?? "No Email",
            phone: "", // Phone will be added later if needed
          );

          await _firebaseService.saveUser(newUser);
        }
      }

      return user;
    } catch (e) {
      print("Error during Google Sign-In: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

