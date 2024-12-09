import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:video_player/video_player.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ImagePicker _picker = ImagePicker();

  // Function to handle image or video picking
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      // Here you can handle the selected image (upload to Firebase or show it)
      File pickedImage = File(image.path);
      // Do something with the image, such as uploading to Firestore or displaying
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore Sellers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[300],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: _pickImage, // Call function to pick image or record video
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final posts = snapshot.data!.docs;

          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'No posts available. Check back later!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].data() as Map<String, dynamic>;
              return PostCard(
                sellerName: post['sellerName'] ?? 'Unknown Seller',
                workTitle: post['workTitle'] ?? 'Untitled Work',
                description: post['description'] ?? 'No description provided.',
                mediaUrl: post['mediaUrl'],
              );
            },
          );
        },
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String sellerName;
  final String workTitle;
  final String description;
  final String? mediaUrl;

  const PostCard({
    super.key,
    required this.sellerName,
    required this.workTitle,
    required this.description,
    this.mediaUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seller Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[300],
                  child: Text(
                    sellerName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  sellerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Work Title
            Text(
              workTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Media (Video/Image)
            if (mediaUrl != null)
              mediaUrl!.endsWith('.mp4')
                  ? VideoPlayerWidget(mediaUrl: mediaUrl!)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        mediaUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            const SizedBox(height: 16),

            // Contact Button
            ElevatedButton(
              onPressed: () {
                // Implement contact functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[300],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Contact Seller'),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String mediaUrl;

  const VideoPlayerWidget({super.key, required this.mediaUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.mediaUrl)
      ..initialize().then((_) {
        setState(() {}); // Update UI once video is loaded
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
