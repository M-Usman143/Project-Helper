import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      return snapshot.docs.isEmpty
          ? null
          : UserModel.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      print("Error fetching user by email: $e");
      return null;
    }
  }

  Future<UserModel?> getUserByPhone(String phone) async {
    final snapshot = await _firestore
        .collection("users")
        .where("phone", isEqualTo: phone)
        .limit(1)
        .get();
    return snapshot.docs.isEmpty
        ? null
        : UserModel.fromJson(snapshot.docs.first.data());
  }



  // Retrieve user data from Firestore
  Future<UserModel?> getUser(String uid) async {
    try {
      print("Attempting to fetch user with UID: $uid");
      DocumentSnapshot doc = await _firestore.collection("users").doc(uid).get();
      print("Document exists: ${doc.exists}");

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print("User data: $data");
        return UserModel.fromJson(data);
      } else {
        print("No document found for user with UID: $uid");
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
    return null;
  }

  // Update user's name in Firestore
  Future<bool> updateUserName(String uid, String newName) async {
    try {
      await _firestore.collection("users").doc(uid).update({
        'name': newName,
      });
      return true;
    } catch (e) {
      print("Error updating user name: $e");
      return false;
    }
  }

  // Delete user from Firestore
  Future<bool> deleteUser(String uid) async {
    try {
      await _firestore.collection("users").doc(uid).delete();
      return true;
    } catch (e) {
      print("Error deleting user: $e");
      return false;
    }
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
  Future<void> updateAd(
      String userId,
      String adId,
      String newTitle,
      String newDescription,
      String newHouseNo,
      String newStreet,
      String newImportantArea,
      String newCity,
      String newWhatsappNumber,
      List<String> imageUrls, // Change this to List<String>
      ) async {
    try {
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("ads")
          .doc(adId)
          .update({
        'title': newTitle,
        'description': newDescription,
        'houseNo': newHouseNo,
        'street': newStreet,
        'importantArea': newImportantArea,
        'city': newCity,
        'whatsappNumber': newWhatsappNumber,
        'imageUrls': imageUrls,
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

