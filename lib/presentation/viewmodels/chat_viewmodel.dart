import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'onboarding_viewmodel.dart'; // Same directory

// Repository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

// State definitions
final chatMessagesProvider = StateProvider<List<ChatMessage>>((ref) => []);
final chatLoadingProvider = StateProvider<bool>((ref) => false);

class ChatViewModel extends StateNotifier<List<ChatMessage>> {
  final ChatRepository _repository;
  final Ref _ref;

  ChatViewModel(this._repository, this._ref) : super([]) {
    // Add initial greeting (optional)
    state = [
      ChatMessage.ai(
        "Hello! I'm your personal nutrition assistant. How can I help you today?",
      ),
    ];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Add User Message
    final userMessage = ChatMessage.user(text);
    state = [...state, userMessage];

    // 2. Set Loading
    _ref.read(chatLoadingProvider.notifier).state = true;

    try {
      // 3. Get User Profile for Context
      final userState = _ref.read(onboardingViewModelProvider);

      // Convert OnboardingState to UserModel (or just use relevant fields)
      // Since OnboardingState is not UserModel, we might need a converter or construct a temporary object.
      // Ideally, OnboardingViewModel should hold the UserModel or we access a UserProvider.
      // For now, let's construct a partial UserModel from OnboardingState or use what we have.
      // Actually, OnboardingViewModel seems to be the source of truth for the 'current session' user data until it's saved.
      // Better: assume OnboardingState holds the data we need.

      final profile = UserModel(
        weight: userState.weight,
        height: userState.height,
        age: userState.age,
        gender: userState.gender,
        goal: userState.goal,
        activityLevel: userState.activityLevel,
        allergies: userState.allergies,
        dailyCalorieNeeds: userState.dailyCalories,
      );

      // 4. Call API
      final response = await _repository.sendMessage(text, profile);

      // 5. Add AI Response
      state = [...state, response];
    } catch (e) {
      state = [...state, ChatMessage.error("Failed to send message.")];
    } finally {
      // 6. Clear Loading
      _ref.read(chatLoadingProvider.notifier).state = false;
    }
  }
}

final chatViewModelProvider =
    StateNotifierProvider<ChatViewModel, List<ChatMessage>>((ref) {
      final repository = ref.watch(chatRepositoryProvider);
      return ChatViewModel(repository, ref);
    });
