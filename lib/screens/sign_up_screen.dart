import 'package:flutter/material.dart';
import 'package:keptaom/services/auth_services.dart';
import 'package:keptaom/screens/login_screen.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  String? _error;

  void _signup() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _authService.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (result != null) {
      setState(() => _error = result);
    } else {
      Navigator.pop(context); // back to login screen
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Sign Up', style: TextStyle(fontSize: 28)),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _signup, child: const Text('Sign Up')),
          ],
        ),
      ),
    );
  }
}
