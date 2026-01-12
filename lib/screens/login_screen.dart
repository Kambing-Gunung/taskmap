import 'package:flutter/material.dart';

import '../screens/task_list_screen.dart';
import '../services/user_service.dart';
import '../models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final UserService _userService = UserService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // =====================
  // LOGIN LOGIC
  // =====================
  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Mohon isi Username dan Password', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final existingUser = await _userService.getUserByEmail(username);

      // ======================
      // USER BELUM ADA → BUAT BARU
      // ======================
      if (existingUser == null) {
        final newUser = User(
          name: username.split('@').first,
          email: username,
          password: password,
        );

        await _userService.insertUser(newUser);

        _showSnackBar('Akun baru berhasil dibuat', Colors.green);
        _goToHome();
        return;
      }

      // ======================
      // USER ADA → CEK PASSWORD
      // ======================
      if (existingUser.password != password) {
        _showSnackBar('Password salah. Silakan masukkan kembali.', Colors.red);
        return;
      }

      // ======================
      // LOGIN BERHASIL
      // ======================
      _showSnackBar('Login berhasil', Colors.green);
      _goToHome();
    } catch (e) {
      _showSnackBar('Terjadi kesalahan saat login', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // =====================
  // HELPER METHODS
  // =====================
  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TaskListScreen()),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =====================
  // UI
  // =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.map_outlined, size: 100, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                'TaskMap Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 40),

              // =====================
              // USERNAME
              // =====================
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Email / Username',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // =====================
              // PASSWORD
              // =====================
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // =====================
              // LOGIN BUTTON
              // =====================
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'MASUK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
