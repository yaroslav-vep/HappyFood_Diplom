import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/menu_analysis_model.dart';
import '../../data/repositories/menu_analysis_repository.dart';

// ─── Status Enum ─────────────────────────────────────────────────────────────
enum MenuScanStatus { idle, loading, success, error }

// ─── State ───────────────────────────────────────────────────────────────────
class MenuScanState {
  final MenuScanStatus status;
  final MenuAnalysisResult? result;
  final String? errorMessage;

  const MenuScanState({
    this.status = MenuScanStatus.idle,
    this.result,
    this.errorMessage,
  });

  MenuScanState copyWith({
    MenuScanStatus? status,
    MenuAnalysisResult? result,
    String? errorMessage,
  }) {
    return MenuScanState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─── ViewModel ───────────────────────────────────────────────────────────────
class MenuScanViewModel extends StateNotifier<MenuScanState> {
  final MenuAnalysisRepository _repository;

  MenuScanViewModel(this._repository) : super(const MenuScanState());

  Future<void> analyzeMenu({
    required String base64Image,
    required String mimeType,
  }) async {
    state = const MenuScanState(status: MenuScanStatus.loading);

    try {
      final result = await _repository.analyzeMenuImage(
        base64Image: base64Image,
        mimeType: mimeType,
      );
      state = MenuScanState(status: MenuScanStatus.success, result: result);
    } catch (e) {
      state = MenuScanState(
        status: MenuScanStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void reset() => state = const MenuScanState();
}

// ─── Providers ───────────────────────────────────────────────────────────────
final menuAnalysisRepositoryProvider = Provider<MenuAnalysisRepository>((ref) {
  return MenuAnalysisRepository();
});

final menuScanViewModelProvider =
    StateNotifierProvider<MenuScanViewModel, MenuScanState>((ref) {
  return MenuScanViewModel(ref.watch(menuAnalysisRepositoryProvider));
});
