import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/di/providers.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_section_label.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/discard_changes_scope.dart';
import '../data/plan_builder.dart';
import '../data/plan_models.dart';
import '../data/plans_repository.dart';
import 'plan_detail_page.dart';

/// Crear o editar datos del plan (título, zona, presupuesto).
/// Las paradas se arman en [PlanDetailPage].
class CreatePlanPage extends ConsumerStatefulWidget {
  const CreatePlanPage({
    super.key,
    required this.repository,
    this.existing,
  });

  final PlansRepository repository;
  final Plan? existing;

  @override
  ConsumerState<CreatePlanPage> createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends ConsumerState<CreatePlanPage> {
  final _titleCtrl = TextEditingController();
  final _zoneCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _budgetFocus = FocusNode();
  bool _saving = false;
  final FormDirtyTracker _formDirty = FormDirtyTracker();

  bool get _isEdit => widget.existing != null;

  bool get _titleValid => _titleCtrl.text.trim().length >= 3;

  @override
  void initState() {
    super.initState();
    void rebuildOnEdit() {
      if (mounted) setState(() {});
    }
    final p = widget.existing;
    if (p != null) {
      final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (!p.isOwnedBy(uid)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          AppToast.show(context, context.l10n.planEditNotOwner, error: true);
          Navigator.of(context).pop();
        });
        return;
      }
      final defaultTitle = p.title.trim() == 'Plan sin título';
      _titleCtrl.text = defaultTitle ? '' : p.title;
      _zoneCtrl.text = p.locationQuery;
      final budget = p.maxBudgetAmount;
      if (budget != null) {
        _budgetCtrl.text = budget == budget.roundToDouble()
            ? budget.round().toString()
            : '$budget';
      }
    }
    _titleCtrl.addListener(rebuildOnEdit);
    _zoneCtrl.addListener(rebuildOnEdit);
    _budgetCtrl.addListener(rebuildOnEdit);
    _formDirty.arm();
  }

  @override
  void dispose() {
    _formDirty.dispose();
    _titleCtrl.dispose();
    _zoneCtrl.dispose();
    _budgetCtrl.dispose();
    _budgetFocus.dispose();
    super.dispose();
  }

  void _submitFromKeyboard() {
    if (_saving) return;
    if (!_titleValid) {
      AppToast.show(context, context.l10n.planTitleMinLength, error: true);
      return;
    }
    unawaited(_next());
  }

  InputDecoration _fieldDec({
    required TextEditingController controller,
    String? hint,
    String? helper,
    String? prefixText,
    String? suffixText,
  }) {
    final hasText = controller.text.isNotEmpty;
    return InputDecoration(
      hintText: hint,
      helperText: helper,
      helperMaxLines: 2,
      filled: true,
      fillColor: AppColors.surfaceElevated,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      prefixText: prefixText,
      suffixText: suffixText,
      suffixIcon: hasText
          ? IconButton(
              tooltip: context.l10n.actionClear,
              icon: Icon(Icons.cancel_rounded, size: 20, color: AppColors.muted),
              onPressed: () => controller.clear(),
            )
          : null,
    );
  }

  Future<void> _next() async {
    final title = _titleCtrl.text.trim();
    if (title.length < 3) {
      AppToast.show(context, context.l10n.planTitleMinLength, error: true);
      return;
    }
    setState(() => _saving = true);
    _formDirty.setSuppressed(true);
    try {
      final budgetRaw = _budgetCtrl.text.trim().replaceAll(',', '.');
      final budget = budgetRaw.isEmpty ? null : double.tryParse(budgetRaw);
      final zone = _zoneCtrl.text.trim();
      final existing = widget.existing;
      if (existing != null) {
        await widget.repository.updatePlanMeta(
          planId: existing.id,
          title: title,
          locationQuery: zone,
          maxBudget: budget,
        );
        final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
        if (uid != null) {
          await ref
              .read(entityCacheStoreProvider)
              .invalidate(CacheKeys.plansPage0(uid));
        }
        ref.invalidate(plansProvider);
        if (!mounted) return;
        AppToast.show(context, context.l10n.planEditSaved);
        Navigator.of(context).pop(true);
        return;
      }
      final Plan plan = await widget.repository.createPlan(
        title: title,
        locationQuery: zone,
        maxBudget: budget,
        orderedStops: const <PlanCandidate>[],
      );
      final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (uid != null) {
        await ref
            .read(entityCacheStoreProvider)
            .invalidate(CacheKeys.plansPage0(uid));
      }
      ref.invalidate(plansProvider);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => PlanDetailPage(
            planId: plan.id,
            repository: widget.repository,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _formDirty.setSuppressed(false);
      AppToast.error(context, e, logContext: 'create_plan_draft');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currencyCode =
        widget.existing?.currencyCode ?? kDefaultCurrencyCode;

    return ListenableBuilder(
      listenable: _formDirty,
      builder: (context, _) => DiscardChangesScope(
        hasUnsavedChanges: _formDirty.hasUnsavedChanges,
        child: Scaffold(
          key: WidgetKeys.createPlanPage,
          appBar: AppBar(
            title: Text(_isEdit ? l10n.planEditTitle : l10n.planCreateTitle),
          ),
          body: DirtyInteractionScope(
            tracker: _formDirty,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                AppSectionLabel(
                  text: l10n.planTitleOptional,
                  required: true,
                  bottom: 8,
                ),
                TextField(
                  key: WidgetKeys.createPlanTitle,
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submitFromKeyboard(),
                  decoration: _fieldDec(
                    controller: _titleCtrl,
                    hint: _isEdit
                        ? l10n.planEditTitleHint
                        : l10n.planCreateStepTitleHint,
                    helper: l10n.planCreateTitleHelper,
                  ),
                ),
                SizedBox(height: 16),
                AppSectionLabel(text: l10n.planStatZone, bottom: 8),
                TextField(
                  key: WidgetKeys.createPlanZone,
                  controller: _zoneCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _budgetFocus.requestFocus(),
                  decoration: _fieldDec(
                    controller: _zoneCtrl,
                    hint: l10n.planZoneHint,
                    helper: l10n.planCreateZoneHelper,
                  ),
                ),
                SizedBox(height: 16),
                AppSectionLabel(text: l10n.planStatBudget, bottom: 8),
                TextField(
                  key: WidgetKeys.createPlanBudget,
                  controller: _budgetCtrl,
                  focusNode: _budgetFocus,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submitFromKeyboard(),
                  decoration: _fieldDec(
                    controller: _budgetCtrl,
                    hint: l10n.searchBudgetMax,
                    helper: l10n.planCreateBudgetHelper,
                    prefixText: currencyInputPrefix(currencyCode),
                    suffixText: currencyInputSuffix(currencyCode),
                  ),
                ),
                SizedBox(height: 24),
                FilledButton(
                  key: WidgetKeys.createPlanNext,
                  onPressed: (_saving || !_titleValid) ? null : _next,
                  child: _saving
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isEdit
                              ? l10n.actionSave
                              : l10n.planCreateNextStops,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
