class ChatSessionManager {
  static String? _currentChatId;

  static void setCurrentChatId(String? chatId) {
    _currentChatId = chatId;
  }

  static String? get currentChatId => _currentChatId;
}
