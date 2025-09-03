// lib/features/profile_and_premium/presentation/pages/plans_page.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../dependency_injection.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/usecases/get_subscription_plans.dart';
import 'checkout_page.dart';
import 'my_subscription_page.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final GetSubscriptionPlans getSubscriptionPlans = sl<GetSubscriptionPlans>();
  late Future<List<SubscriptionPlan>> _plansFuture;

  @override
  void initState() {
    super.initState();
    _plansFuture = getSubscriptionPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plans & Pricing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_membership),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MySubscriptionPage())),
          )
        ],
      ),
      body: FutureBuilder<List<SubscriptionPlan>>(
        future: _plansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No subscription plans found.'));
          }
          final plans = snapshot.data!;
          // Use a ListView for scrollable content
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              return _buildPlanCard(plans[index]);
            },
          );
        },
      ),
    );
  }

  // --- THIS WIDGET CONTAINS THE FIX ---
  // Inside _PlansPageState in plans_page.dart

// --- THIS WIDGET CONTAINS THE FINAL FIX ---
  Widget _buildPlanCard(SubscriptionPlan plan) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Title
            Text(plan.name, style: textTheme.headlineSmall),
            const SizedBox(height: 8),

            // --- START OF THE FIX ---
            // Use RichText for complex, multi-style text that needs to wrap.
            RichText(
              text: TextSpan(
                // The default style for this paragraph
                style: textTheme.bodyLarge,
                children: <TextSpan>[
                  // The Price part
                  TextSpan(
                    text:
                        'ETB ${plan.price.toInt()} ', // Added a space for separation
                    style: textTheme.displayLarge,
                  ),
                  // The Description part
                  TextSpan(
                    text: plan.description,
                    // This part will use the default style (textTheme.bodyLarge)
                  ),
                ],
              ),
            ),
            // --- END OF THE FIX ---

            const SizedBox(height: 24),
            Text('Features:', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Column(
              children: plan.features
                  .map((feature) => _buildFeatureRow(feature))
                  .toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CheckoutPage(plan: plan)),
                ),
                child: const Text('Upgrade'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
