// ignore_for_file: deprecated_member_use

import 'dart:developer' as dev;
import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_hope/main.dart'; // Make sure kPrimaryAccent is exported here

class AIService {
  static void init() {
    OpenAI.apiKey = dotenv.env['GROQ_API_KEY'] ?? "";

    OpenAI.baseUrl = "https://api.groq.com/openai";
  }

  static Future<String> getHopeResponse(
    String userMessage,
    List<Map<String, String>> history,
    int score,
  ) async {
    final systemPrompt =
        """
You are 'HOPE,' the official empathetic AI companion for Project Hope. 
Your mission is to provide a safe, non-judgmental, and  comforting space.
core
CONTEXT: The user's current stress score is $score.

RULES:
1. Be exceptionally warm and concise—respond in exactly 2-3 natural, human-like sentences.
2. Provide emotional validation and gentle encouragement. Never offer solutions, advice, or medical diagnostics.
3. Adopt a soothing, supportive, and deeply human tone. Avoid generic AI phrasing or disclaimers entirely.
4. Always end on a hopeful note, reminding the user that they are not alone and that you are here for them.
5.try giving  encouragement to the user to seek professional help if they are in crisis, but do not provide any resources or contact information.
6.help the user to find a positive distraction, such as a hobby or activity they enjoy, to help them cope with their stress.
7. If the user expresses feelings of hopelessness or despair, respond with empathy and encourage them to reach out to a trusted friend, family member, or mental health professional for support.

""";

    // Build the payload stack cleanly exactly how you mapped it
    final List<OpenAIChatCompletionChoiceMessageModel> messages = [
      // 1. System Prompt configuration
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
        ],
      ),

      // 2. Map all past historical contexts
      ...history.map(
        (m) => OpenAIChatCompletionChoiceMessageModel(
          role: m["role"] == "user"
              ? OpenAIChatMessageRole.user
              : OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              m["text"] ?? "",
            ),
          ],
        ),
      ),

      // 3. FIX: Append the new incoming message that the user just typed!
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(userMessage),
        ],
      ),
    ];

    try {
      final completion = await OpenAI.instance.chat.create(
        model: "llama-3.3-70b-versatile",
        messages: messages,
        temperature: 0.6,
      );
      return completion.choices.first.message.content?.first.text ??
          "I'm here for you.";
    } catch (e) {
      dev.log("AIService Error", error: e);
      return "I'm having trouble connecting right now, but I am still here with you.";
    }
  }
}

class ChatScreen extends StatefulWidget {
  final int score;
  const ChatScreen({super.key, this.score = 0, required String initialContext});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    AIService.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatHistory();
    });
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedChat = prefs.getString('chat_history');

      if (savedChat != null) {
        final List<dynamic> decodedData = jsonDecode(savedChat);
        setState(() {
          _messages.clear();
          _messages.addAll(
            decodedData.map((item) {
              return {
                "role": item["role"]?.toString() ?? "user",
                "text": item["text"]?.toString() ?? "",
              };
            }).toList(),
          );
        });
        _scrollToBottom();
      }
    } catch (e) {
      dev.log("Error loading chat history: $e");
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String encodedData = jsonEncode(_messages);
      await prefs.setString('chat_history', encodedData);
    } catch (e) {
      dev.log("Error saving chat: $e");
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

  void _sendMessage() async {
    if (_isLoading || _controller.text.trim().isEmpty) return;

    String userText = _controller.text.trim();

    // Capture historical snapshot BEFORE updating layout context
    List<Map<String, String>> staticHistoryContext = List.from(_messages);

    setState(() {
      _messages.add({"role": "user", "text": userText});
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();
    await _saveChatHistory();

    // Pass parameters down cleanly to backend service setup
    String aiResponse = await AIService.getHopeResponse(
      userText,
      staticHistoryContext,
      widget.score,
    );

    if (mounted) {
      setState(() {
        _messages.add({"role": "assistant", "text": aiResponse});
        _isLoading = false;
      });
      _scrollToBottom();
      _saveChatHistory();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "HOPE COUNSELOR",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white60),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('chat_history');
              setState(() => _messages.clear());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                bool isUser = _messages[i]["role"] == "user";
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? kPrimaryAccent
                          : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: isUser
                            ? Radius.zero
                            : const Radius.circular(20),
                        bottomLeft: isUser
                            ? const Radius.circular(20)
                            : Radius.zero,
                      ),
                    ),
                    child: Text(
                      _messages[i]["text"] ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white38,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "HOPE is listening...",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: "Talk to HOPE...",
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    backgroundColor: kPrimaryAccent,
                    mini: true,
                    elevation: 0,
                    onPressed: _sendMessage,
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
