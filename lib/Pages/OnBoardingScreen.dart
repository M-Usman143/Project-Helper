import 'package:flutter/material.dart';
import 'package:isaar/Pages/LoginScreen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  String _backgroundImage = 'assets/images/onboard1.jpg';

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int newPage = _pageController.page!.round();
      if (_currentPage != newPage) {
        setState(() {
          _currentPage = newPage;
          // Update the background image based on the current page
          _backgroundImage = _currentPage == 0
              ? 'assets/images/onboard1.jpg' // First page image
              : 'assets/images/onboard2.jpg'; // Second page image
        });
      }
    });
  }

  void _onNextPressed() {
    if (_currentPage < 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _backgroundImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint("Error loading image: $error");
                return Container(color: Colors.red);
              },
            ),
          ),
          // PageView for onboarding screens
          PageView(
            controller: _pageController,
            children: [
              _buildPage(
                title: 'Isaar Foundation – A Name You Can Trust',
                subtitle: 'Every drop counts, every help matters – Join us in saving lives.',
              ),
              _buildPage(
                title: 'Be the Hope Someone Needs Today!',
                subtitle: 'Donate blood, support the needy – because kindness changes lives.',
              ),
            ],
          ),
          // Container with content at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Page Title
                  Text(
                    _currentPage == 0
                        ? 'Isaar Foundation – A Name You Can Trust'
                        : 'Be the Hope Someone Needs Today!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  // Page Subtitle
                  Text(
                    _currentPage == 0
                        ? 'Every drop counts, every help matters – Join us in saving lives.'
                        : 'Donate blood, support the needy – because kindness changes lives.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  // Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(0),
                      _buildDot(1),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Floating Action Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: FloatingActionButton(
                      onPressed: _onNextPressed,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required String title, required String subtitle}) {
    return Container(
      color: Colors.transparent,
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.red : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
