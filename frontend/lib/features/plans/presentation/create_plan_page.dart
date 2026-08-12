import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../data/plans_repository.dart';
import 'plan_builder_page.dart';

/// Paso 1: solo título → crea borrador y abre el builder.
class CreatePlanPage extends ConsumerStatefulWidget {
  const CreatePlanPage({super.key, required this.repository});

  final PlansRepository repository;

  @override
  ConsumerState<CreatePlanPage> createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends ConsumerState<CreatePlanPage> {
  final _titleCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    setState(() => _saving = true);
    try {
      final plan = await widget.repository.createDraft(title: _titleCtrl.text);
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
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.planCreateStepTitleHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                if (!_saving) _next();
              },
              decoration: InputDecoration(
                labelText: l10n.planTitleOptional,
                border: const OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _saving ? null : _next,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.actionNext),
            ),
          ],
        ),
      ),
    );
  }
}
