import 'package:flutter/material.dart';

import '../../../../core/monetization/domain/subscription_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Kartu satu paket langganan pada paywall.
class PricingCard extends StatelessWidget {
  const PricingCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
    this.savingsPercent,
    super.key,
  });

  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  /// Persentase penghematan dibanding membayar bulanan, bila ada. Dihitung dari
  /// harga nyata di store, jadi angkanya benar di mata uang apa pun.
  final int? savingsPercent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected
            ? context.palette.surfaceAccent
            : context.palette.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: context.motion(const Duration(milliseconds: 180)),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? context.palette.primary
                    : context.palette.primary.withValues(alpha: 0.16),
                width: isSelected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              plan.titleFor(AppL10n.of(context)),
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (plan.isRecommended || savingsPercent != null) ...[
                            const SizedBox(width: 8),
                            // Wrap: dua badge berdampingan mudah meluber pada
                            // ponsel sempit, terutama saat mata uangnya panjang.
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (savingsPercent != null)
                                  _SavingsBadge(percent: savingsPercent!),
                                if (plan.isRecommended)
                                  const _RecommendedBadge(),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          // Flexible agar harga panjang tidak meluber di ponsel.
                          Flexible(
                            child: Text(
                              plan.priceLabel,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headlineSmall?.copyWith(
                                color: context.palette.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              plan.periodLabelFor(AppL10n.of(context)),
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      if (plan.trialDescriptionFor(AppL10n.of(context)) !=
                          null) ...[
                        const SizedBox(height: 6),
                        Text(
                          plan.trialDescriptionFor(AppL10n.of(context))!,
                          style: textTheme.bodySmall?.copyWith(
                            color: context.palette.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? context.palette.primary
                      : context.palette.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge penghematan untuk paket tahunan.
class _SavingsBadge extends StatelessWidget {
  const _SavingsBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.palette.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        AppL10n.of(context).paywallSavePercent(percent),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.palette.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _RecommendedBadge extends StatelessWidget {
  const _RecommendedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.palette.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        AppL10n.of(context).paywallRecommended,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.palette.onPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
