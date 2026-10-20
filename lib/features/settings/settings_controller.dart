import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({this.locale = const Locale('hi'), this.dark = false});
  final Locale locale;
  final bool dark;
}

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      state = AppSettings(
        locale: Locale(p.getString('lang') ?? 'hi'),
        dark: p.getBool('dark') ?? false,
      );
    } catch (_) {}
  }

  Future<void> setLocale(Locale l) async {
    state = AppSettings(locale: l, dark: state.dark);
    try {
      (await SharedPreferences.getInstance()).setString('lang', l.languageCode);
    } catch (_) {}
  }

  Future<void> setDark(bool v) async {
    state = AppSettings(locale: state.locale, dark: v);
    try {
      (await SharedPreferences.getInstance()).setBool('dark', v);
    } catch (_) {}
  }
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
