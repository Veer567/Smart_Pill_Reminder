import 'dart:async'; // For using Timer
import 'package:flutter/material.dart';
import 'welcome_screen.dart';

// Splash screen widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller and animation variable
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with 2 seconds duration
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Use a curved animation for smooth transition
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Start the animation
    _controller.forward();

    // After 3 seconds, navigate to WelcomeScreen
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    // Dispose the animation controller to free resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50], // Light background color
      body: FadeTransition(
        opacity: _animation, // Apply fade animation to child widget
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the content
            children: [
              // Logo or splash image
              Image.asset('assets/images/medicine.png', height: 120),
              const SizedBox(height: 20),

              // App name text
              Text(
                'Smart Medicine',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
