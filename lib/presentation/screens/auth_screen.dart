import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? 'Sign Up' : 'Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (authProvider.isLoading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton(
                onPressed: () async {
                  try {
                    if (_isSignUp) {
                      await authProvider.signUpWithEmail(
                        _emailController.text,
                        _passwordController.text,
                      );
                    } else {
                      await authProvider.signInWithEmail(
                        _emailController.text,
                        _passwordController.text,
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
              ),
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(_isSignUp
                    ? 'Already have an account? Sign In'
                    : 'Need an account? Sign Up'),
              ),
              const Divider(),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const String.fromEnvironment('use_google_signin') == 'true' 
                    ? const Text('Sign in with Google') 
                    : const Text('Google Sign In'),
                onPressed: () async {
                  try {
                    await authProvider.signInWithGoogle();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
