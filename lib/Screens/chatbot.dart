import 'dart:convert';
import 'package:diet_maker/services/chat_memory.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({Key? key}) : super(key: key);

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ✅ Use the shared memory messages
  List<Map<String, dynamic>> _messages = ChatMemory().messages;
  List<String> _suggestions = [];
  bool _isTyping = false;

  final String baseUrl = "https://diet-revamp-saigalteams.replit.app";

  @override
  void initState() {
    super.initState();
    _loadSuggestions();

    //  Only add the greeting if chat is empty
    if (_messages.isEmpty) {
      _addInitialMessage();
    }
    _scrollToBottom();
  }

  void _addInitialMessage() {
    final message = {
      "role": "assistant",
      "content":
          "Hi! 👋 I'm your Diet Maker Assistant. Ask me about your profile, meal plans, or tracking your progress!",
      "relatedQuestions": [
        "How do I set up my profile?",
        "Can I plan meals for the week?",
        "How do I track my progress?",
      ],
    };

    setState(() {
      _messages.add(message);
      ChatMemory().messages = _messages; //  store in memory
    });
  }

  Future<void> _loadSuggestions() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/chatbot/suggestions"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _suggestions = List<String>.from(data["suggestions"]);
        });
      }
    } catch (e) {
      debugPrint("Error fetching suggestions: $e");
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    //  Add user message to memory
    setState(() {
      _messages.add({"role": "user", "content": message});
      ChatMemory().messages = _messages;
      _controller.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/chatbot/message"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final botMessage = {
          "role": "assistant",
          "content": data["message"],
          "relatedQuestions": data["relatedQuestions"] ?? [],
        };

        setState(() {
          _messages.add(botMessage);
          ChatMemory().messages = _messages; //  keep updated
        });
      } else {
        _showError("Server Error: ${res.statusCode}");
      }
    } catch (e) {
      _showError("Connection Error");
    } finally {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  void _showError(String message) {
    final errorMsg = {
      "role": "assistant",
      "content": "⚠️ $message. Please try again later.",
    };

    setState(() {
      _messages.add(errorMsg);
      ChatMemory().messages = _messages; // store in memory
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
    bool isUser = message["role"] == "user";
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
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message["content"] ?? "",
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            if (message["relatedQuestions"] != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children:
                      (message["relatedQuestions"] as List<dynamic>)
                          .map(
                            (q) => ActionChip(
                              label: Text(q),
                              backgroundColor: Colors.white,
                              onPressed: () => _sendMessage(q),
                            ),
                          )
                          .toList(),
                ),
              ),
          ],
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
            // Chat list
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

            // Suggestions (only on first load)
            if (_messages.length == 1 && _suggestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Wrap(
                  spacing: 8,
                  children:
                      _suggestions
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

// import 'dart:convert';
// import 'package:diet_maker/services/chat_memory.dart';
// import 'package:diet_maker/utils/color_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class ChatBotScreen extends StatefulWidget {
//   const ChatBotScreen({Key? key}) : super(key: key);

//   @override
//   State<ChatBotScreen> createState() => _ChatBotScreenState();
// }

// class _ChatBotScreenState extends State<ChatBotScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   // 🧠 Persist chat within app session
//   List<Map<String, dynamic>> _messages = ChatMemory().messages;
//   bool _isTyping = false;

//   // ⚙️ Agent config
//   final String workflowId =
//       "wf_68f1460b034c8190871d7cdb5a9583ab06ac72975998adb1";
//   final String apiKey =
//       "YOUR_OPENAI_API_KEY"; // ❗ Replace or route through backend

//   @override
//   void initState() {
//     super.initState();
//     if (_messages.isEmpty) _addInitialMessage();
//     _scrollToBottom();
//   }

//   void _addInitialMessage() {
//     final message = {
//       "role": "assistant",
//       "content":
//           "Hi! 👋 I'm your Diet Maker Assistant. Ask me about your profile, meal plans, or tracking your progress!",
//       "relatedQuestions": [
//         "How do I set up my profile?",
//         "Can I plan meals for the week?",
//         "How do I track my progress?",
//       ],
//     };
//     setState(() {
//       _messages.add(message);
//       ChatMemory().messages = _messages;
//     });
//   }

//   Future<void> _sendMessage(String message) async {
//     if (message.trim().isEmpty) return;

//     setState(() {
//       _messages.add({"role": "user", "content": message});
//       ChatMemory().messages = _messages;
//       _controller.clear();
//       _isTyping = true;
//     });
//     _scrollToBottom();

//     try {
//       final url = Uri.parse(
//         "https://api.openai.com/v1/workflows/$workflowId/runs",
//       );

//       final res = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $apiKey",
//         },
//         body: jsonEncode({
//           "input": {"input_as_text": message},
//         }),
//       );

//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);

//         // Extract bot output
//         final outputText =
//             (data["outputs"] != null &&
//                     data["outputs"].isNotEmpty &&
//                     data["outputs"][0]["output_text"] != null)
//                 ? data["outputs"][0]["output_text"]
//                 : "⚠️ No valid response received.";

//         final botMessage = {
//           "role": "assistant",
//           "content": outputText,
//           "relatedQuestions": [],
//         };

//         setState(() {
//           _messages.add(botMessage);
//           ChatMemory().messages = _messages;
//         });
//       } else {
//         _showError("Server Error: ${res.statusCode}");
//       }
//     } catch (e) {
//       _showError("Connection Error: $e");
//     } finally {
//       setState(() => _isTyping = false);
//       _scrollToBottom();
//     }
//   }

//   void _showError(String message) {
//     final errorMsg = {
//       "role": "assistant",
//       "content": "⚠️ $message. Please try again later.",
//     };
//     setState(() {
//       _messages.add(errorMsg);
//       ChatMemory().messages = _messages;
//     });
//   }

//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 200), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent + 100,
//           duration: const Duration(milliseconds: 400),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Widget _buildMessageBubble(Map<String, dynamic> message) {
//     final isUser = message["role"] == "user";
//     return Align(
//       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color:
//               isUser
//                   ? const Color.fromARGB(255, 253, 217, 203)
//                   : backgroundColor(),
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(12),
//             topRight: const Radius.circular(12),
//             bottomLeft:
//                 isUser ? const Radius.circular(12) : const Radius.circular(0),
//             bottomRight:
//                 isUser ? const Radius.circular(0) : const Radius.circular(12),
//           ),
//         ),
//         child: Text(
//           message["content"] ?? "",
//           style: const TextStyle(fontSize: 15, height: 1.4),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Diet Maker Assistant"),
//         backgroundColor: backgroundColor(),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Chat list
//             Expanded(
//               child: ListView.builder(
//                 controller: _scrollController,
//                 itemCount: _messages.length + (_isTyping ? 1 : 0),
//                 itemBuilder: (context, index) {
//                   if (_isTyping && index == _messages.length) {
//                     return Align(
//                       alignment: Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(
//                           vertical: 6,
//                           horizontal: 10,
//                         ),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: backgroundColor(),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Text("Assistant is typing..."),
//                       ),
//                     );
//                   }
//                   return _buildMessageBubble(_messages[index]);
//                 },
//               ),
//             ),

//             // Input field
//             Container(
//               padding: const EdgeInsets.all(8),
//               color: Colors.grey[100],
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       textInputAction: TextInputAction.send,
//                       onSubmitted: _sendMessage,
//                       decoration: const InputDecoration(
//                         hintText: "Ask me anything...",
//                         border: OutlineInputBorder(),
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 8,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   IconButton(
//                     icon: const Icon(Icons.send, color: primaryColor),
//                     onPressed: () => _sendMessage(_controller.text),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
