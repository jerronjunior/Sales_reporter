import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../widgets/stat_card.dart';
import '../widgets/app_error_widget.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth   = ref.watch(authProvider);
    final report = ref.watch(reportProvider);
    final scheme = Theme.of(context).colorScheme;

    final fmt     = NumberFormat.compact(locale: 'en_US');
    final currFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    if (report.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (report.error != null) {
      return AppErrorWidget(
        message: report.error!,
        onRetry: () => ref.read(reportProvider.notifier).fetchAll(),
      );
    }

    final stats = report.stats;

    return RefreshIndicator(
      onRefresh: () => ref.read(reportProvider.notifier).fetchAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: scheme.onPrimary.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.user?.name ?? 'User',
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Here's your sales overview",
                    style: TextStyle(
                      color: scheme.onPrimary.withOpacity(0.75),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Overview',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            // ── Stats grid (fixed height per cell — never overflows) ──
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 148, // fixed pixel height — no overflow
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return StatCard(
                      title: 'Total Customers',
                      value: fmt.format(stats?.totalCustomers ?? 0),
                      icon: Icons.people_alt_outlined,
                      color: const Color(0xFF1565C0),
                    );
                  case 1:
                    return StatCard(
                      title: 'Total Sales',
                      value: fmt.format(stats?.totalSales ?? 0),
                      icon: Icons.shopping_cart_outlined,
                      color: const Color(0xFF2E7D32),
                    );
                  case 2:
                    return StatCard(
                      title: 'Total Revenue',
                      value: currFmt.format(stats?.totalRevenue ?? 0),
                      icon: Icons.attach_money_rounded,
                      color: const Color(0xFFE65100),
                    );
                  case 3:
                    return StatCard(
                      title: 'Avg. Order',
                      value: stats != null && stats.totalSales > 0
                          ? currFmt.format(stats.totalRevenue / stats.totalSales)
                          : '\$0',
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFF6A1B9A),
                    );
                  default:
                    return const SizedBox();
                }
              },
            ),

            const SizedBox(height: 24),
            Text(
              'Recent months',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...report.reports.reversed.take(4).map(
              (r) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.calendar_month_outlined,
                        size: 20, color: scheme.secondary),
                  ),
                  title: Text(r.month,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('${r.orders} orders',
                      style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withOpacity(0.55))),
                  trailing: Text(
                    currFmt.format(r.revenue),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}