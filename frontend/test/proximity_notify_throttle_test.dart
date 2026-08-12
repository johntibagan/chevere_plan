import 'package:chevere_plan/features/proximity/data/proximity_notify_throttle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('dayKey formato local yyyy-MM-dd', () {
    expect(
      ProximityNotifyThrottle.dayKey(DateTime(2026, 8, 12, 23, 59)),
      '2026-08-12',
    );
  });

  test('shouldNotify una vez por sitio y día', () async {
    const site = 'site-abc';
    final day = DateTime(2026, 8, 12, 10);
    expect(await ProximityNotifyThrottle.shouldNotify(site, now: day), isTrue);
    await ProximityNotifyThrottle.markShown(site, now: day);
    expect(await ProximityNotifyThrottle.shouldNotify(site, now: day), isFalse);
    expect(
      await ProximityNotifyThrottle.shouldNotify(
        site,
        now: DateTime(2026, 8, 13, 1),
      ),
      isTrue,
    );
    expect(
      await ProximityNotifyThrottle.shouldNotify('otro', now: day),
      isTrue,
    );
  });

  test('clearAll resetea tope', () async {
    const site = 'site-xyz';
    final day = DateTime(2026, 8, 12);
    await ProximityNotifyThrottle.markShown(site, now: day);
    await ProximityNotifyThrottle.clearAll();
    expect(await ProximityNotifyThrottle.shouldNotify(site, now: day), isTrue);
  });
}
