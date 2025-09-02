// lib/features/profile_and_premium/presentation/pages/plans_page.dart
import 'package:flutter/material.dart';
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
        title: const Text('Subscription Plans'),
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
          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.name,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                          'ETB ${plan.price.toStringAsFixed(2)} / ${plan.durationInDays == 30 ? "Month" : "Year"}'),
                      const SizedBox(height: 8),
                      Text(plan.description),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CheckoutPage(plan: plan))),
                        child: const Text('Subscribe'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
