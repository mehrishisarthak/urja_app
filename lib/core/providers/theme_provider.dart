import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:urja/core/services/shared_preferences_service.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ref.read(sharedPrefsServiceProvider).themeMode;
});
