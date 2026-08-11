import 'package:flutter/material.dart';

import '../legal_texts.dart';

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  static Future<void> openTerms(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LegalDocumentPage(
          title: LegalTexts.termsTitle,
          body: LegalTexts.termsBody,
        ),
      ),
    );
  }

  static Future<void> openPrivacy(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LegalDocumentPage(
          title: LegalTexts.privacyTitle,
          body: LegalTexts.privacyBody,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Text(body, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
