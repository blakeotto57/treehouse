import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/components/drawer.dart';
import 'package:treehouse/components/nav_bar.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String? receiverName;

  const ChatPage({Key? key, required this.receiverEmail, this.receiverName}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  // Dummy messages for illustration
  final List<Map<String, dynamic>> messages = [];

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF386A53);

    return Scaffold(
      drawer: customDrawer(context),
      appBar: const Navbar(),
      body: Column(
        children: [
          // Username/email display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            color: Colors.transparent,
            child: Text(
              widget.receiverName ?? widget.receiverEmail,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF386A53),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    margin: EdgeInsets.only(
                      top: 4,
                      bottom: 4,
                      left: isMe ? 40 : 0,
                      right: isMe ? 0 : 40,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe ? themeColor : Colors.green[50],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(22),
                        topRight: const Radius.circular(22),
                        bottomLeft: Radius.circular(isMe ? 22 : 6),
                        bottomRight: Radius.circular(isMe ? 6 : 22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: isMe ? Colors.white : themeColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.green[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: Color(0xFF386A53), // Green border
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: Color(0xFF386A53), // Green border
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: Color(0xFF386A53), // Green border
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: themeColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      // Send message logic here
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
