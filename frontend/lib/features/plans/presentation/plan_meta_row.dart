import 'package:flutter/material.dart';

import '../../../core/formatters/date_format.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../data/plan_models.dart';

/// Meta de plan (lista y ficha): sitios → zona → presupuesto → fechas.
/// Una sola fila, sin `|`, sin wrap; scroll horizontal si no cabe.
class PlanMetaRow extends StatelessWidget {
  const PlanMetaRow({
    super.key,
    required this.plan,
    this.compact = false,
  });

  final Plan plan;
  /// Cards de lista (muted). Ficha = onImage.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final zone = plan.locationQuery.trim();
    final budget = plan.maxBudgetAmount;
    final budgetText = budget == null
        ? null
        : formatMoney(budget, currencyCode: plan.currencyCode);
    final datesText = formatPlanDateRange(plan.startDate, plan.endDate);
    final stopsLabel = l10n.planStopsCount(plan.stopCount);

    final fg = compact ? AppColors.muted : AppColors.onImage;
    final moneyColor = AppColors.success;
    final iconSize = compact ? 12.0 : 14.0;
    final fontSize = compact ? 11.0 : 12.0;
    final gap = compact ? 4.0 : 5.0;
    final chunkGap = compact ? 10.0 : 8.0;
    final style = TextStyle(fontSize: fontSize, color: fg, height: 1.1);
    final moneyStyle = TextStyle(
      fontSize: fontSize,
      color: moneyColor,
      height: 1.1,
    );

    final chunks = <Widget>[
      _chunk(
        icon: Icons.trending_up_rounded,
        iconColor: AppColors.primary,
        iconSize: iconSize,
        gap: gap,
        child: Text(stopsLabel, softWrap: false, style: style),
      ),
      if (zone.isNotEmpty)
        _chunk(
          icon: Icons.place_outlined,
          iconColor: AppColors.accent,
          iconSize: iconSize,
          gap: gap,
          child: Text(zone, softWrap: false, style: style),
        ),
      if (budgetText != null)
        _chunk(
          icon: Icons.attach_money_rounded,
          iconColor: moneyColor,
          iconSize: iconSize,
          gap: gap - 2,
          child: Text(budgetText, softWrap: false, style: moneyStyle),
        ),
      if (datesText != null)
        _chunk(
          icon: Icons.event,
          iconColor: fg,
          iconSize: iconSize,
          gap: gap,
          child: Text(datesText, softWrap: false, style: style),
        ),
    ];

    if (chunks.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (var i = 0; i < chunks.length; i++) ...[
              if (i > 0) SizedBox(width: chunkGap),
              chunks[i],
            ],
          ],
        ),
      ),
    );
  }

  static Widget _chunk({
    required IconData icon,
    required Color iconColor,
    required double iconSize,
    required double gap,
    required Widget child,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: iconColor),
        SizedBox(width: gap),
        child,
      ],
    );
  }
}
