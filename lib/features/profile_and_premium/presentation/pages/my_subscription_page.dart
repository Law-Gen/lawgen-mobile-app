// lib/features/profile_and_premium/presentation/pages/my_subscription_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    final status = await getSubscriptionStatus();
    setState(() => _status = status);
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat.yMMMd().format(date) : 'N/A';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Subscription')),
      body: _status == null
          ? const Center(child: CircularProgressIndicator())
          : !_status!.isActive
              ? const Center(child: Text('No active subscription.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    ListTile(
                        title: const Text('Current Plan'),
                        subtitle: Text(_status!.planName ?? 'N/A')),
                    ListTile(
                      title: const Text('Status'),
                      subtitle: Text(
                        _status!.status ?? 'N/A',
                        style: TextStyle(
                            color:
                                _status!.isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                        title: const Text('Start Date'),
                        subtitle: Text(_formatDate(_status!.startDate))),
                    ListTile(
                        title: const Text('End Date'),
                        subtitle: Text(_formatDate(_status!.endDate))),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => showCancelSubscriptionDialog(context,
                          onConfirm: _loadSubscription),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Cancel Subscription'),
                    ),
                  ]),
                ),
    );
  }
}
