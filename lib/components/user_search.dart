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
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Map<String, dynamic>> _results = [];
  List<String> _pastSearches = [];
  List<String> _previousSearches = [];
  bool _loading = false;

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

      // Save search if it's not a duplicate
      if (!_pastSearches.contains(query)) {
        _pastSearches.insert(0, query);
        if (_pastSearches.length > 10) _pastSearches.removeLast();
      }
    });

    _showOverlay();
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty && !_previousSearches.contains(query)) {
      setState(() {
        _previousSearches.add(query);
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
        width: size?.width ?? 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, size?.height ?? 40),
          showWhenUnlinked: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: _controller.text.isEmpty && _previousSearches.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: _previousSearches.length,
                      itemBuilder: (context, index) {
                        final query = _previousSearches[index];
                        return ListTile(
                          title: Text(query),
                          onTap: () {
                            _controller.text = query;
                            _onSearchSubmitted(query);
                          },
                        );
                      },
                    )
                  : _pastSearches.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No recent searches.'),
                        )
                      : ListView.builder(
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
                                  _showPastSearches();
                                },
                              ),
                              onTap: () {
                                _controller.text = search;
                                _searchUsers(search);
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 38,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
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
              _searchUsers(val.trim());
            },
            onSubmitted: _onSearchSubmitted,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
