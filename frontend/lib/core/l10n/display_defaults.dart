/// Fallbacks de texto cuando la DB no trae dato (deben coincidir con `.arb`).
abstract final class DisplayDefaults {
  DisplayDefaults._();

  /// `defaultUserDisplayName` en `app_es.arb`.
  static const userDisplayName = 'Usuario';
}
