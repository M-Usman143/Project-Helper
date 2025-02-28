import 'package:cloud_firestore/cloud_firestore.dart';

class AdModel {
  final String adId;
  final String title;
  final String description;
  final String houseNo;
  final String street;
  final String importantArea;
  final String city;
  final String whatsappNumber;
  final List<String> imageUrls;
  final String category;
  final String? bloodType;
  final Timestamp timestamp;

  AdModel({
    required this.adId,
    required this.title,
    required this.description,
    required this.houseNo,
    required this.street,
    required this.importantArea,
    required this.city,
    required this.whatsappNumber,
    required this.imageUrls,
    required this.category,
    this.bloodType,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      "adId": adId,
      "title": title,
      "description": description,
      "houseNo": houseNo,
      "street": street,
      "importantArea": importantArea,
      "city": city,
      "whatsappNumber": whatsappNumber,
      "imageUrls": imageUrls,
      "category": category,
      "bloodType": bloodType ?? "", // Ensure it never crashes
      "timestamp": timestamp,
    };
  }

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      adId: json["adId"] ?? "N/A",
      title: json["title"] ?? "No Title",
      description: json["description"] ?? "No Description",
      houseNo: json["houseNo"] ?? "N/A",
      street: json["street"] ?? "N/A",
      importantArea: json["importantArea"] ?? "N/A",
      city: json["city"] ?? "Unknown City",
      whatsappNumber: json["whatsappNumber"] ?? "N/A",
      imageUrls: json["imageUrls"] != null
          ? List<String>.from(json["imageUrls"])
          : [],
      category: json["category"] ?? "Unknown",
      bloodType: json["bloodType"], // Nullable
      timestamp: json["timestamp"] ?? Timestamp.now(),
    );
  }

  String getTimeAgo() {
    final Duration difference = DateTime.now().difference(timestamp.toDate());

    if (difference.inDays > 0) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }
}
