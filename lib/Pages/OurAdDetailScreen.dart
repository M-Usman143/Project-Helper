import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:isaar/Common/InternetChecker.dart';
import '../Firebase/firebase_service.dart';
import '../image_handler/ImagePickerWidget.dart';
import '../models/AdModel.dart';
import 'DonationScreen.dart';
import 'NavigationScreen.dart';

class OurAdDetailScreen extends StatefulWidget {
  final AdModel ad;
  OurAdDetailScreen({required this.ad});

  @override
  _OurAdDetailScreenState createState() => _OurAdDetailScreenState();
}

class _OurAdDetailScreenState extends State<OurAdDetailScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController houseNoController;
  late TextEditingController streetController;
  late TextEditingController importantAreaController;
  late TextEditingController cityController;
  late TextEditingController whatsappNumberController;

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool isEditing = false;
  bool isLoading = false;
  late Stream<DocumentSnapshot> _adStream;
  List<String> imageUrls = []; // To hold image URLs
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool isUploading = false;
  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.ad.title);
    descriptionController = TextEditingController(text: widget.ad.description);
    houseNoController = TextEditingController(text: widget.ad.houseNo);
    streetController = TextEditingController(text: widget.ad.street);
    importantAreaController = TextEditingController(text: widget.ad.importantArea);
    cityController = TextEditingController(text: widget.ad.city);
    whatsappNumberController = TextEditingController(text: widget.ad.whatsappNumber);
    imageUrls = widget.ad.imageUrls; // Initialize image URLs

    // Listen for real-time updates
    _adStream = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('ads')
        .doc(widget.ad.adId)
        .snapshots();
  }

  Future<void> _updateAd() async {
    setState(() {
      isLoading = true;
    });

    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      await _firestoreService.updateAd(
        currentUserId,
        widget.ad.adId,
        titleController.text,
        descriptionController.text,
        houseNoController.text,
        streetController.text,
        importantAreaController.text,
        cityController.text,
        whatsappNumberController.text,
        imageUrls, // Updated image URLs
      );

      setState(() {
        isLoading = false;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ad updated successfully!")),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update ad. Please try again.")),
      );
    }
  }

  // Function to delete an image
  Future<void> _deleteImage(int index) async {
    try {
      // Delete the image from Firebase Storage
      String imageUrl = imageUrls[index];
      await _storage.refFromURL(imageUrl).delete();

      // Remove the image URL from the list
      setState(() {
        imageUrls.removeAt(index);
        if (_currentImageIndex >= imageUrls.length) {
          _currentImageIndex = imageUrls.length - 1;
        }
      });

      // Update Firestore
      await _updateAd();

    } catch (e) {
      print("Error deleting image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete image. Please try again.")),
      );
    }

  }
  // Function to show upload dialog with red progress bar
  void _showUploadDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing during upload
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.red, // Red progress bar
              ),
              SizedBox(height: 10),
              Text("Uploading images..."),
            ],
          ),
        );
      },
    );
  }

  // Function to close the upload dialog
  void _closeUploadDialog() {
    Navigator.pop(context);
  }

  // Function to show success message
  void _showSuccessMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 50),
              SizedBox(height: 10),
              Text("Images uploaded successfully!"),
            ],
          ),
        );
      },
    );

    // Close success dialog after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  // Function to handle new image selection
  void _onImagesSelected(List<File> images) async {
    setState(() {
      isUploading = true;
    });

    _showUploadDialog(); // Show upload dialog

    try {
      // Upload new images to Firebase Storage
      List<String> newImageUrls = [];
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      String adId = widget.ad.adId;

      for (var image in images) {
        // Generate a unique filename
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        // Define the storage path
        Reference storageRef = _storage.ref().child('adnewimages/$currentUserId/$adId/$fileName.jpg');
        await storageRef.putFile(image);
        String downloadUrl = await storageRef.getDownloadURL();
        newImageUrls.add(downloadUrl);
      }

      // Update the image URLs list
      setState(() {
        imageUrls.addAll(newImageUrls);
      });

      // Update Firestore
      await _updateAd();
      _closeUploadDialog(); // Close upload dialog
      _showSuccessMessage(); // Show success message
    } catch (e) {
      print("Error uploading images: $e");
      _closeUploadDialog(); // Close upload dialog on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload images. Please try again.")),
      );
    }
    finally {
      setState(() {
        isUploading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to DonationScreen when back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Navigationscreen(initialIndex: 1)),
        );
        return false; // Prevent default back behavior
      },
      child: InternetChecker(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text("Ad Details", style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Navigate to DonationScreen when back arrow is pressed
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Navigationscreen(initialIndex: 1)),
                );
              },
            ),
            actions: [
              if (isEditing)
                IconButton(
                  icon: Icon(Icons.save, color: Colors.white),
                  onPressed: _updateAd,
                ),
              IconButton(
                icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.white),
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
              ),
            ],
          ),
          body: StreamBuilder<DocumentSnapshot>(
            stream: _adStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text("Ad not found"));
              }

              // Parse the updated ad data
              var adData = snapshot.data!.data() as Map<String, dynamic>;
              AdModel updatedAd = AdModel.fromJson(adData);

              // Update image URLs if they change in Firestore
              if (updatedAd.imageUrls.isNotEmpty && updatedAd.imageUrls != imageUrls) {
                imageUrls = updatedAd.imageUrls;
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Pager (PageView)
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            height: 250,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: imageUrls.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrls[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          if (isEditing)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteImage(_currentImageIndex),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_a_photo, color: Colors.blue),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) => ImagePickerWidget(
                                          onImagesSelected: _onImagesSelected,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          Positioned(
                            bottom: 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(imageUrls.length, (index) {
                                return Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index ? Colors.red : Colors.grey,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Ad Details
                      _buildEditableField(
                        label: "Title",
                        value: updatedAd.title,
                        controller: titleController,
                        isEditing: isEditing,
                      ),
                      _buildEditableField(
                        label: "Description",
                        value: updatedAd.description,
                        controller: descriptionController,
                        isEditing: isEditing,
                      ),
                      _buildEditableField(
                        label: "House No",
                        value: updatedAd.houseNo,
                        controller: houseNoController,
                        isEditing: isEditing,
                      ),
                      _buildEditableField(
                        label: "Street",
                        value: updatedAd.street,
                        controller: streetController,
                        isEditing: isEditing,
                      ),
                      _buildEditableField(
                        label: "Important Area",
                        value: updatedAd.importantArea,
                        controller: importantAreaController,
                        isEditing: isEditing,
                      ),
                      _buildEditableField(
                        label: "City",
                        value: updatedAd.city,
                        controller: cityController,
                        isEditing: isEditing,
                      ),
                      _buildEditableField(
                        label: "WhatsApp Number",
                        value: updatedAd.whatsappNumber,
                        controller: whatsappNumberController,
                        isEditing: isEditing,
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

  // Helper method to build editable fields
  Widget _buildEditableField({
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 4),
          isEditing
              ? TextField(controller: controller, decoration: InputDecoration(border: OutlineInputBorder()))
              : Text(value, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}


