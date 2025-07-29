import 'package:flutter/material.dart';
import 'package:school_hub/pages/profile.dart';
import 'package:school_hub/pages/create_class.dart';
import 'package:school_hub/pages/home.dart';
import 'package:school_hub/widgets/bottom_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:school_hub/Config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_hub/Config/token_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _tasksResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        setState(() {
          _tasksResults = [];
        });
      } else {
        _search();
      }
    });
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _tasksResults = [];
      });
      return;
    }
    setState(() { _isLoading = true; });
    try {
      final token = await TokenService.getToken();
      final url = Uri.parse('$baseUrl/api/class/search?q=$query');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _tasksResults = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _tasksResults = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: \\${response.body}')),
        );
      }
    } catch (e) {
      setState(() {
        _tasksResults = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \\$e')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search tasks...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.blue),
                    onPressed: _search,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
              if (!_isLoading && _searchController.text.trim().isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 160,
                          child: Image.asset('images/search.png'),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'What are you looking for?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_isLoading && _searchController.text.trim().isNotEmpty) ...[
                // Show search results
                Expanded(
                  child: ListView.builder(
                    itemCount: _tasksResults.length,
                    itemBuilder: (context, index) {
                      final item = _tasksResults[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(item['grade']?['name'] ?? 'No Grade', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Teacher: \\${item['teacher']?['name'] ?? 'Unknown'}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
} 