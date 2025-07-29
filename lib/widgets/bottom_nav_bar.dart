import 'package:flutter/material.dart';
import 'package:school_hub/pages/home.dart';
import 'package:school_hub/pages/search.dart';
import 'package:school_hub/pages/classes.dart';
import 'package:school_hub/pages/create_class.dart';
import 'package:school_hub/pages/profile.dart';
import 'package:school_hub/pages/teacher.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  
  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            Icons.home_rounded,
            'Home',
            0,
            const HomePage(),
          ),
          _buildNavItem(
            context,
            Icons.search_rounded,
            'Search',
            1,
            const SearchPage(),
          ),
          _buildNavItem(
            context,
            Icons.menu_book_rounded,
            'Classes',
            2,
            const ClassesPage(),
          ),
          _buildNavItem(
            context,
            Icons.add_circle,
            'Create',
            3,
            const TeacherPage(),
          ),
          _buildNavItem(
            context,
            Icons.account_circle_rounded,
            'Profile',
            4,
            const ProfilePage(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    Widget page,
  ) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => page),
            );
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 