import 'package:flutter/material.dart';
import 'package:school_hub/pages/create_class.dart';
import 'package:school_hub/pages/profile.dart';
import 'package:school_hub/pages/search.dart';
import 'package:school_hub/pages/classes.dart';
import 'package:school_hub/widgets/bottom_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:school_hub/Config/api_config.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_hub/Config/token_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? gradeName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGradeName();
  }

  Future<void> _fetchGradeName() async {
    setState(() { _isLoading = true; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await TokenService.getToken();
      if (token == null) {
        setState(() { _isLoading = false; });
        return;
      }
      final profileUrl = Uri.parse('$baseUrl/api/profile');
      final profileResponse = await http.get(
        profileUrl,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (profileResponse.statusCode == 200) {
        final profileData = json.decode(profileResponse.body);
        final gradeId = profileData['grade_id']?.toString();
        if (gradeId != null) {
          await prefs.setString('user_grade_id', gradeId);
          final gradeUrl = Uri.parse('$baseUrl/api/grades?id=$gradeId');
          final gradeResponse = await http.get(gradeUrl);
          if (gradeResponse.statusCode == 200) {
            final grades = json.decode(gradeResponse.body);
            if (grades is List && grades.isNotEmpty) {
              setState(() {
                gradeName = grades[0]['name'];
                _isLoading = false;
              });
              return;
            }
          }
        }
      }
      setState(() { _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Classes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Subject icons and labels
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _SubjectIcon(label: 'Arabic'),
                            _SubjectIcon(label: 'Math'),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _SubjectIcon(label: 'English'),
                            _SubjectIcon(label: 'Science'),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            _SubjectIcon(label: 'Social Studies'),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

class _SubjectIcon extends StatelessWidget {
  final String label;
  const _SubjectIcon({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Replace with your subject icon asset if available
        IconButton(
          icon: Icon(Icons.menu_book),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ClassesPage(subject: label)),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
