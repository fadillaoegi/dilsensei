import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/monetization/domain/subscription_models.dart';
import '../../../../core/monetization/monetization_config.dart';
import '../../../../core/monetization/monetization_providers.dart';
import '../../../../core/theme/app_theme.dart';
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
  static const _benefits = <String>[
    'Seluruh modul dan sesi tanpa batas harian',
    'Peta pola kelemahan lengkap, bukan ringkasan',
    'Sesi otomatis dari pola yang belum jadi refleks',
    'Riwayat skor refleks dan perkembangan mingguan',
  ];

  String? _selectedPlanId;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(subscriptionPlansProvider);

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
                    Text(
                      'Buka\nPotensi\nPenuhmu',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.primary,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Jangan biarkan memori ototmu terputus. Latih pola yang '
                      'masih membuatmu ragu, sampai bahasa Jepang keluar tanpa '
                      'kamu pikirkan.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    for (final benefit in _benefits)
                      _BenefitRow(label: benefit),
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
    final planId = _resolvePlanId(plans);
    if (planId == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    final result = await ref.read(subscriptionServiceProvider).purchase(planId);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    switch (result.outcome) {
      case PurchaseOutcome.success:
        _showMessage('Langganan aktif. Selamat berlatih!');
        Navigator.of(context).pop();
      case PurchaseOutcome.cancelled:
        break;
      case PurchaseOutcome.failed:
        _showMessage(result.message ?? 'Pembelian gagal.');
    }
  }

  Future<void> _restore() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    final result = await ref
        .read(subscriptionServiceProvider)
        .restorePurchases();
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result.isSuccess) {
      _showMessage('Langganan berhasil dipulihkan.');
      Navigator.of(context).pop();
      return;
    }

    _showMessage(result.message ?? 'Tidak ada langganan untuk dipulihkan.');
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showMessage('Tidak bisa membuka $url');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
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
            color: AppColors.textSecondary,
            tooltip: 'Tutup',
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
        'Mengambil harga dari store...',
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Harga belum bisa ditampilkan',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Periksa koneksimu, lalu muat ulang daftar paket.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Muat Ulang')),
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
          const Icon(Icons.check_rounded, size: 20, color: AppColors.primary),
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
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.white,
                      ),
                    )
                  : const Text('Mulai Langganan'),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: isProcessing ? null : onRestore,
            child: const Text('Restore Purchases'),
          ),
          Text(
            'Langganan diperpanjang otomatis sampai dibatalkan. '
            'Pembatalan dilakukan lewat pengaturan akun store.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => onOpenLink(MonetizationConfig.termsUrl),
                child: const Text('Terms of Use'),
              ),
              Text('·', style: Theme.of(context).textTheme.bodySmall),
              TextButton(
                onPressed: () =>
                    onOpenLink(MonetizationConfig.privacyPolicyUrl),
                child: const Text('Privacy Policy'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
