import 'package:flutter/material.dart';
import 'package:medicine/screens/signin_screen.dart';

// Screen to handle forgotten password
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controller for the email input
  final _emailController = TextEditingController();

  // Stores email validation error message
  String? _emailError;

  // Validates email and navigates to SignInScreen if valid
  void _validateAndSubmit() {
    setState(() {
      _emailError = _validateEmail(_emailController.text);
      if (_emailError == null) {
        // Show confirmation snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset link sent!')),
        );
        // Navigate to sign-in screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      }
    });
  }

  // Email validation logic using regex
  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive UI
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.03,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.06),

                  // Subtitle
                  Text(
                    'Enter your email to reset your password',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  // Email input field
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      errorText: _emailError,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black87),
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  // Reset Password Button
                  ElevatedButton(
                    onPressed: _validateAndSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.2,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                    ),
                    child: Text(
                      'Reset Password',
                      style: TextStyle(fontSize: screenWidth * 0.045),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  // Back to login button
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                      );
                    },
                    child: Text(
                      'Back to Log In',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
