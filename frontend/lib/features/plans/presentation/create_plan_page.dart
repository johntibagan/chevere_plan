import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_form_card.dart';
import '../../../core/widgets/app_section_label.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/coming_soon_page.dart';
import '../data/plan_builder.dart';
import '../data/plan_models.dart';
import '../data/plans_repository.dart';
import 'plan_builder_page.dart';

/// Paso 1: título, zona, públicos y tope → borrador y builder.
class CreatePlanPage extends ConsumerStatefulWidget {
  const CreatePlanPage({super.key, required this.repository});

  final PlansRepository repository;

  @override
  ConsumerState<CreatePlanPage> createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends ConsumerState<CreatePlanPage> {
  final _titleCtrl = TextEditingController();
  final _zoneCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  bool _includePublic = true;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _zoneCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDec({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surfaceElevated,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }

  Future<void> _next() async {
    setState(() => _saving = true);
    try {
      final budgetRaw = _budgetCtrl.text.trim().replaceAll(',', '.');
      final budget = budgetRaw.isEmpty ? null : double.tryParse(budgetRaw);
      final zone = _zoneCtrl.text.trim();
      final title = _titleCtrl.text.trim();
      final Plan plan;
      if (title.isEmpty && zone.isEmpty) {
        plan = await widget.repository.createDraft(title: '');
      } else {
        plan = await widget.repository.createPlan(
          title: title,
          locationQuery: zone,
          includePublic: _includePublic,
          maxBudget: budget,
          orderedStops: const <PlanCandidate>[],
        );
      }
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
          builder: (_) => PlanBuilderPage(
            planId: plan.id,
            repository: widget.repository,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error(context, e, logContext: 'create_plan_draft');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.planCreateTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          ComingSoonCard(
            title: l10n.planCreateAiCta,
            subtitle: l10n.comingSoonBadge,
            pageTitle: l10n.comingSoonAiTitle,
            pageBody: l10n.comingSoonAiBody,
          ),
          const SizedBox(height: 20),
          AppSectionLabel(text: l10n.planTitleOptional, bottom: 8),
          TextField(
            controller: _titleCtrl,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            decoration: _fieldDec(hint: l10n.planCreateStepTitleHint),
          ),
          const SizedBox(height: 16),
          AppSectionLabel(text: l10n.planStatZone, bottom: 8),
          TextField(
            controller: _zoneCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: _fieldDec(hint: l10n.planZoneHint),
          ),
          const SizedBox(height: 16),
          AppFormCard(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.searchIncludePublic,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      ),
                      Text(
                        l10n.planIncludePublicSubtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.mutedDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _includePublic,
                  onChanged: (v) => setState(() => _includePublic = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSectionLabel(text: l10n.planStatBudget, bottom: 8),
          TextField(
            controller: _budgetCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _fieldDec(hint: l10n.searchBudgetMax).copyWith(
              prefixText: NumberFormat.simpleCurrency(
                name: 'COP',
                locale: 'es',
              ).currencySymbol,
              suffixText: 'COP',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _next,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.planCreateNextStops),
          ),
        ],
      ),
    );
  }
}
