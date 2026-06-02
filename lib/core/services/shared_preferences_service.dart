import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

final sharedPrefsServiceProvider = Provider<SharedPrefsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsService(prefs);
});

class SharedPrefsService {
  final SharedPreferences _prefs;
  SharedPrefsService(this._prefs);

  static const _hasSeenOnboardingKey = 'hasSeenOnboarding';

  bool get hasSeenOnboarding => _prefs.getBool(_hasSeenOnboardingKey) ?? false;

  Future<void> setHasSeenOnboarding() async {
    await _prefs.setBool(_hasSeenOnboardingKey, true);
  }
}