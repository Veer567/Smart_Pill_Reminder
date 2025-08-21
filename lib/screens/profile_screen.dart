// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicine/screens/welcome_screen.dart'; // Import the WelcomeScreen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controller to manage the text in the display name field.
  final _nameController = TextEditingController();
  // State variable to show a loading indicator during profile updates.
  bool _loading = false;
  // A global key to manage the form state, allowing for validation.
  final _formKey = GlobalKey<FormState>();

  // State variable to manage the selected index of the BottomNavigationBar.
  int _selectedIndex = 2; // 'Profile' is the third item (index 2)

  // Define brand colors for consistency
  static const Color brandOrange = Color(0xFFF28C38);
  static const Color brandTeal = Color(0xFF2E7D7D);

  @override
  void initState() {
    super.initState();
    // Pre-populate the text field with the user's current display name.
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed to prevent memory leaks.
    _nameController.dispose();
    super.dispose();
  }

  // Asynchronous function to handle the profile update logic.
  Future<void> _updateProfile() async {
    // Only proceed if the form is valid (e.g., the name field is not empty).
    if (_formKey.currentState?.validate() ?? false) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() => _loading = true);
        try {
          // Update the user's display name on Firebase.
          await user.updateDisplayName(_nameController.text.trim());
          await user.reload(); // Reload user data to get the latest info.
          // Show a success message to the user.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          // Show an error message if the update fails.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to update profile: $e"),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          // Hide the loading indicator.
          setState(() => _loading = false);
        }
      }
    }
  }

  // A helper function to get the first initial for the avatar.
  String _getUserInitial(User? user) {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName![0].toUpperCase();
    }
    return user?.email != null && user!.email!.isNotEmpty
        ? user.email![0].toUpperCase()
        : '?';
  }

  // Method to handle navigation bar item taps.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // In a real app, you would navigate to different screens here.
    // For now, we'll just print the selected index.
    print("Tapped on index: $index");
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [brandTeal, brandOrange], // Updated gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Set Scaffold background to transparent
        body: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 40.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "My Profile",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: brandTeal.withOpacity(
                              0.5,
                            ), // Updated avatar color
                            child: Text(
                              _getUserInitial(user),
                              style: const TextStyle(
                                fontSize: 48,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            user?.email ?? 'No email found',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Display Name',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: brandTeal.withOpacity(
                              0.3,
                            ), // Updated fill color
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                brandOrange, // Updated button color
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            // Navigate to the Welcome Screen after logout
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WelcomeScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: brandTeal, // Updated outline color
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Logout",
                            style: TextStyle(fontSize: 18),
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
