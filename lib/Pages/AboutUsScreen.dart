import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-width Image
            Image.asset(
              'assets/images/bg_3.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle("About Isaar Foundation"),
                  SizedBox(height: 10),
                  _buildText(
                      "Isaar Foundation is dedicated to helping those in need by providing essential donations, especially blood donations. "
                          "Our mission is to create a healthier and more supportive society where every donor can make a difference. "
                          "We also contribute to various humanitarian causes, ensuring that help reaches those who need it the most."
                  ),
                  SizedBox(height: 10),
                  _buildTitle("Our Goals:"),
                  SizedBox(height: 5),
                  _buildBulletPoint("Encourage blood donations to save lives."),
                  _buildBulletPoint("Provide support to underprivileged communities."),
                  _buildBulletPoint("Organize awareness campaigns for health and social causes."),
                  _buildBulletPoint("Create a strong network of volunteers and donors."),
                  SizedBox(height: 10),
                  _buildTitle("How You Can Help:"),
                  SizedBox(height: 5),
                  _buildBulletPoint("Donate blood to save lives."),
                  _buildBulletPoint("Spread awareness about the importance of donations."),
                  _buildBulletPoint("Volunteer for our events and campaigns."),
                  _buildBulletPoint("Contribute funds or resources for humanitarian efforts."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, color: Colors.black54),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ", style: TextStyle(fontSize: 16, color: Colors.black)),
        Expanded(child: _buildText(text)),
      ],
    );
  }
}
