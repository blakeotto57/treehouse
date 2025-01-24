import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:treehouse/models/category_model.dart';
import 'package:treehouse/pages/user_settings.dart';
import 'dart:io';

import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ExplorePage extends StatefulWidget {
  final List<CategoryModel> categories = CategoryModel.getCategories();

  ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );

    if (video != null) {
      File videoFile = File(video.path);
      
      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('videos/${DateTime.now().toString()}.mp4');
      
      try {
        await storageRef.putFile(videoFile);
        final videoUrl = await storageRef.getDownloadURL();
        
        // Store video metadata in Firestore
        await FirebaseFirestore.instance.collection('videos').add({
          'url': videoUrl,
          'userId': FirebaseAuth.instance.currentUser?.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error uploading video: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.green[800],
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Explore Users",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.green[800],
            height: 1.0,
          ),
        ),
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.65, // Reduced width
        child: Drawer(
          backgroundColor: Colors.white,
          elevation: 1,
          child: ListView(
            children: [
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.grey),
              ...widget.categories.map((category) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: Icon(
                      category.icon,
                      size: 30,
                      color: category.boxColor, // Match icon color to category color
                    ),
                    title: Text(
                      (category.name as Text).data ?? '', // Extract string from Text widget
                      style: TextStyle(
                        fontSize: 18,
                        color: category.boxColor, // Use category's boxColor for text
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      category.onTap(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey[200]),
                ],
              )).toList(),
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(
                  Icons.settings,
                  size: 30,
                  color: Colors.grey[700],
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserSettingsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('videos')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final videoData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return VideoThumbnail(videoUrl: videoData['url']);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadVideo,
        backgroundColor: Colors.green[800],
        child: const Icon(Icons.video_call),
      ),
    );
  }
}

class VideoThumbnail extends StatefulWidget {
  final String videoUrl;
  
  const VideoThumbnail({Key? key, required this.videoUrl}) : super(key: key);
  
  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? VideoPlayer(_controller)
        : const Center(child: CircularProgressIndicator());
  }
}
