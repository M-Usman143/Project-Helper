import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Common/FavoriteProvider.dart';
import '../Pages/AdDetailShow.dart';
import '../models/AdModel.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProductCard extends StatelessWidget {
  final AdModel ad;

  ProductCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    bool isFav = favoriteProvider.isFavorite(ad);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdDetailShow(ad: ad),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                ad.imageUrls.first,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 120);
                },
              ),
            ),
            SizedBox(height: 10),

            // Product Name & Favorite Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Ensures text does not overflow
                  child: Text(
                    ad.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    favoriteProvider.toggleFavorite(ad);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            isFav ? 'Your ad is removed from favourites!' : 'Your ad is added to favourites!'
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );

                  },
                  child: Icon(
                    favoriteProvider.isFavorite(ad) ? Icons.favorite : Icons.favorite_border,
                    color: favoriteProvider.isFavorite(ad) ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),

            // Price
            Text(
              "${ad.whatsappNumber}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 4),
            // Location
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${ad.importantArea}, ${ad.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),

            SizedBox(height: 4),

            // Upload Date
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.blueGrey),
                SizedBox(width: 4),
                Text(
                  timeago.format(ad.timestamp.toDate()), // Format timestamp
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}