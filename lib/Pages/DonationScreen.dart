import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Firebase/firebase_service.dart';
import '../models/AdModel.dart';
import '../Common/InternetChecker.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'NavigationScreen.dart';
import 'OurAdDetailScreen.dart';

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
    checkInternetBeforeAction(context, () async {
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
    });
  }

  Future<void> _deleteAd(String adId) async {
    checkInternetBeforeAction(context, () async {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Navigationscreen(initialIndex: 0)),
        );
        return false;
      },
      child: InternetChecker(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text("My Ads", style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Navigationscreen(initialIndex: 0)),
                );
              },
            ),
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : userAds.isEmpty
              ? Center(child: Text("No ads found"))
              : ListView.builder(
            itemCount: userAds.length,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemBuilder: (context, index) {
              AdModel ad = userAds[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OurAdDetailScreen(ad: ad),
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.network(
                          ad.imageUrls.first,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              ad.whatsappNumber,
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 18, color: Colors.grey),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${ad.importantArea}, ${ad.city}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(
                                      timeago.format(ad.timestamp.toDate()),
                                      style: TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteAd(ad.adId),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
