// lib/features/profile_and_premium/presentation/pages/payment_confirmation_page.dart
import 'package:flutter/material.dart';
import '../../../../dependency_injection.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/usecases/notify_backend.dart';
import '../../domain/usecases/verify_payment.dart';
import 'my_subscription_page.dart';

class PaymentConfirmationPage extends StatefulWidget {
  final String txRef;
  final SubscriptionPlan plan;
  const PaymentConfirmationPage(
      {super.key, required this.txRef, required this.plan});

  @override
  State<PaymentConfirmationPage> createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  final VerifyPayment verifyPayment = sl<VerifyPayment>();
  final NotifyBackend notifyBackend = sl<NotifyBackend>();
  late Future<bool> _verificationFuture;

  @override
  void initState() {
    super.initState();
    _verificationFuture = _verifyAndNotify();
  }

  Future<bool> _verifyAndNotify() async {
    try {
      final isSuccess = await verifyPayment(widget.txRef, widget.plan);
      // --- FIX: Added the missing userId argument ---
      await notifyBackend(
        isSuccess ? 'activated' : 'failed',
        widget.txRef,
        widget.plan.name,
        "user123", // Placeholder user ID
      );
      return isSuccess;
    } catch (e) {
      // --- FIX: Added the missing userId argument ---
      await notifyBackend('failed', widget.txRef, widget.plan.name, "user123");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Status')),
      body: FutureBuilder<bool>(
        future: _verificationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final isSuccess = snapshot.data ?? false;
          if (isSuccess) {
            return _buildStatusWidget(
              icon: Icons.check_circle,
              color: Colors.green,
              title: 'Payment Successful!',
              message: 'Your ${widget.plan.name} plan is now active.',
            );
          } else {
            return _buildStatusWidget(
              icon: Icons.error,
              color: Colors.red,
              title: 'Payment Failed',
              message: 'Your payment could not be processed. Please try again.',
            );
          }
        },
      ),
    );
  }

  Widget _buildStatusWidget(
      {required IconData icon,
      required Color color,
      required String title,
      required String message}) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 100),
        const SizedBox(height: 20),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 10),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => const MySubscriptionPage()),
              (Route<dynamic> route) => false),
          child: const Text('Go to My Subscription'),
        ),
      ]),
    ));
  }
}
