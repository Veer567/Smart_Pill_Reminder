import 'package:flutter/material.dart';
import 'package:medicine/screens/welcome_screen.dart';
import 'package:medicine/screens/home_screen.dart';

// Profile screen where users can view and edit personal information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers for form fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Toggle for showing/hiding password
  bool _isPasswordVisible = false;

  // Dispose controllers when the screen is destroyed
  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            // Top Bar with back button and settings icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    // Navigate back to HomeScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                ),
                const Icon(Icons.settings),
              ],
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 30),

            // Name input field
            const Text("Your Name"),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Enter your name",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Email input field
            const Text("Your Email"),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "yourname@example.com",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Phone number input field
            const Text("Phone Number"),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "+91 1234567890",
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Password input field with visibility toggle
            const Text("Password"),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: "••••••••",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    // Toggle password visibility
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Logout button that navigates to WelcomeScreen
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // Navigate to WelcomeScreen on logout
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  );
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
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
