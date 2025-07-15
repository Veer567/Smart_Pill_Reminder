import 'package:flutter/material.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

// Stateless widget for the Welcome Screen
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen height and width for responsive sizing
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white, // Set background color
      body: SafeArea(
        child: Center(
          // Center widget to vertically and horizontally center the content
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight, // Ensure it takes full height
            ),
            child: IntrinsicHeight(
              // Makes the Column take the height of its children
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
                children: [
                  // Logo/Image at the top
                  Image.asset(
                    'assets/images/Group.png',
                    height: screenHeight * 0.18,
                    width: screenWidth * 0.4,
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Welcome message
                  Text(
                    'Welcome to Smart Medicine',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.01),

                  // Subtext message
                  Text(
                    'Manage your health with ease',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  // Sign In button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87, // Button color
                      foregroundColor: Colors.white, // Text color
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(fontSize: screenWidth * 0.045),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Create Account button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black87), // Border color
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                    ),
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: Colors.black87,
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
