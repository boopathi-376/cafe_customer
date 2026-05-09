import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../models/order.dart';
import '../provider/auth_provider.dart';
import '../provider/order_provider.dart';
import '../provider/rating_provider.dart';
import '../service/order_service.dart';
import 'order_update_screen/order_tracking_screen.dart';
import 'rate_order_screen.dart';

class ViewOrdersScreen extends StatefulWidget {
  const ViewOrdersScreen({super.key});

  @override
  State<ViewOrdersScreen> createState() => _ViewOrdersScreenState();
}

class _ViewOrdersScreenState extends State<ViewOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid =
          Provider.of<AuthenticationProvider>(context, listen: false)
              .user
              ?.uid;
      if (uid != null) {
        Provider.of<OrderProvider>(context, listen: false)
            .listenToOrders(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('Your Orders',
            style: tt.titleMedium?.copyWith(color: cs.onSurface)),
        centerTitle: true,
        backgroundColor: cs.surface,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orderProvider.error != null) {
            return Center(child: Text(orderProvider.error!));
          }
          final orders = orderProvider.orders;
          if (orders.isEmpty) {
            return Center(
                child: Text('No orders found.', style: tt.bodyMedium));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) =>
                _OrderCard(order: orders[index]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final CafeOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final date =
        DateFormat.yMMMd().add_jm().format(order.createdAt);

    return Card(
      color: cs.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OrderTrackingScreen(orderId: order.id ?? ''),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(order.customerName,
                        style: tt.titleMedium,
                        overflow: TextOverflow.ellipsis),
                  ),
                  _StatusBadge(order: order),
                ],
              ),
              const SizedBox(height: 4),
              Text(date,
                  style: tt.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}',
                  style: tt.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              if (order.notes != null &&
                  order.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Note: ${order.notes}',
                    style: tt.bodySmall),
              ],
              const Divider(height: 20),
              ...order.items.map((item) => Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.name} x${item.quantity}',
                            style: tt.bodySmall),
                        Text(
                            '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: tt.bodySmall),
                      ],
                    ),
                  )),
              if (order.status.canCancel) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.cancel,
                        color: Colors.redAccent),
                    label: const Text('Cancel Order',
                        style: TextStyle(color: Colors.redAccent)),
                    onPressed: () =>
                        _showCancelDialog(context, order),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCancelDialog(
      BuildContext context, CafeOrder order) async {
    String? reason;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Cancel Order'),
          content: DropdownButtonFormField<String>(
            value: reason,
            isExpanded: true,
            decoration:
                const InputDecoration(border: OutlineInputBorder()),
            hint: const Text('Select a reason'),
            items: const [
              DropdownMenuItem(
                  value: 'Ordered by mistake',
                  child: Text('Ordered by mistake')),
              DropdownMenuItem(
                  value: 'Wrong delivery address',
                  child: Text('Wrong delivery address')),
              DropdownMenuItem(
                  value: 'I need to cancel',
                  child: Text('I need to cancel')),
              DropdownMenuItem(
                  value: 'Other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => reason = v),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Back')),
            TextButton(
              onPressed: reason == null
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && reason != null) {
      await Provider.of<OrderProvider>(context, listen: false)
          .cancelOrder(order.id!, reason!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order cancelled.')));
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final CafeOrder order;
  const _StatusBadge({required this.order});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final status = order.status;

    // Rate Now badge for delivered + unrated
    if (status == OrderStatus.delivered && !order.hasRated) {
      return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          // Use first item's real menuItemId — not toString()
          final menuItemId = order.items.isNotEmpty
              ? order.items.first.menuItemId
              : '';
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => RatingProvider(),
                child: RateOrderScreen(
                  orderId: order.id!,
                  userId: order.uid,
                  menuItemId: menuItemId,
                ),
              ),
            ),
          );
          // Mark as rated after returning
          await OrderService().markAsRated(order.id!);
        },
        child: _badge(
            Icons.star_half, 'Rate Now',
            Colors.amber.shade100, Colors.amber.shade800, tt),
      );
    }

    if (status == OrderStatus.delivered && order.hasRated) {
      return _badge(Icons.check_circle, 'Rated',
          Colors.green.shade100, Colors.green.shade800, tt);
    }

    final (bg, fg, icon, label) = switch (status) {
      OrderStatus.pending => (
          cs.tertiaryContainer,
          cs.onTertiaryContainer,
          Icons.timelapse,
          status.label
        ),
      OrderStatus.cancelled => (
          cs.errorContainer,
          cs.onErrorContainer,
          Icons.cancel,
          status.label
        ),
      OrderStatus.completed => (
          cs.secondaryContainer,
          cs.onSecondaryContainer,
          Icons.check_circle,
          status.label
        ),
      _ => (
          cs.surfaceContainerHighest,
          cs.onSurfaceVariant,
          Icons.local_shipping_outlined,
          status.label
        ),
    };

    return _badge(icon, label, bg, fg, tt);
  }

  Widget _badge(IconData icon, String label, Color bg, Color fg,
      TextTheme tt) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(label,
              style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}
