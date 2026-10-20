import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class LockState {
  const LockState({this.loaded = false, this.hasPin = false, this.biometric = false, this.unlocked = false});
  final bool loaded, hasPin, biometric, unlocked;
  bool get locked => hasPin && !unlocked;
  LockState copyWith({bool? loaded, bool? hasPin, bool? biometric, bool? unlocked}) =>
      LockState(
        loaded: loaded ?? this.loaded, hasPin: hasPin ?? this.hasPin,
        biometric: biometric ?? this.biometric, unlocked: unlocked ?? this.unlocked);
}

String hashPin(String pin, String salt) =>
    sha256.convert(utf8.encode('$salt:$pin')).toString();

class LockController extends Notifier<LockState> {
  static const _storage = FlutterSecureStorage();

  @override
  LockState build() {
    _load();
    return const LockState();
  }

  Future<void> _load() async {
    try {
      final hash = await _storage.read(key: 'pin_hash');
      final bio = await _storage.read(key: 'bio') == '1';
      state = LockState(loaded: true, hasPin: hash != null, biometric: bio);
    } catch (_) {
      state = const LockState(loaded: true);
    }
  }

  Future<void> setPin(String pin) async {
    final salt = List.generate(16, (_) => Random.secure().nextInt(256)).join('-');
    await _storage.write(key: 'pin_salt', value: salt);
    await _storage.write(key: 'pin_hash', value: hashPin(pin, salt));
    state = state.copyWith(hasPin: true, unlocked: true);
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(key: 'pin_salt');
    final hash = await _storage.read(key: 'pin_hash');
    return salt != null && hash == hashPin(pin, salt);
  }

  Future<bool> unlockWithPin(String pin) async {
    final ok = await verifyPin(pin);
    if (ok) state = state.copyWith(unlocked: true);
    return ok;
  }

  Future<bool> unlockWithBiometric(String reason) async {
    if (!state.biometric) return false;
    try {
      final ok = await LocalAuthentication().authenticate(
          localizedReason: reason, biometricOnly: true);
      if (ok) state = state.copyWith(unlocked: true);
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<void> setBiometric(bool on) async {
    await _storage.write(key: 'bio', value: on ? '1' : '0');
    state = state.copyWith(biometric: on);
  }

  Future<void> removePin() async {
    await _storage.delete(key: 'pin_hash');
    await _storage.delete(key: 'pin_salt');
    await _storage.write(key: 'bio', value: '0');
    state = const LockState(loaded: true);
  }

  void lock() {
    if (state.hasPin) state = state.copyWith(unlocked: false);
  }
}

final lockProvider = NotifierProvider<LockController, LockState>(LockController.new);
