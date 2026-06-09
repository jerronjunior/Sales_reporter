import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerTile extends StatelessWidget {
  final Customer customer;

  const CustomerTile({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initials = customer.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Text(
            initials,
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(Icons.mail_outline,
                    size: 13, color: scheme.onSurface.withOpacity(0.5)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    customer.email,
                    style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withOpacity(0.6)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.phone_outlined,
                    size: 13, color: scheme.onSurface.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(
                  customer.phone,
                  style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
