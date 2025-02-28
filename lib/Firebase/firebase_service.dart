import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/AdModel.dart';
import '../models/users_info.dart';


class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save user data to Firestore
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection("users").doc(user.uid).set(user.toJson());
    } catch (e) {
      print("Error saving user: $e");
    }
  }

  // Retrieve user data from Firestore
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("users").doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
    return null;
  }
}


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveAd(String userId, AdModel ad) async {
    try {
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("ads")
          .doc(ad.adId)
          .set(ad.toMap())
          .then((_) => print("Ad successfully saved"))
          .catchError((error) => print("Error saving ad: $error"));
    } catch (e) {
      print("Firestore Error: $e");
    }
  }

  Future<List<AdModel>> fetchAds(String currentUserId) async {
    try {
      List<AdModel> adsList = [];
      QuerySnapshot usersSnapshot = await _firestore.collection("users").get();

      for (var userDoc in usersSnapshot.docs) {
        QuerySnapshot adsSnapshot =
        await userDoc.reference.collection("ads").get();

        // Exclude ads from the current user
        if (userDoc.id != currentUserId) {
          QuerySnapshot adsSnapshot =
          await userDoc.reference.collection("ads").get();

          for (var adDoc in adsSnapshot.docs) {
            AdModel ad = AdModel.fromJson(adDoc.data() as Map<String, dynamic>);
            adsList.add(ad);
          }
        }

      }

      return adsList;
    } catch (e) {
      print("Error fetching ads: $e");
      return [];
    }
  }




  Future<List<AdModel>> fetchUserAds(String userId) async {
    try {
      QuerySnapshot adsSnapshot = await _firestore
          .collection("users")
          .doc(userId)
          .collection("ads")
          .get();

      return adsSnapshot.docs
          .map((doc) => AdModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching user ads: $e");
      return [];
    }
  }

  Future<void> updateAd(String userId, String adId, String newTitle, String newDescription) async {
    try {
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("ads")
          .doc(adId)
          .update({
        'title': newTitle,
        'description': newDescription,
      });
    } catch (e) {
      print("Error updating ad: $e");
    }
  }

  Future<void> deleteAd(String userId, String adId) async {
    try {
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("ads")
          .doc(adId)
          .delete();
    } catch (e) {
      print("Error deleting ad: $e");
    }
  }



}

