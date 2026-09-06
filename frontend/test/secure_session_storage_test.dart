import 'package:chevere_plan/core/auth/secure_session_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('SecureSessionStorage.parsePersistedSession', () {
    test('null / empty → null', () {
      expect(SecureSessionStorage.parsePersistedSession(null), isNull);
      expect(SecureSessionStorage.parsePersistedSession(''), isNull);
      expect(SecureSessionStorage.parsePersistedSession('   '), isNull);
    });

    test('invalid JSON → null', () {
      expect(SecureSessionStorage.parsePersistedSession('{nope'), isNull);
      expect(SecureSessionStorage.parsePersistedSession('"string"'), isNull);
    });

    test('session JSON round-trip shape', () {
      const raw = '''
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.x",
  "token_type": "bearer",
  "expires_in": 3600,
  "expires_at": 9999999999,
  "refresh_token": "refresh-token",
  "user": {
    "id": "00000000-0000-4000-8000-000000000001",
    "aud": "authenticated",
    "role": "authenticated",
    "email": "test@example.com",
    "app_metadata": {},
    "user_metadata": {},
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
''';
      final session = SecureSessionStorage.parsePersistedSession(raw);
      expect(session, isA<Session>());
      expect(session!.user.id, '00000000-0000-4000-8000-000000000001');
      expect(session.refreshToken, 'refresh-token');
    });
  });
}
