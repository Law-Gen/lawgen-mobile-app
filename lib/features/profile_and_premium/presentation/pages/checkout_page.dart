// lib/features/profile_and_premium/presentation/pages/checkout_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../dependency_injection.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/usecases/initialize_payment.dart';
import 'payment_confirmation_page.dart';

class CheckoutPage extends StatefulWidget {
  final SubscriptionPlan plan;
  const CheckoutPage({super.key, required this.plan});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final InitializePayment initializePayment = sl<InitializePayment>();
  bool _isLoading = false;

  void _proceedToPayment() async {
    setState(() => _isLoading = true);
    try {
      // The Use Case call is now correct
      final paymentData = await initializePayment(
          widget.plan, "user123"); // Placeholder user ID

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebView(
              checkoutUrl: paymentData.checkoutUrl,
              txRef: paymentData.txRef,
              plan: widget.plan,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment Error'),
        content: Text(message),
        actions: [
          TextButton(
              child: const Text('Okay'),
              onPressed: () => Navigator.of(ctx).pop())
        ],
      ),
    );
  }

  // --- THIS BUILD METHOD WAS MISSING ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('You have selected: ${widget.plan.name}'),
            Text('Price: ETB ${widget.plan.price}'),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _proceedToPayment,
                    child: const Text('Proceed to Payment')),
          ],
        ),
      ),
    );
  }
}

// --- THIS CLASS WAS INCORRECTLY PLACED INSIDE THE OTHER ---
class PaymentWebView extends StatefulWidget {
  final String checkoutUrl;
  final String txRef;
  final SubscriptionPlan plan;

  const PaymentWebView({
    super.key,
    required this.checkoutUrl,
    required this.txRef,
    required this.plan,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    if (!kIsWeb) {
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      _controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith("https://myapp.com/payment-success")) {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentConfirmationPage(
                      txRef: widget.txRef, plan: widget.plan),
                ),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    }
    _controller.loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
