import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../providers/orders.dart' show Orders;
import './../widgets/order_items.dart';
import './../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  const OrdersScreen({super.key});

//   @override
//   State<OrdersScreen> createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends State<OrdersScreen> {
//   var _isLoading = false;

//   @override
//   void initState() {
    // _isLoading = true;
    // Provider.of<Orders>(context, listen: false).fetchAndSetOrders().then((_) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });

    // Future.delayed(Duration.zero).then(
    //   (_) async {
    //     setState(() {
    //       _isLoading = true;
    //     });
    //     await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   },
    // );
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    // if we listen above , this will run in infinite loop,
    // after fetchAndSetOrders() it will notify listeners
    // and liseteners setup at top, whole build will run again and that will
    // keep on going.
    // Use Consumer of data at ListView

    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                // error handling
                return const Center(
                  child: Text('Error occurred!'),
                );
              } else {
                return Consumer<Orders>(
                  builder: (ctx, orderData, child) => ListView.builder(
                    itemBuilder: (ctx, index) =>
                        OrderItem(orderData.orders[index]),
                    itemCount: orderData.orders.length,
                  ),
                );
              }
            }
          },
        )
        // _isLoading
        //     ? const Center(
        //         child: CircularProgressIndicator(),
        //       )
        //     : ListView.builder(
        //         itemBuilder: (ctx, index) {
        //           return OrderItem(orderData.orders[index]);
        //         },
        //         itemCount: orderData.orders.length,
        //       ),
        );
  }
}
