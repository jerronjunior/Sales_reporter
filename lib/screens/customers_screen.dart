import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/customer_tile.dart';
import '../widgets/app_error_widget.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(customerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (q) => ref.read(customerProvider.notifier).search(q),
            decoration: InputDecoration(
              hintText: 'Search by name...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        ref.read(customerProvider.notifier).search('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Count
        if (!state.isLoading && state.error == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${state.filtered.length} customer${state.filtered.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurface.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
        // Content
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? AppErrorWidget(
                      message: state.error!,
                      onRetry: () => ref
                          .read(customerProvider.notifier)
                          .fetch(refresh: true),
                    )
                  : state.filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_search_outlined,
                                  size: 52,
                                  color: scheme.onSurface.withOpacity(0.3)),
                              const SizedBox(height: 12),
                              Text(
                                _searchCtrl.text.isEmpty
                                    ? 'No customers found'
                                    : 'No results for "${_searchCtrl.text}"',
                                style: TextStyle(
                                    color: scheme.onSurface.withOpacity(0.5)),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => ref
                              .read(customerProvider.notifier)
                              .fetch(refresh: true),
                          child: ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.only(bottom: 20, top: 4),
                            itemCount: state.filtered.length +
                                (state.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i == state.filtered.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              return CustomerTile(customer: state.filtered[i]);
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}
