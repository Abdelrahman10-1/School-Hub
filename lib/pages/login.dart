import 'dart:ui';

//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_hub/widgets/custom_botton.dart';
import 'package:school_hub/widgets/custom_text_field.dart';
import 'package:school_hub/pages/register.dart';
import 'package:school_hub/pages/start.dart';
import 'package:school_hub/pages/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:school_hub/Config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_hub/Config/token_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }
    setState(() { _isLoading = true; });
    try {
      final url = Uri.parse('$baseUrl/api/login?email=${_emailController.text}&password=${_passwordController.text}');
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        if (token != null) {
          await TokenService.saveToken(token);
        }
        // Optionally store user info
        final user = data['user'];
        if (user != null) {
          await prefs.setString('user_id', user['id'].toString());
          await prefs.setString('user_name', user['name']);
          await prefs.setString('user_email', user['email']);
          await prefs.setString('user_role', user['role']);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const StartPage()),
            );
          },
        ),
        title: const Text('Back', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Welcome Back',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: Image.asset('images/login.png'),
            ),
            const SizedBox(height: 32),
            CustomTextField(hintText: 'Email', controller: _emailController),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot Password ?',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              title: _isLoading ? 'Logging in...' : 'Login',
              onPressed: _isLoading ? null : _login,
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                "Don't have an Account?",
                style: TextStyle(color: Colors.black87),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
