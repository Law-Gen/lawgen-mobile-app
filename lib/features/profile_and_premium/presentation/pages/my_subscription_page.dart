// lib/features/profile_and_premium/presentation/pages/my_subscription_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../dependency_injection.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/usecases/get_subscription_status.dart';
import '../widgets/cancel_subscription_popup.dart';

class MySubscriptionPage extends StatefulWidget {
  const MySubscriptionPage({super.key});
  @override
  State<MySubscriptionPage> createState() => _MySubscriptionPageState();
}

class _MySubscriptionPageState extends State<MySubscriptionPage> {
  final GetSubscriptionStatus getSubscriptionStatus =
      sl<GetSubscriptionStatus>();
  SubscriptionStatus? _status;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    setState(() => _isLoading = true);
    final status = await getSubscriptionStatus();
    if (mounted) {
      setState(() {
        _status = status;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat.yMMMd().format(date) : 'N/A';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Subscription')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _status == null || !_status!.isActive
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'You do not have an active subscription.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInfoRow(
                              'Current Plan', _status!.planName ?? 'N/A'),
                          const Divider(),
                          _buildInfoRow(
                            'Status',
                            _status!.status ?? 'N/A',
                            valueStyle: TextStyle(
                              color: _status!.isActive
                                  ? AppColors.success
                                  : AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _buildInfoRow('Subscription Start Date',
                              _formatDate(_status!.startDate)),
                          const Divider(),
                          _buildInfoRow('Next Billing Date',
                              _formatDate(_status!.endDate)),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => showCancelSubscriptionDialog(
                                  context,
                                  onConfirm: _loadSubscription),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.1),
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              child: const Text('Cancel Subscription'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String title, String value, {TextStyle? valueStyle}) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: textTheme.bodyLarge),
          Text(value,
              style: valueStyle ??
                  textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
