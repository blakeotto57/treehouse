import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/auth/presence_service.dart';

class PresenceWrapper extends StatefulWidget {
  final Widget child;

  const PresenceWrapper({super.key, required this.child});

  @override
  State<PresenceWrapper> createState() => _PresenceWrapperState();
}

class _PresenceWrapperState extends State<PresenceWrapper> with WidgetsBindingObserver {
  final PresenceService _presenceService = PresenceService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setOnline();
    
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _setOnline();
      } else {
        _setOffline();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setOffline();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _setOnline();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _setOffline();
    }
  }

  Future<void> _setOnline() async {
    if (_auth.currentUser != null) {
      await _presenceService.setOnline();
    }
  }

  Future<void> _setOffline() async {
    if (_auth.currentUser != null) {
      await _presenceService.setOffline();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

