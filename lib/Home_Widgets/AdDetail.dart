import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../Firebase/firebase_service.dart';
import '../image_handler/ImagePickerWidget.dart';
import '../Firebase/storage_service.dart';
import '../models/AdModel.dart';

class AdDetailsScreen extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;

  AdDetailsScreen({
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  State<AdDetailsScreen> createState() => _AdDetailsScreenState();
}

class _AdDetailsScreenState extends State<AdDetailsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, Color> _borderColors = {};
  String _selectedBloodType = "A+";
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController(text: "+92");

  String? _whatsappError;
  List<File> _selectedImage = [];

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Category *", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: widget.categoryColor,
                    child: Icon(widget.categoryIcon, color: Colors.black),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.categoryName, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      Text("Select Category", style: TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),
              if (widget.categoryName == "Blood" || widget.categoryName == "Blood Donation") ...[
                SizedBox(height: 16),
                _buildDropdownField("Blood Type *", ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]),
              ],
              SizedBox(height: 16),
              //----------image picker-------------------------------------
              ImagePickerWidget(
                onImagesSelected: (selectedImages) {
                  setState(() {
                    _selectedImage = selectedImages;
                  });
                },
              ),
            //--------------------------------------------------------------
              SizedBox(height: 16),
              _buildTextField("Ad title *", "Enter title"),
              SizedBox(height: 16),
              _buildTextField("Description *", "Describe the item you are selling", maxLines: 3),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(flex: 1, child: _buildTextField("House No. *", "Enter house number")),
                  SizedBox(width: 10),
                  Expanded(flex: 2, child: _buildTextField("Street *", "Enter street")),
                ],
              ),
              SizedBox(height: 16),
              _buildTextField("Important Area *", "Enter nearby important area"),
              SizedBox(height: 16),
              _buildTextField("City *", "Enter city"),
              SizedBox(height: 16),
              _buildWhatsAppField(),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed:  _validateAndSubmit,
                child: Text("Submit Ad", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.red,
      title: Text("Ad details", style: TextStyle(color: Colors.white)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  //other fields controller-------------------
  Widget _buildTextField(String label, String hintText, {int maxLines = 1}) {
    if (!_controllers.containsKey(label)) {
      _controllers[label] = TextEditingController();
      _focusNodes[label] = FocusNode();
      _borderColors[label] = Colors.grey;

      _focusNodes[label]!.addListener(() {
        setState(() {
          if (!_focusNodes[label]!.hasFocus && _controllers[label]!.text.isEmpty) {
            _borderColors[label] = Colors.red;
          } else if (_focusNodes[label]!.hasFocus) {
            _borderColors[label] = Colors.green;
          }
        });
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          controller: _controllers[label],
          focusNode: _focusNodes[label],
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _borderColors[label]! ?? Colors.grey),
            ),
          ),
          style: TextStyle(color: Colors.black),
          onChanged: (value) {
            setState(() {
              _borderColors[label] = value.isNotEmpty ? Colors.green : Colors.red;
            });
          },
        ),
      ],
    );
  }

  //number Managing things----------
  Widget _buildWhatsAppField() {
    TextEditingController countryCodeController =
    TextEditingController(text: "+92");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("WhatsApp Number *",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 70, // Fixed width for country code
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: TextField(
                controller: countryCodeController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.center,
                maxLength: 4,
                decoration: InputDecoration(
                  counterText: "", // Hides the counter text
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _whatsappController,
                keyboardType: TextInputType.number,
                maxLength: 10, // Restrict to 10 digits
                decoration: InputDecoration(
                  hintText: "31**********",
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  errorText: _whatsappError,
                  counterText: "", // Hides the counter text
                ),
                onChanged: (value) {
                  setState(() {
                    _whatsappError = (value.length < 10)
                        ? "Number is incomplete"
                        : null;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }


  //drop down list list field --------
  Widget _buildDropdownField(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedBloodType,
              dropdownColor: Colors.white,
              style: TextStyle(color: Colors.black),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBloodType = newValue!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  void _validateAndSubmit() async {
    if (_controllers["Ad title *"]!.text.isEmpty ||
        _controllers["Description *"]!.text.isEmpty ||
        _controllers["City *"]!.text.isEmpty ||
        _selectedImage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not authenticated")),
      );
      return;
    }

    String userId = user.uid;
    String adId = Uuid().v4();
    DateTime timestamp = DateTime.now();
    // Validate and format WhatsApp number
    String countryCode = _countryCodeController.text.trim();
    String phoneNumber = _whatsappController.text.trim();
    if (phoneNumber.length < 10) {
      setState(() {
        _whatsappError = "Number is incomplete";
      });
      return;
    }
    String fullWhatsAppNumber = "$countryCode$phoneNumber";



    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Submitting Ad"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Your ad is being submitted, please wait..."),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
              ),
            );
          },
        );
      },
    );

    try {
      List<String> imageUrls = await StorageService().uploadImages(userId, adId, _selectedImage);
      AdModel ad = AdModel(
        adId: adId,
        title: _controllers["Ad title *"]!.text,
        description: _controllers["Description *"]!.text,
        houseNo: _controllers["House No. *"]!.text,
        street: _controllers["Street *"]!.text,
        importantArea: _controllers["Important Area *"]!.text,
        city: _controllers["City *"]!.text,
        whatsappNumber: fullWhatsAppNumber,
        imageUrls: imageUrls,
        category: widget.categoryName,
        bloodType: (widget.categoryName == "Blood" || widget.categoryName == "Blood Donation") ? _selectedBloodType : null,
        timestamp: Timestamp.fromDate(timestamp),
      );

      await FirestoreService().saveAd(userId, ad);



      // Update dialog with success message
      Navigator.pop(context); // Close loading dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("Ad is successfully posted!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close success dialog
                Navigator.pop(context); // Navigate back to previous screen
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit ad: $e")),
      );
    }
  }

}
