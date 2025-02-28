import 'package:flutter/material.dart';

Widget buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
      leading: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(10),
        child: Icon(icon, color: Colors.red),
      ),
      title: Text(title, style: TextStyle(color: Colors.black, fontSize: 16)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap,
    ),
  );
}

void showPrivacyPolicy(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Privacy Policy",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(color: Colors.grey),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Text(
                      """Your privacy is important to us. We are committed to protecting your personal information and your right to privacy.

1. **Information We Collect**  
   We collect personal data such as your name, email, and usage data.

2. **How We Use Your Information**  
   We use your information to improve our services, provide support, and enhance user experience.

3. **Data Security**  
   We implement strong security measures to protect your data from unauthorized access.

4. **Third-Party Services**  
   We do not share your data with third parties without your consent.

5. **Changes to Privacy Policy**  
   We may update our privacy policy periodically. Please review it regularly.

If you have any questions, feel free to contact us at support@example.com.""",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
