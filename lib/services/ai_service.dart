import 'dart:developer' as dev;
import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_hope/main.dart';

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
      You are 'HOPE,' an empathetic AI counselor. 
      Context: User stress score is $score.
      Rules: Be warm, concise (2-3 sentences), and human-like. No medical advice.
    """;

    final List<OpenAIChatCompletionChoiceMessageModel> messages = [
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
        ],
      ),
      ...history.map(
        (m) => OpenAIChatCompletionChoiceMessageModel(
          role: m["role"] == "user"
              ? OpenAIChatMessageRole.user
              : OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(m["text"]!),
          ],
        ),
      ),
    ];

    final completion = await OpenAI.instance.chat.create(
      model: "llama-3.3-70b-versatile",
      messages: messages,
      temperature: 0.6,
    );

    return completion.choices.first.message.content?.first.text ??
        "I'm here for you.";
  }
}

class ChatScreen extends StatefulWidget {
  final int score;
  const ChatScreen({super.key, this.score = 0});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  String get _combinedSystemPrompt {
    return """
You are 'HOPE,' the official AI counselor for Project Hope. 
Your mission is to provide a safe, non-judgmental, and empathetic space.
CONTEXT: User stress score is ${widget.score}.
RULES: Warmth, 2-3 concise sentences, no medical advice.
""";
  }

  @override
  void initState() {
    super.initState();
    _initGroq();

    // FIX: Wait for the frame to load before calling SharedPreferences to avoid PlatformException
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatHistory();
    });
  }

  void _initGroq() {
    OpenAI.apiKey = dotenv.env['GROQ_API_KEY'] ?? "";
    OpenAI.baseUrl = "https://api.groq.com/openai";
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedChat = prefs.getString('chat_history');

      if (savedChat != null) {
        final List<dynamic> decodedData = jsonDecode(savedChat);
        setState(() {
          _messages.clear();
          // FIX: Proper type casting from dynamic to Map<String, String>
          _messages.addAll(
            decodedData.map((item) => Map<String, String>.from(item)).toList(),
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
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _sendMessage() async {
    if (_isLoading || _controller.text.trim().isEmpty) return;

    String userText = _controller.text.trim();

    setState(() {
      _messages.add({"role": "user", "text": userText});
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();
    await _saveChatHistory();

    try {
      List<OpenAIChatCompletionChoiceMessageModel> chatHistory = [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              _combinedSystemPrompt,
            ),
          ],
        ),
        ..._messages.map(
          (m) => OpenAIChatCompletionChoiceMessageModel(
            role: m["role"] == "user"
                ? OpenAIChatMessageRole.user
                : OpenAIChatMessageRole.assistant,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                m["text"]!,
              ),
            ],
          ),
        ),
      ];

      OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat
          .create(
            model: "llama-3.3-70b-versatile",
            messages: chatHistory,
            temperature: 0.6,
          );

      String aiResponse =
          chatCompletion.choices.first.message.content?.first.text ??
          "I'm here for you.";

      if (mounted) {
        setState(() {
          _messages.add({"role": "assistant", "text": aiResponse});
          _isLoading = false;
        });
        _scrollToBottom();
        _saveChatHistory();
      }
    } catch (e) {
      dev.log('Groq Error', error: e);
      if (mounted) {
        setState(() {
          _messages.add({
            "role": "assistant",
            "text": "I'm having trouble connecting.",
          });
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CHAT WITH HOPE AI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
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
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                bool isUser = _messages[i]["role"] == "user";
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? kPrimaryAccent : Colors.white10,
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
                      _messages[i]["text"]!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(color: kPrimaryAccent),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Message Hope...",
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    backgroundColor: kPrimaryAccent,
                    mini: true,
                    onPressed: _sendMessage,
                    child: const Icon(
                      Icons.send,
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
