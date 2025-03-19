import 'package:flutter/material.dart';
import '../image_handler/PermissionHandlerService.dart';
import '../models/AdModel.dart';
import '../utils/contact_utils.dart';
import '../Common/InternetChecker.dart';
import 'NavigationScreen.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdDetailShow extends StatefulWidget {
  final AdModel ad;
  AdDetailShow({required this.ad});
  @override
  State<AdDetailShow> createState() => _AdDetailShowState();
}
class _AdDetailShowState extends State<AdDetailShow> {
  int _currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to Home screen when back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Navigationscreen(initialIndex: 0)),
        );
        return false; // Prevent default back behavior
      },
      child: InternetChecker(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.ad.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.red,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Navigate to Home screen when back arrow is clicked
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Navigationscreen(initialIndex: 0)),
                );
              },
            ),
          ),

          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Slider
                  Container(
                    height: 280,
                    width: double.infinity,
                    child: PageView.builder(
                      itemCount: widget.ad.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.ad.imageUrls[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.broken_image, size: 120);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Product Name
                  Text(
                    widget.ad.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 22, color: Colors.blueGrey),
                      SizedBox(width: 6),
                      Text(
                        timeago.format(widget.ad.timestamp.toDate()),
                        style: TextStyle(fontSize: 15, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Contact: +92 ${widget.ad.whatsappNumber}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                  ),

                  SizedBox(height: 20),
                  // Product Description
                  Text(
                    "Product Description:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.ad.description ?? "No description available.",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 20),

                  // Complete Address Section
                  Divider(color: Colors.black54),
                  SizedBox(height: 10),
                  Text(
                    "Complete Address:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(height: 8),

                  // Formatted Address
                  Text("Street: ${widget.ad.street}", style: TextStyle(fontSize: 18, color: Colors.black87)),
                  SizedBox(height: 4),
                  Text("House No: ${widget.ad.houseNo}", style: TextStyle(fontSize: 18, color: Colors.black87)),
                  SizedBox(height: 4),
                  Text("Important Area: ${widget.ad.importantArea}", style: TextStyle(fontSize: 18, color: Colors.black87)),
                  SizedBox(height: 4),
                  Text("City: ${widget.ad.city}", style: TextStyle(fontSize: 18, color: Colors.black87)),

                  SizedBox(height: 20),
                  SizedBox(height: 80), // Space for buttons
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      bool isStorageGranted = await PermissionHandlerService.requestPhonePermission();
                      if (isStorageGranted) {
                        ContactUtils.callNumber(widget.ad.whatsappNumber);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Phone permission required!")),
                        );
                      }
                      // Implement Message Functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Call",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      bool isStorageGranted = await PermissionHandlerService.requestPhonePermission();
                      if (isStorageGranted) {
                        ContactUtils.sendMessage(widget.ad.whatsappNumber);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Phone permission required!")),
                        );
                      }
                      // Implement Message Functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Message",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
