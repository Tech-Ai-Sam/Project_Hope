// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:project_hope/main.dart'; // Handles kPrimaryAccent
import 'dart:developer' as dev;
import 'package:project_hope/services/ai_service.dart'; // Centralized AI interaction logic

class ChatScreen extends StatefulWidget {
  final int
  score; // Accepting the user's stress score down from previous context
  const ChatScreen({super.key, this.score = 0});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Keeping history structured uniformly to feed cleanly into AIService mappings
  final List<Map<String, dynamic>> _messages = [
    {
      "text":
          "Hello. I am here to listen without judgment. Tell me what's on your mind today.",
      "isUser": false,
    },
  ];

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAiTyping = false;

  @override
  void initState() {
    super.initState();
    // Safely initializing our backend API parameters on screen mount
    AIService.init();
  }

  void _sendMessage() async {
    final String userText = _messageController.text.trim();
    if (userText.isEmpty || _isAiTyping) return;

    // 1. Capture dynamic snapshot history payload before appending the mutation
    // We convert the internal map structure into the schema expected by AIService: List<Map<String, String>>
    List<Map<String, String>> staticHistoryContext = _messages.map((msg) {
      return {
        "role": msg["isUser"] == true ? "user" : "assistant",
        "text": msg["text"].toString(),
      };
    }).toList();

    // Remove the initial generic welcome statement from token history payload so the model doesn't over-index on it
    if (staticHistoryContext.isNotEmpty && _messages.length == 1) {
      staticHistoryContext.clear();
    }

    setState(() {
      _messages.add({"text": userText, "isUser": true});
      _isAiTyping = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      // 2. Fire actual background network request to Groq via our fixed AIService
      String aiResponse = await AIService.getHopeResponse(
        userText,
        staticHistoryContext,
        widget.score,
      );

      if (mounted) {
        setState(() {
          _isAiTyping = false;
          _messages.add({"text": aiResponse, "isUser": false});
        });
        _scrollToBottom();
      }
    } catch (e) {
      dev.log("ChatScreen processing exception error: $e");
      if (mounted) {
        setState(() {
          _isAiTyping = false;
          _messages.add({
            "text":
                "I'm having trouble connecting right now, but I am still here with you.",
            "isUser": false,
          });
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Column(
          children: [
            const Text(
              "Talk to HOPE",
              style: TextStyle(
                letterSpacing: 2,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "SECURE ENCRYPTED NODE",
              style: TextStyle(
                color: kPrimaryAccent.withOpacity(0.4),
                fontSize: 8,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: Colors.white70,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.lens,
              size: 8,
              color: _isAiTyping ? kPrimaryAccent : Colors.white12,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Message History Viewport
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isUser = message['isUser'];

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? kPrimaryAccent.withOpacity(0.06)
                          : const Color(0xFF09090A),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 20),
                      ),
                      border: Border.all(
                        color: isUser
                            ? kPrimaryAccent.withOpacity(0.25)
                            : Colors.white.withOpacity(0.02),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: isUser
                            ? Colors.white
                            : Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // AI Typing Indicator Dock
          if (_isAiTyping)
            Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 20, right: 28),
              child: Row(
                children: [
                  SizedBox(
                    height: 10,
                    width: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        kPrimaryAccent.withOpacity(0.4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Hope AI is interpreting inputs...",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          // Message Input Deck
          Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.02),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: kPrimaryAccent,
                    decoration: InputDecoration(
                      hintText: "Share what's on your mind...",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.2),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF09090A),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.03),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: kPrimaryAccent.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    height: 46,
                    width: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
