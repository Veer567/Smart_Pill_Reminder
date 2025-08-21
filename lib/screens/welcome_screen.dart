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

    // Define common button size
    final buttonWidth = screenWidth * 0.6;
    final buttonHeight = screenHeight * 0.07;

    // Define colors from the logo
    const Color brandOrange = Color(0xFFF28C38);
    const Color brandTeal = Color(0xFF2E7D7D);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Image at the top
                  Image.asset(
                    'assets/images/group.png',
                    height: screenHeight * 0.2,
                    width: screenWidth * 0.4,
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Dashed line separator (updated to solid for visibility)
                  Container(
                    height: 1,
                    width: screenWidth * 0.8,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.blue[200]!,
                          style: BorderStyle.solid, // Changed to solid line
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // App name
                  Text(
                    'MediRem',
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: brandOrange, // Orange color from the logo
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Subtext
                  Text(
                    'Your smart companion for daily \nmedicine reminders.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  // Sign In button (updated to orange)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandOrange, // Use the new brand color
                      foregroundColor: Colors.white,
                      minimumSize: Size(buttonWidth, buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(fontSize: screenWidth * 0.045),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Create Account button (updated to a teal outlined button)
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: brandTeal,
                        width: 2,
                      ), // Teal outline
                      minimumSize: Size(buttonWidth, buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Create account',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: brandTeal, // Teal text
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
