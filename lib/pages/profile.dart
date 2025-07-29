import 'package:flutter/material.dart';
import 'package:school_hub/widgets/custom_text_field.dart';
import 'package:school_hub/widgets/custom_botton.dart';
import 'package:school_hub/pages/create_class.dart';
import 'package:school_hub/pages/search.dart';
import 'package:school_hub/pages/home.dart';
import 'package:school_hub/pages/login.dart';
import 'package:school_hub/widgets/bottom_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:school_hub/Config/api_config.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'package:school_hub/Config/token_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _obscurePassword = true;
  String? userId;
  String? userName;
  String? userEmail;
  bool _isLoading = true;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() { _isLoading = true; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await TokenService.getToken();
      if (token == null) {
        developer.log('No auth token found.', name: 'ProfilePage');
        setState(() { _isLoading = false; });
        return;
      }
      developer.log('Fetching profile with token: $token', name: 'ProfilePage');
      final url = Uri.parse('$baseUrl/api/profile');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      developer.log('Profile API response status: ${response.statusCode}', name: 'ProfilePage');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('Profile data received: $data', name: 'ProfilePage');
        setState(() {
          userId = data['id']?.toString();
          userName = data['name'];
          userEmail = data['email'];
          _isLoading = false;
        });
        developer.log('Profile state updated: userId=$userId, userName=$userName, userEmail=$userEmail', name: 'ProfilePage');
        // Save userId for later use
        await prefs.setString('user_id', userId ?? '');
      } else {
        developer.log('Profile API returned non-200 status: ${response.statusCode}', name: 'ProfilePage');
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      developer.log('Error fetching profile: $e', name: 'ProfilePage', error: e);
      setState(() { _isLoading = false; });
    }
  }

  void _showGiveAccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const _GiveAccessSheet();
      },
    );
  }

  Future<void> _changePassword() async {
    final newPassword = _passwordController.text.trim();
    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a new password.')),
      );
      return;
    }
    final token = await TokenService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated.')),
      );
      return;
    }
    final url = Uri.parse('$baseUrl/api/profile/password?new_password=$newPassword');
    try {
      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Password change response unknown.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      developer.log('Starting logout process', name: 'ProfilePage');
      final token = await TokenService.getToken();
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      if (token == null || email == null) {
        developer.log('No token or email found', name: 'ProfilePage');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not authenticated.')),
        );
        return;
      }
      developer.log('Making logout API call', name: 'ProfilePage');
      final url = Uri.parse('$baseUrl/api/logout?email=$email');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (!mounted) return;
      final data = json.decode(response.body);
      developer.log('Logout response: $data', name: 'ProfilePage');
      if (response.statusCode == 200 && (data['message']?.toLowerCase().contains('logged out') ?? false)) {
        developer.log('Logout successful, clearing preferences', name: 'ProfilePage');
        // Clear all stored data
        await TokenService.deleteToken();
        await prefs.clear();
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
        // Navigate to login page
        if (!mounted) return;
        developer.log('Attempting navigation to login page', name: 'ProfilePage');
        // Try navigation
        try {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
          developer.log('Navigation completed successfully', name: 'ProfilePage');
        } catch (e) {
          developer.log('Navigation failed: $e', name: 'ProfilePage', error: e);
          // Try alternative navigation
          try {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
            developer.log('Alternative navigation completed', name: 'ProfilePage');
          } catch (e) {
            developer.log('Alternative navigation failed: $e', name: 'ProfilePage', error: e);
          }
        }
      } else {
        developer.log('Logout failed: [31m${data['message']}[0m', name: 'ProfilePage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Logout failed!')),
        );
      }
    } catch (e) {
      developer.log('Error during logout', name: 'ProfilePage', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          centerTitle: true,
          title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    // Settings icon (only if profile data is loaded)
                    if (userId != null && userName != null && userEmail != null) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => _showGiveAccessSheet(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.settings, size: 32, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // User Profile Fields
                      _ProfileField(
                        label: 'User ID',
                        value: userId!,
                        icon: Icons.perm_identity,
                      ),
                      const SizedBox(height: 16),
                      _ProfileField(
                        label: 'Name',
                        value: userName!,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _ProfileField(
                        label: 'Email',
                        value: userEmail!,
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 24),
                      // Change Password Section
                      const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: const InputDecoration(
                                    hintText: '**********',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              tooltip: 'Change Password',
                              onPressed: _changePassword,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      // Display a message if profile data couldn't be loaded
                      Center(
                        child: Text(
                          'Failed to load profile data.',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Logout Button (always visible if not loading)
                    CustomButton(
                      title: 'Logout',
                      onPressed: _logout,
                    ),
                    const Spacer(),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}

class _GiveAccessSheet extends StatefulWidget {
  const _GiveAccessSheet();

  @override
  State<_GiveAccessSheet> createState() => _GiveAccessSheetState();
}

class _GiveAccessSheetState extends State<_GiveAccessSheet> {
  final TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 24,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomButton(
              title: 'Give Access to teacher',
              onPressed: () {},
            ),
            const SizedBox(height: 24),
            const Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomTextField(hintText: '', controller: _idController),
            const SizedBox(height: 24),
            CustomButton(
              title: 'Teacher',
              onPressed: () async {
                final userId = _idController.text.trim();
                if (userId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter the user ID.')),
                  );
                  return;
                }
                final token = await TokenService.getToken();
                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Not authenticated.')),
                  );
                  return;
                }
                final url = Uri.parse('$baseUrl/api/users/$userId/role?role=teacher');
                try {
                  final response = await http.put(
                    url,
                    headers: {
                      'Accept': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                  );
                  final data = json.decode(response.body);
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data['message'] ?? 'Role changed to teacher!')),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data['message'] ?? 'Failed to change role.')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
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

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 