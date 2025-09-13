import 'package:cafe/view/ratingOrderScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../provider/auth_provider.dart';
import '../service/order_service.dart';
import 'order_update_screen/order_tracking_screen.dart';

class ViewOrdersScreen extends StatelessWidget {
  const ViewOrdersScreen({super.key});

  bool canCancelOrder(CafeOrder order) {
    return order.status.toLowerCase() == 'pending' &&
        order.status.isNotEmpty == true &&
        order.status.toLowerCase() != 'accepted';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final uid = authProvider.user?.uid ?? "";

    final colorScheme = Theme
        .of(context)
        .colorScheme;
    final textTheme = Theme
        .of(context)
        .textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text("Your Orders", style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: uid.isEmpty
          ? Center(
        child: Text("You're not logged in.", style: textTheme.bodyMedium),
      )
          : StreamBuilder<List<CafeOrder>>(
        stream: OrderService().getUserOrders(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Text("No orders found.", style: textTheme.bodyMedium),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final formattedDate = DateFormat.yMMMd().add_jm().format(
                  order.createdAt);

              return Card(
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                child: ExpansionTile(
                  onExpansionChanged: (expanded) async {
                    if (expanded) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OrderTrackingScreen(orderId: order.id ?? ''),
                        ),
                      );
                    }
                  },
                  tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  childrenPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              order.customerName, style: textTheme.titleMedium),
                          _buildStatusBadge(
                              order, colorScheme, textTheme, context),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16,
                              color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(order.customerPhone, style: textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total: ₹${order.totalAmount.toStringAsFixed(2)}",
                            style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formattedDate,
                            style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      if (order.notes != null && order.notes!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text("Note: ${order.notes}",
                              style: textTheme.bodySmall),
                        ),
                    ],
                  ),
                  children: [
                    const Divider(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Items", style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 6),
                    ...order.items.map(
                          (item) =>
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${item.name} x${item.quantity}",
                                    style: textTheme.bodySmall),
                                Text("₹${(item.price).toStringAsFixed(2)}",
                                    style: textTheme.bodySmall),
                              ],
                            ),
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (canCancelOrder(order))
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(
                              Icons.cancel, color: Colors.redAccent),
                          label: const Text("Cancel Order",
                              style: TextStyle(color: Colors.redAccent)),
                          onPressed: () async {
                            String? selectedReason;
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) {
                                return StatefulBuilder(
                                  builder: (context, setState) =>
                                      AlertDialog(
                                        title: const Text("Cancel Order"),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                  "Please select a reason:"),
                                              const SizedBox(height: 12),
                                              DropdownButtonFormField<String>(
                                                value: selectedReason,
                                                isExpanded: true,
                                                decoration: const InputDecoration(
                                                    border: OutlineInputBorder()),
                                                items: const [
                                                  DropdownMenuItem(
                                                      value: "I need to cancel the order",
                                                      child: Text(
                                                          "I need to cancel the order")),
                                                  DropdownMenuItem(
                                                      value: "Wrong delivery address",
                                                      child: Text(
                                                          "Wrong delivery address")),
                                                  DropdownMenuItem(
                                                      value: "Ordered by mistake",
                                                      child: Text(
                                                          "Ordered by mistake")),
                                                  DropdownMenuItem(
                                                      value: "Other",
                                                      child: Text("Other")),
                                                ],
                                                onChanged: (value) {
                                                  setState(() =>
                                                  selectedReason = value);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text("Back"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              if (selectedReason != null) {
                                                Navigator.pop(ctx, true);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(content: Text(
                                                      "Please select a reason to cancel")),
                                                );
                                              }
                                            },
                                            child: const Text("Confirm"),
                                          ),
                                        ],
                                      ),
                                );
                              },
                            );

                            if (confirm == true && selectedReason != null) {
                              await OrderService().updateOrderStatus(
                                  order.id!, "cancelled",
                                  reason: selectedReason);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Order cancelled.")),
                              );
                            }
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }


  Widget _buildStatusBadge(CafeOrder order,
      ColorScheme colorScheme,
      TextTheme textTheme,
      BuildContext context,) {
    final status = order.status.toLowerCase();

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;
    VoidCallback? onTap;

    if (status == 'delivered') {
      if (order.hasRated) {
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        label = 'Rated';
        onTap = null; // No action
      } else {
        backgroundColor = Colors.amber.shade100;
        textColor = Colors.amber.shade800;
        icon = Icons.star_half;
        label = 'Rate Now';
        onTap = () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RateOrderScreen(
                orderId: order.id!,              // from your order object
                userId: order.uid, menuItemId: order.items.toString(),
              ),
            ),
          );



          // Optional: Refresh or update state after returning from rating screen
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(order.id)
              .update({'hasRated': true});
        };
      }
    } else {
      switch (status) {
        case 'completed':
          backgroundColor = colorScheme.secondaryContainer;
          textColor = colorScheme.onSecondaryContainer;
          icon = Icons.check_circle;
          label = 'Completed';
          break;
        case 'pending':
          backgroundColor = colorScheme.tertiaryContainer;
          textColor = colorScheme.onTertiaryContainer;
          icon = Icons.timelapse;
          label = 'Pending';
          break;
        case 'cancelled':
          backgroundColor = colorScheme.errorContainer;
          textColor = colorScheme.onErrorContainer;
          icon = Icons.cancel;
          label = 'Cancelled';
          break;
        default:
          backgroundColor = colorScheme.surfaceContainerHighest;
          textColor = colorScheme.onSurfaceVariant;
          icon = Icons.help_outline;
          label = status;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}