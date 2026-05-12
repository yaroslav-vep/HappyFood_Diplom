class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isCalorieRelated;
  final bool isError;
  final bool isMealPlan;
  final List<String> suggestedDishes;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isCalorieRelated = false,
    this.isError = false,
    this.isMealPlan = false,
    this.suggestedDishes = const [],
  });

  factory ChatMessage.user(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.ai(
    String text, {
    bool isCalorieRelated = false,
    bool isMealPlan = false,
    List<String> suggestedDishes = const [],
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      isCalorieRelated: isCalorieRelated,
      isMealPlan: isMealPlan,
      suggestedDishes: suggestedDishes,
    );
  }

  factory ChatMessage.error(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      isError: true,
    );
  }
}
