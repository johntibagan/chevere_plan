import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/chevere_theme_scope.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/field_action_icon.dart';

/// Diálogo corto: URL de imagen + atribución opcional (staff / catálogo).
Future<void> showPasteExternalPhotoDialog({
  required BuildContext context,
  required Future<void> Function(String url, String? attribution) onSubmit,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _PasteExternalPhotoDialog(onSubmit: onSubmit),
  );
}

class _PasteExternalPhotoDialog extends StatefulWidget {
  const _PasteExternalPhotoDialog({required this.onSubmit});

  final Future<void> Function(String url, String? attribution) onSubmit;

  @override
  State<_PasteExternalPhotoDialog> createState() =>
      _PasteExternalPhotoDialogState();
}

class _PasteExternalPhotoDialogState extends State<_PasteExternalPhotoDialog> {
  final _urlCtrl = TextEditingController();
  final _attrCtrl = TextEditingController();
  final _urlFocus = FocusNode();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _urlCtrl.addListener(_onText);
    _attrCtrl.addListener(_onText);
  }

  void _onText() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _urlCtrl.removeListener(_onText);
    _attrCtrl.removeListener(_onText);
    _urlCtrl.dispose();
    _attrCtrl.dispose();
    _urlFocus.dispose();
    super.dispose();
  }

  Future<void> _pasteUrl() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    _urlCtrl.text = text;
    _urlCtrl.selection = TextSelection.collapsed(offset: text.length);
  }

  Future<void> _save() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      final attr = _attrCtrl.text.trim();
      await widget.onSubmit(url, attr.isEmpty ? null : attr);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      if (e is AppUserError) {
        AppToast.show(context, e.message, error: true);
      } else {
        AppToast.error(context, e, logContext: 'paste_external_photo');
        AppToast.show(context, context.l10n.errorProblemToast, error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ChevereThemeScope.of(context);
    final l10n = context.l10n;
    final canSave = _urlCtrl.text.trim().isNotEmpty && !_busy;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      title: Text(
        l10n.photoPasteLinkTitle,
        style: AppTypography.cardTitle(color: AppColors.foreground),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _urlCtrl,
              focusNode: _urlFocus,
              autofocus: true,
              enabled: !_busy,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: AppColors.foreground),
              decoration: InputDecoration(
                labelText: l10n.photoPasteLinkUrlLabel,
                hintText: l10n.photoPasteLinkUrlHint,
                suffixIcon: _urlCtrl.text.isEmpty
                    ? FieldActionIcon(
                        icon: Icons.content_paste,
                        tooltip: l10n.actionPaste,
                        onPressed: _busy ? null : _pasteUrl,
                      )
                    : IconButton(
                        tooltip: l10n.actionClear,
                        onPressed: _busy
                            ? null
                            : () {
                                _urlCtrl.clear();
                                _urlFocus.requestFocus();
                              },
                        icon: Icon(
                          Icons.cancel_rounded,
                          size: 20,
                          color: AppColors.muted,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _attrCtrl,
              enabled: !_busy,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (canSave) unawaited(_save());
              },
              maxLength: 500,
              maxLines: 2,
              style: TextStyle(color: AppColors.foreground),
              decoration: InputDecoration(
                labelText: l10n.photoPasteLinkAttributionLabel,
                hintText: l10n.photoPasteLinkAttributionHint,
                helperText: l10n.photoPasteLinkAttributionHelper,
                counterText: '',
                suffixIcon: _attrCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.actionClear,
                        onPressed: _busy ? null : _attrCtrl.clear,
                        icon: Icon(
                          Icons.cancel_rounded,
                          size: 20,
                          color: AppColors.muted,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.maxFinite,
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.muted,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: Text(l10n.actionCancel),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: canSave ? _save : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: _busy
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(l10n.actionSave),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
