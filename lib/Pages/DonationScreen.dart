import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Firebase/firebase_service.dart';
import '../models/AdModel.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyAdsScreen extends StatefulWidget {
  @override
  _MyAdsScreenState createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<AdModel> userAds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserAds();
  }

  Future<void> _fetchUserAds() async {
    try {
      List<AdModel> ads = await _firestoreService.fetchUserAds(currentUserId);
      setState(() {
        userAds = ads;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user ads: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteAd(String adId) async {
    try {
      await _firestoreService.deleteAd(currentUserId, adId);
      setState(() {
        userAds.removeWhere((ad) => ad.adId == adId);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Ad deleted successfully!"),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      print("Error deleting ad: $e");
    }
  }

  void _editAd(AdModel ad) {
    TextEditingController titleController = TextEditingController(text: ad.title);
    TextEditingController descriptionController = TextEditingController(text: ad.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Ad"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
              TextField(controller: descriptionController, decoration: InputDecoration(labelText: "Description")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestoreService.updateAd(
                  currentUserId,
                  ad.adId,
                  titleController.text,
                  descriptionController.text,
                );
                _fetchUserAds();
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          "My Ads",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userAds.isEmpty
          ? Center(child: Text("No ads found"))
          : ListView.builder(
        itemCount: userAds.length,
        itemBuilder: (context, index) {
          AdModel ad = userAds[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.all(10),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(ad.imageUrls.first, height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ad.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(ad.whatsappNumber, style: TextStyle(fontSize: 16, color: Colors.red)),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('${ad.importantArea}, ${ad.city}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(timeago.format(ad.timestamp.toDate()), style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editAd(ad),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteAd(ad.adId),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
