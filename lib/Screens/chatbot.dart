import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/chat_memory.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:flutter/material.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _messages = ChatMemory().messages;
  List<String> _predefinedQuestions = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  /// Fetches greeting message and predefined questions from server config
  Future<void> _loadConfig() async {
    try {
      final data = await _apiService.getWithToken('chatbot/config', null);

      if (data['success'] == true) {
        final config = data['data'];

        // Only add greeting if chat is fresh
        if (_messages.isEmpty) {
          final greeting = {
            "role": "assistant",
            "content":
                config['greeting_message'] ??
                "Hi! I'm your Diet Maker Assistant.",
          };
          setState(() {
            _messages.add(greeting);
            ChatMemory().messages = _messages;
          });
        }

        setState(() {
          _predefinedQuestions = List<String>.from(
            config['predefined_questions'] ?? [],
          );
        });

        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("Error loading chatbot config: $e");
      // Fallback greeting if API fails
      if (_messages.isEmpty) {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content":
                "Hi! 👋 I'm your Diet Maker Assistant. Ask me about your profile, meal plans, or tracking your progress!",
          });
          ChatMemory().messages = _messages;
        });
      }
    }
  }

  /// Sends user message to /api/chatbot/ask
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": message});
      ChatMemory().messages = _messages;
      _controller.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final data = await _apiService.postWithToken('chatbot/ask', {
        "input_as_text": message,
      });

      if (data['success'] == true) {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": data['output_text'] ?? "...",
          });
          ChatMemory().messages = _messages;
        });
      } else {
        //_showError("Unexpected response from server.");
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": data['message'] ?? "...",
          });
          ChatMemory().messages = _messages;
        });
      }
    } catch (e) {
      //_showError(data['output_text'] ?? "...");
      debugPrint("Chat error: $e");
    } finally {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  void _showError(String message) {
    setState(() {
      _messages.add({
        "role": "assistant",
        "content": "⚠️ $message. Please try again later.",
      });
      ChatMemory().messages = _messages;
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final bool isUser = message["role"] == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isUser
                  ? const Color.fromARGB(255, 253, 217, 203)
                  : backgroundColor(),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft:
                isUser ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight:
                isUser ? const Radius.circular(0) : const Radius.circular(12),
          ),
        ),
        child: Text(
          message["content"] ?? "",
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diet Maker Assistant"),
        backgroundColor: backgroundColor(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 10,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: backgroundColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("Assistant is typing..."),
                      ),
                    );
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),

            // Predefined questions shown only on fresh chat (1 message = greeting only)
            if (_messages.length == 1 && _predefinedQuestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children:
                      _predefinedQuestions
                          .map(
                            (q) => ActionChip(
                              label: Text(q),
                              backgroundColor: backgroundColor(),
                              onPressed: () => _sendMessage(q),
                            ),
                          )
                          .toList(),
                ),
              ),

            // Input field
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: const InputDecoration(
                        hintText: "Ask me anything...",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: primaryColor),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
