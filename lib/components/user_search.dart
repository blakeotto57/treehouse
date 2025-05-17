import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/models/other_users_profile.dart';

class UserSearch extends StatefulWidget {
  const UserSearch({super.key});

  @override
  State<UserSearch> createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      _removeOverlay();
      return;
    }

    setState(() => _loading = true);

    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: query + '\uf8ff')
        .limit(10)
        .get();

    setState(() {
      _results = result.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _loading = false;
    });

    _showOverlay();
  }

  void _showOverlay() {
    _removeOverlay(); // remove existing if any

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size?.width ?? 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, size?.height ?? 40),
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _results.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No users found.'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final user = _results[index];
                          return ListTile(
                            title: Text(user['username'] ?? ''),
                            onTap: () {
                              _controller.text = user['username'];
                              _removeOverlay();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OtherUsersProfilePage(
                                    username: user['username'],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        height: 38,
        child: TextField(
          controller: _controller,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: 'Search users by username...',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green[200] ?? Colors.green),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green[200] ?? Colors.green),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: Colors.green[200] ?? Colors.green, width: 2),
            ),
            suffixIcon: const Icon(Icons.search, color: Colors.green),
          ),
          onChanged: (val) => _searchUsers(val.trim()),
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
