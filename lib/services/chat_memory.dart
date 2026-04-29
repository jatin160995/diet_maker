class ChatMemory {
  static final ChatMemory _instance = ChatMemory._internal();
  factory ChatMemory() => _instance;
  ChatMemory._internal();

  List<Map<String, dynamic>> messages = [];
}
