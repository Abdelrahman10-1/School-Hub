import 'package:flutter/material.dart';
import 'package:school_hub/pages/profile.dart';
import 'package:school_hub/pages/create_class.dart';
import 'package:school_hub/pages/search.dart';
import 'package:school_hub/pages/home.dart';
import 'package:school_hub/widgets/bottom_nav_bar.dart';
import 'package:school_hub/Config/token_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:school_hub/Config/api_config.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class ClassesPage extends StatelessWidget {
  final String subject;
  const ClassesPage({super.key, this.subject = 'Arabic'});

  Future<void> _downloadAssignment(BuildContext context, int taskId) async {
    try {
      final token = await TokenService.getToken();
      final url = Uri.parse('$baseUrl/api/tasks/$taskId/download');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/octet-stream',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        // Get the app's documents directory
        final dir = await getApplicationDocumentsDirectory();
        // You can extract the filename from headers or use a default
        final fileName = 'assignment_task_$taskId.pdf';
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assignment saved to ${file.path}')),
        );
        // Open the file
        await OpenFile.open(file.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: \\${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \\$e')),
      );
    }
  }

  Future<void> _downloadBook(BuildContext context, int bookId) async {
    try {
      final token = await TokenService.getToken();
      final url = Uri.parse('$baseUrl/api/tasks/$bookId/download-book');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/octet-stream',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = 'book_$bookId.pdf';
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book saved to ${file.path}')),
        );
        await OpenFile.open(file.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: \\${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \\$e')),
      );
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
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Class',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ClassCard(
                icon: Icons.menu_book,
                label: subject,
                onDownload: () => _downloadBook(context, 1),
              ),
              const SizedBox(height: 16),
              _ClassCard(
                icon: Icons.assignment,
                label: 'Task',
                onDownload: () => _downloadAssignment(context, 2),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onDownload;
  const _ClassCard({required this.icon, required this.label, this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Icon(icon, size: 48, color: Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: IconButton(
              icon: const Icon(Icons.download_rounded, size: 32, color: Colors.black),
              onPressed: onDownload,
            ),
          ),
        ],
      ),
    );
  }
} 