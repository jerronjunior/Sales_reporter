import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../widgets/stat_card.dart';
import '../widgets/app_error_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth   = ref.watch(authProvider);
    final report = ref.watch(reportProvider);
    final scheme = Theme.of(context).colorScheme;
    Widget loaderOrError() {
      if (report.isLoading) return const Center(child: CircularProgressIndicator());
      if (report.error != null) {
        return AppErrorWidget(
          message: report.error!,
          onRetry: () => ref.read(reportProvider.notifier).fetchAll(),
        );
      }
      return const SizedBox.shrink();
    }

    String compact(num? n) {
      if (n == null) return '0';
      if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
      if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
      return n.toString();
    }

    String currency(num? n) => '\$${n == null ? 0 : n.toInt()}';

    final stats = report.stats;

    final body = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back,', style: TextStyle(color: scheme.onPrimary.withOpacity(0.9))),
                const SizedBox(height: 4),
                Text(auth.user?.name ?? 'User', style: TextStyle(color: scheme.onPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              StatCard(title: 'Customers', value: compact(stats?.totalCustomers), icon: Icons.people_outline, color: Colors.blue),
              StatCard(title: 'Sales', value: compact(stats?.totalSales), icon: Icons.shopping_bag_outlined, color: Colors.green),
              StatCard(title: 'Revenue', value: currency(stats?.totalRevenue), icon: Icons.attach_money, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 18),
          Text('Recent months', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...report.reports.reversed.take(4).map((r) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.calendar_month, color: scheme.primary),
                  title: Text(r.month),
                  subtitle: Text('${r.orders} orders'),
                  trailing: Text(currency(r.revenue), style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              )),
        ],
      ),
    );

    final loader = loaderOrError();
    if (loader is! SizedBox) return loader;

    return RefreshIndicator(onRefresh: () => ref.read(reportProvider.notifier).fetchAll(), child: body);
  }
}
