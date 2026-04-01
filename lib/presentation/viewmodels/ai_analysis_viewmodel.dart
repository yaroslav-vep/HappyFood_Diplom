import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/food_analysis_model.dart';
import '../../data/repositories/ai_analysis_repository.dart';

// --- State ---
enum AnalysisStatus { idle, loading, success, error }

class AnalysisState {
  final AnalysisStatus status;
  final FoodAnalysisModel? result;
  final String? errorMessage;

  const AnalysisState({
    this.status = AnalysisStatus.idle,
    this.result,
    this.errorMessage,
  });

  AnalysisState copyWith({
    AnalysisStatus? status,
    FoodAnalysisModel? result,
    String? errorMessage,
  }) {
    return AnalysisState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// --- ViewModel ---
class AiAnalysisViewModel extends StateNotifier<AnalysisState> {
  final AiAnalysisRepository _repository;

  AiAnalysisViewModel(this._repository) : super(const AnalysisState());

  Future<void> analyze({
    required String base64Image,
    required String mimeType,
  }) async {
    state = const AnalysisState(status: AnalysisStatus.loading);

    try {
      final result = await _repository.analyzeImage(
        base64Image: base64Image,
        mimeType: mimeType,
      );
      state = AnalysisState(status: AnalysisStatus.success, result: result);
    } catch (e) {
      state = AnalysisState(
        status: AnalysisStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void reset() {
    state = const AnalysisState();
  }
}

// --- Providers ---
final aiAnalysisRepositoryProvider = Provider<AiAnalysisRepository>((ref) {
  return AiAnalysisRepository();
});

final aiAnalysisViewModelProvider =
    StateNotifierProvider<AiAnalysisViewModel, AnalysisState>((ref) {
  final repo = ref.watch(aiAnalysisRepositoryProvider);
  return AiAnalysisViewModel(repo);
});
