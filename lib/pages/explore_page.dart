import 'package:flutter/material.dart';
import 'package:treehouse/pages/chat_page.dart';
import 'package:treehouse/pages/home.dart';
import 'package:treehouse/pages/messages_page.dart';
import 'package:treehouse/pages/user_settings.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();

  // Example static data for demonstration
  final List<Map<String, String>> users = [
    {
      'name': 'Ashley Kim',
      'desc': 'Photography services for campus events',
      'category': 'Photography',
    },
    {
      'name': 'Marcus Nguyen',
      'desc': 'Custom PC builds & tech help',
      'category': 'Tech Support',
    },
    {
      'name': 'Sofia Rivera',
      'desc': 'Handmade jewelry & campus delivery',
      'category': 'Art & Design',
    },
  ];

  void _goToExplore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExplorePage()),
    );
  }

  void _goToMessages() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MessagesPage()),
    );
  }

  void _goToUpload() {
    // Replace with your upload page navigation
    // Example:
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadPage()));
  }

  void _goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserSettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pastelGreen = const Color(0xFFF5FBF7);

    return Scaffold(
      backgroundColor: pastelGreen,
      body: Column(
        children: [
          // Top Navigation Bar
          Container(
            color: const Color(0xFF386A53),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo or App Name
                const Text(
                  "Treehouse Connect",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 1,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _goToExplore,
                      icon: const Icon(Icons.explore, color: Colors.white),
                      label: const Text("Explore", style: TextStyle(color: Colors.white)),
                    ),
                    TextButton.icon(
                      onPressed: _goToMessages,
                      icon: const Icon(Icons.message, color: Colors.white),
                      label: const Text("Messages", style: TextStyle(color: Colors.white)),
                    ),
                    TextButton.icon(
                      onPressed: _goToUpload,
                      icon: const Icon(Icons.video_call, color: Colors.white),
                      label: const Text("Upload", style: TextStyle(color: Colors.white)),
                    ),
                    TextButton.icon(
                      onPressed: _goToSettings,
                      icon: const Icon(Icons.settings, color: Colors.white),
                      label: const Text("Settings", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Header
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by service, name, or major...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF386A53), width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF386A53),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Implement search logic
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Search",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // User grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: GridView.builder(
                itemCount: users.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // More columns for a feed feel
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                ),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Media/image placeholder (replace with real image if available)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: Container(
                            height: 120,
                            color: Colors.grey[300],
                            child: Icon(Icons.image, size: 60, color: Colors.grey[400]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name
                              Text(
                                user['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF386A53),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Description
                              Text(
                                user['desc'] ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              // Category/Tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD6EADF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user['category'] ?? '',
                                  style: const TextStyle(
                                    color: Color(0xFF386A53),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Actions row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Message button
                                  ElevatedButton(
                                    onPressed: () {
                                      // Implement message action
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF386A53),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text("Message"),
                                  ),
                                  // View Profile button
                                  TextButton(
                                    onPressed: () {
                                      // Implement view profile action
                                    },
                                    child: const Text("View Profile"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
