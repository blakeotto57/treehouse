import 'package:flutter/material.dart';

class Marketplace extends StatelessWidget {
  const Marketplace({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TreeHouse'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Marketplace Title with Cool Effects
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 10, 9, 6), // Background color
                  borderRadius: BorderRadius.circular(12.0), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 10, 31, 0).withOpacity(0.3), // Shadow color
                      blurRadius: 8,
                      offset: Offset(4, 4), // Shadow position
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [const Color.fromARGB(255, 112, 219, 96), const Color.fromARGB(255, 219, 68, 30)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Text(
                  'Welcome to the MarketPlace!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(1, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Seller Listings Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Adjust to 3-4 boxes per row as desired
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 4 / 5, // Adjust the aspect ratio as needed
                ),
                itemCount: 12, // Replace with the dynamic count of services
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(10, 4), // Shadow position
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shop Name
                          Text(
                            'Shop Name  ${index + 1}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(221, 181, 235, 1),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          // Placeholder Icon for the Picture
                          Expanded(
                            child: Center(
                              child: Icon(
                                Icons.image, // Use any icon or image widget
                                size: 70,
                                color: const Color.fromARGB(255, 128, 120, 120), // Customize color if needed
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          // Hashtags TextBox
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                '#hastags and description',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 207, 5, 5),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
