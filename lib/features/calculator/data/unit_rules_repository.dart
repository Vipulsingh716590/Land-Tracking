import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/unit_rule.dart';
import 'unit_rules_seed.dart';

const _key = 'unit_rules_v1';

class UnitRulesRepository {
  Future<List<UnitRule>> load() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw != null) {
        return [
          for (final e in jsonDecode(raw) as List)
            UnitRule.fromJson(e as Map<String, dynamic>)
        ];
      }
    } catch (_) {}
    return unitRulesSeed;
  }

  Future<void> save(List<UnitRule> rules) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_key, jsonEncode([for (final r in rules) r.toJson()]));
    } catch (_) {}
  }
}

final unitRulesRepositoryProvider =
    Provider<UnitRulesRepository>((_) => UnitRulesRepository());

class UnitRulesNotifier extends Notifier<List<UnitRule>> {
  @override
  List<UnitRule> build() {
    _init();
    return unitRulesSeed;
  }

  Future<void> _init() async {
    state = await ref.read(unitRulesRepositoryProvider).load();
  }

  void upsert(UnitRule rule) {
    final i = state.indexWhere((r) => r.id == rule.id);
    state = i < 0
        ? [...state, rule]
        : [for (final r in state) r.id == rule.id ? rule : r];
    ref.read(unitRulesRepositoryProvider).save(state);
  }

  void remove(String id) {
    state = [for (final r in state) if (r.id != id) r];
    ref.read(unitRulesRepositoryProvider).save(state);
  }
}

final unitRulesProvider =
    NotifierProvider<UnitRulesNotifier, List<UnitRule>>(UnitRulesNotifier.new);
