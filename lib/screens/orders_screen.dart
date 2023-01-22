import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../providers/orders.dart' show Orders;
import './../widgets/order_items.dart';
import './../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemBuilder: (ctx, index) {
          return OrderItem(orderData.orders[index]);
        },
        itemCount: orderData.orders.length,
      ),
    );
  }
}
