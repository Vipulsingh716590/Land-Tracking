import 'package:flutter/widgets.dart';
import 'package:ayodhya_zameen/app.dart';
import 'package:ayodhya_zameen/features/lock/lock_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('welcome is Hindi, toggles to English, opens calculator', (t) async {
    await t.pumpWidget(const ProviderScope(child: AyodhyaApp()));
    await t.pumpAndSettle();
    expect(find.text('अयोध्या ज़मीन'), findsOneWidget);
    await t.tap(find.text('English'));
    await t.pumpAndSettle();
    expect(find.text('Ayodhya Zameen'), findsOneWidget);
    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(find.text('DEMO'), findsWidgets);
    await t.scrollUntilVisible(find.textContaining('Information only'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('Information only'), findsOneWidget);
  });

  test('PIN lock: locks, rejects wrong PIN, accepts right PIN', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final lock = c.read(lockProvider.notifier);
    await lock.setPin('4321');
    expect(c.read(lockProvider).locked, isFalse);
    lock.lock();
    expect(c.read(lockProvider).locked, isTrue);
    expect(await lock.unlockWithPin('0000'), isFalse);
    expect(c.read(lockProvider).locked, isTrue);
    expect(await lock.unlockWithPin('4321'), isTrue);
    expect(c.read(lockProvider).locked, isFalse);
  });
}
