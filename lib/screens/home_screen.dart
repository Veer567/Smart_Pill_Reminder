import 'package:flutter/material.dart';
import 'package:medicine/screens/add_medicine_screen.dart';
import 'profile_screen.dart';

// Home screen with bottom navigation and medicine management UI
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Index for tracking bottom navigation bar selection
  int _selectedIndex = 0;

  // Handles navigation when a bottom nav item is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to ProfileScreen when profile icon is tapped
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header: "Home" title
                Text(
                  'Home',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 20),

                // 🔍 Search bar to find medicines
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search medicines...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 🖼️ Center image with title and description
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/reminder_12570772.png',
                        height: screenHeight * 0.25,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Manage your meds',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add your meds to be reminded on time\nand track your health',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ➕ Floating action button to add a new medicine
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
          );
        },
        backgroundColor: Colors.black87,
        child: const Icon(Icons.add, color: Colors.white),
        mini: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // 🔽 Bottom navigation bar with 4 items
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Nearby'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
