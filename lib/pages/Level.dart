import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:school_hub/widgets/custom_botton.dart';
//import 'package:school_hub/widgets/custom_text_field.dart';
import 'package:school_hub/pages/register.dart';
import 'package:school_hub/pages/home.dart';
import 'package:school_hub/Config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChooseLevel extends StatefulWidget {
  const ChooseLevel({super.key});

  @override
  State<ChooseLevel> createState() => _ChooseLevelState();
}

class _ChooseLevelState extends State<ChooseLevel> {
  String? selectedLevel;

  final List<String> levels = [
    'First Grade',
    'Second Grade',
    'Third Grade',
    'Fourth Grade',
    'Fifth Grade',
    'Sixth Grade',
    'Teacher',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            );
          },
        ),
        title: const Text('Back', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Choose Your Level !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Primary School',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...levels.take(6).map((level) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OutlinedLevelButton(
                title: level,
                selected: selectedLevel == level,
                onTap: () {
                  setState(() {
                    selectedLevel = level;
                  });
                },
              ),
            )),
            const SizedBox(height: 24),
            const Text(
              'Or',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            _OutlinedLevelButton(
              title: 'Teacher',
              selected: selectedLevel == 'Teacher',
              onTap: () {
                setState(() {
                  selectedLevel = 'Teacher';
                });
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              title: 'Get Started',
              onPressed: () async {
                if (selectedLevel != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a level')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for outlined buttons
class _OutlinedLevelButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _OutlinedLevelButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: selected ? Colors.blue : Colors.blue,
          width: 2,
        ),
        backgroundColor: selected ? Colors.blue[100] : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.blue[900] : Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
