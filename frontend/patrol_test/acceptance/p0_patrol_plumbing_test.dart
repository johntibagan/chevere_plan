import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// No arranca Firebase/Supabase: solo valida que Patrol ↔ device funciona.
void main() {
  patrolTest(
    'P0 plumbing: Patrol encuentra widgets en device',
    ($) async {
      await $.pumpWidgetAndSettle(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('patrol_ok')),
          ),
        ),
      );
      expect($('patrol_ok'), findsOneWidget);
    },
  );
}
