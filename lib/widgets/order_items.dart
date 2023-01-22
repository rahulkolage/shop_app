import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './../providers/orders.dart' as ord;

class OrderItem extends StatelessWidget {
  final ord.OrderItem order;

  const OrderItem(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    // Expandable card
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(children: [
        ListTile(
            title: Text('\$${order.amount}'),
            subtitle:
                Text(DateFormat('dd MM yyy hh:mm').format(order.dateTime)),
            trailing: IconButton(
              icon: const Icon(Icons.expand_more),
              onPressed: () {},
            ))
      ]),
    );
  }
}
