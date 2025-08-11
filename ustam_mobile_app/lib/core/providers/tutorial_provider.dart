import 'package:flutter_riverpod/flutter_riverpod.dart';

class TutorialNotifier extends StateNotifier<String?> {
  TutorialNotifier() : super(null);

  void setActiveTarget(String? targetKey) {
    state = targetKey;
  }

  void clearActiveTarget() {
    state = null;
  }

  bool isTargetActive(String targetKey) {
    return state == targetKey;
  }
}

final tutorialProvider = StateNotifierProvider<TutorialNotifier, String?>((ref) {
  return TutorialNotifier();
});