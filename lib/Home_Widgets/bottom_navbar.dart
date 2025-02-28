import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  BottomNavBar({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Colors.white,
      color: Colors.red, // Keep your existing design
      buttonBackgroundColor: Colors.white,
      height: 60,
      index: selectedIndex,
      items: <Widget>[
        Icon(Icons.home, size: 30, color: selectedIndex == 0 ? Colors.red : Colors.white),
        Icon(Icons.volunteer_activism, size: 30, color: selectedIndex == 1 ? Colors.red : Colors.white),
        Icon(Icons.chat, size: 30, color: selectedIndex == 2 ? Colors.red : Colors.white),
        Icon(Icons.person, size: 30, color: selectedIndex == 3 ? Colors.red : Colors.white),
      ],
      onTap: (index) {
        onItemTapped(index);
      },
    );
  }
}
