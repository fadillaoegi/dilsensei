import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/analytics/analytics_providers.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/monetization/domain/subscription_models.dart';
import '../../../../core/monetization/monetization_config.dart';
import '../../../../core/monetization/monetization_providers.dart';
import '../../../../core/monetization/purchase_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/pricing_card.dart';

/// Paywall langganan.
///
/// Harga diambil langsung dari store lewat RevenueCat supaya mata uang dan
/// format harga selalu sesuai wilayah pengguna.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    // Dicatat sekali saat paywall dibuka, bukan pada setiap rebuild.
    ref.read(analyticsServiceProvider).log(AnalyticsEvent.paywallViewed);
  }

  String? _selectedPlanId;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final benefits = <String>[
      l10n.paywallBenefitModules,
      l10n.paywallBenefitMap,
      l10n.paywallBenefitAuto,
      l10n.paywallBenefitHistory,
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _PaywallHeader(
              onClose: _isProcessing ? null : () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    if (MonetizationConfig.isUsingTestStore)
                      const _TestStoreBanner(),
                    Text(
                      l10n.paywallHeadline,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: context.palette.primary,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.paywallBody,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.palette.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    for (final benefit in benefits) _BenefitRow(label: benefit),
                    const SizedBox(height: 24),
                    _PlanSection(
                      plansAsync: plansAsync,
                      selectedPlanId: _selectedPlanId,
                      onSelect: (planId) =>
                          setState(() => _selectedPlanId = planId),
                      onRetry: () => ref.invalidate(subscriptionPlansProvider),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _PaywallFooter(
              isProcessing: _isProcessing,
              canPurchase: _resolvePlanId(plansAsync.valueOrNull) != null,
              onPurchase: () => _purchase(plansAsync.valueOrNull),
              onRestore: _restore,
              onOpenLink: _openLink,
            ),
          ],
        ),
      ),
    );
  }

  /// Paket terpilih, atau paket yang direkomendasikan bila belum memilih.
  String? _resolvePlanId(List<SubscriptionPlan>? plans) {
    if (plans == null || plans.isEmpty) return null;
    if (_selectedPlanId != null) return _selectedPlanId;

    final recommended = plans.where((plan) => plan.isRecommended).firstOrNull;
    return (recommended ?? plans.first).id;
  }

  Future<void> _purchase(List<SubscriptionPlan>? plans) async {
    final l10n = AppL10n.of(context);
    final planId = _resolvePlanId(plans);
    if (planId == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.log(
      AnalyticsEvent.purchaseStarted,
      parameters: <String, Object>{'plan_id': planId},
    );

    final result = await ref.read(subscriptionServiceProvider).purchase(planId);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    switch (result.outcome) {
      case PurchaseOutcome.success:
        // Analytics tidak di-await sebelum navigasi supaya BuildContext tidak
        // dipakai melewati async gap; pencatatannya tetap terkirim.
        analytics.log(
          AnalyticsEvent.purchaseCompleted,
          parameters: <String, Object>{'plan_id': planId},
        );
        _showMessage(l10n.paywallPurchaseSuccess);
        Navigator.of(context).pop();
      case PurchaseOutcome.cancelled:
        break;
      case PurchaseOutcome.failed:
        analytics.log(
          AnalyticsEvent.purchaseFailed,
          parameters: <String, Object>{'reason': result.failure.name},
        );
        _showMessage(purchaseFailureMessage(l10n, result));
    }
  }

  Future<void> _restore() async {
    final l10n = AppL10n.of(context);
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    final result = await ref
        .read(subscriptionServiceProvider)
        .restorePurchases();
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result.isSuccess) {
      _showMessage(l10n.settingsRestoreSuccess);
      Navigator.of(context).pop();
      return;
    }

    _showMessage(purchaseFailureMessage(l10n, result));
  }

  Future<void> _openLink(String url) async {
    final l10n = AppL10n.of(context);
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showMessage(l10n.settingsCannotOpen(url));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Penanda bahwa app memakai Test Store RevenueCat.
///
/// Sengaja mencolok: pembelian di Test Store tidak menagih uang, jadi kalau
/// banner ini pernah terlihat di rilis produksi, berarti key-nya salah dan
/// seluruh konten premium sedang dibagikan gratis.
class _TestStoreBanner extends StatelessWidget {
  const _TestStoreBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.palette.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.palette.error.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.science_outlined, size: 18, color: context.palette.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppL10n.of(context).paywallTestStore,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.palette.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaywallHeader extends StatelessWidget {
  const _PaywallHeader({required this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: context.palette.textSecondary,
            tooltip: AppL10n.of(context).commonClose,
          ),
        ],
      ),
    );
  }
}

class _PlanSection extends StatelessWidget {
  const _PlanSection({
    required this.plansAsync,
    required this.selectedPlanId,
    required this.onSelect,
    required this.onRetry,
  });

  final AsyncValue<List<SubscriptionPlan>> plansAsync;
  final String? selectedPlanId;
  final ValueChanged<String> onSelect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return plansAsync.when(
      loading: () => Text(
        AppL10n.of(context).paywallPricesLoading,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      error: (error, _) => _PlansUnavailable(onRetry: onRetry),
      data: (plans) {
        if (plans.isEmpty) return _PlansUnavailable(onRetry: onRetry);

        final effectiveId =
            selectedPlanId ??
            (plans.where((plan) => plan.isRecommended).firstOrNull ??
                    plans.first)
                .id;

        return Column(
          children: [
            for (final plan in plans)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PricingCard(
                  plan: plan,
                  isSelected: plan.id == effectiveId,
                  onTap: () => onSelect(plan.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PlansUnavailable extends StatelessWidget {
  const _PlansUnavailable({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.palette.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppL10n.of(context).paywallPricesErrorTitle,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            AppL10n.of(context).paywallPricesErrorBody,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(AppL10n.of(context).commonReload),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_rounded, size: 20, color: context.palette.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaywallFooter extends StatelessWidget {
  const _PaywallFooter({
    required this.isProcessing,
    required this.canPurchase,
    required this.onPurchase,
    required this.onRestore,
    required this.onOpenLink,
  });

  final bool isProcessing;
  final bool canPurchase;
  final VoidCallback onPurchase;
  final VoidCallback onRestore;
  final ValueChanged<String> onOpenLink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isProcessing || !canPurchase ? null : onPurchase,
              child: isProcessing
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: context.palette.onPrimary,
                      ),
                    )
                  : Text(AppL10n.of(context).paywallCta),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: isProcessing ? null : onRestore,
            child: Text(AppL10n.of(context).paywallRestore),
          ),
          Text(
            AppL10n.of(context).paywallDisclosure,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          // Wrap, bukan Row: pada ponsel sempit kedua tautan tidak muat satu baris.
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                onPressed: () => onOpenLink(MonetizationConfig.termsUrl),
                child: Text(AppL10n.of(context).settingsTerms),
              ),
              Text('·', style: Theme.of(context).textTheme.bodySmall),
              TextButton(
                onPressed: () =>
                    onOpenLink(MonetizationConfig.privacyPolicyUrl),
                child: Text(AppL10n.of(context).settingsPrivacy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
