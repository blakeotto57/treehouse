import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/models/other_users_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSearch extends StatefulWidget {
  const UserSearch({super.key});

  @override
  State<UserSearch> createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Map<String, dynamic>> _results = [];
  List<String> _pastSearches = [];
  List<String> _previousSearches = [];
  bool _loading = false;

  Future<void> _loadPastSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pastSearches = prefs.getStringList('pastSearches') ?? [];
    });
  }

  Future<void> _savePastSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pastSearches', _pastSearches);
  }

  void _addToPastSearches(String search) {
    setState(() {
      _pastSearches.remove(search); // Remove if already exists
      _pastSearches.insert(0, search); // Add to the top
      if (_pastSearches.length > 10) {
        _pastSearches.removeLast(); // Remove oldest
      }
      _savePastSearches();
    });
  }

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      _showPastSearches();
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
      _results =
          result.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      _loading = false;
    });

    _showOverlay();
  }

  void _onUserSelected(String username) {
    _addToPastSearches(username);
    setState(() {
      _controller.text = username;
    });
    _removeOverlay();
    Navigator.of(context).push(
      PageRouteBuilder(
    pageBuilder: (context, animation1, animation2) => OtherUsersProfilePage(username: username),
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  ),
    );
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      _addToPastSearches(query);
      setState(() {
        if (!_previousSearches.contains(query)) {
          _previousSearches.add(query);
        }
      });
    }
    _searchUsers(query);
  }

  void _showPastSearches() {
    _removeOverlay();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size?.width ?? _controller.value.text.length.toDouble(), // Match the exact width of the search bar
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, size?.height ?? 40),
          showWhenUnlinked: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0), // Adjust padding if needed
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: _controller.text.isEmpty && _pastSearches.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: _pastSearches.length,
                      itemBuilder: (context, index) {
                        final search = _pastSearches[index];
                        return ListTile(
                          title: Text(search),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _pastSearches.removeAt(index);
                            });
                            _savePastSearches();
                            _showPastSearches();
                          },
                        ),
                          onTap: () {
                            _onUserSelected(search);
                          },
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _showOverlay() {
    _removeOverlay(); // remove existing if any

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size?.width ?? _controller.value.text.length.toDouble(), // Match the exact width of the search bar
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, size?.height ?? 40),
          showWhenUnlinked: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0), // Adjust padding if needed
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
                                _onUserSelected(user['username']);
                              },
                            );
                          },
                        ),
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
  void initState() {
    super.initState();
    _loadPastSearches();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _controller.text.isEmpty) {
        _showPastSearches();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          height: 38,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            cursorColor: const Color(0xFF386A53),
            decoration: InputDecoration(
              hintText: 'Search users by username...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Colors.green[200] ?? Colors.green),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Colors.green[200] ?? Colors.green),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Colors.green[200] ?? Colors.green, width: 2),
              ),
              suffixIcon: (_controller.text.isNotEmpty)
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _controller.clear();
                          _searchUsers('');
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (val) {
              setState(() {
                _previousSearches.clear();
              });
              if (val.trim().isEmpty) {
                _showPastSearches();
              } else {
                _searchUsers(val.trim());
              }
            },
            onSubmitted: _onSearchSubmitted,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}