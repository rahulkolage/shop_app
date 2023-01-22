import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../providers/cart.dart' show Cart;
import './../providers/orders.dart';
import './../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(children: [
        Card(
          margin: const EdgeInsets.all(15),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 20),
                ),
                Spacer(),
                // const SizedBox(  // not required as we used MainAxisAlignment.spaceBetween
                //   width: 10,
                // ),
                Chip(
                  label: Text(
                    '\$${cart.totalAmount}',
                    style: TextStyle(
                        color: Theme.of(context)
                            .primaryTextTheme
                            .headline6
                            ?.color),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                TextButton(
                  // style: TextButton.styleFrom(
                  //   textStyle: TextStyle(color: Theme.of(context).primaryColor)
                  // ),
                  onPressed: () {
                    Provider.of<Orders>(context, listen: false).addOrder(
                      cart.items.values.toList(),
                      cart.totalAmount,
                    );
                    cart.clear();
                  },
                  child: const Text('ORDER NOW'),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // ListView() widget directly inside column doesn't work, so wrap it with Expanded() widget.
        Expanded(
            child: ListView.builder(
          itemBuilder: (ctx, index) => CartItem(
            cart.items.values.toList()[index].id,
            cart.items.keys.toList()[index],
            cart.items.values.toList()[index].price,
            cart.items.values.toList()[index].quantity,
            cart.items.values.toList()[index].title,
          ),
          itemCount: cart.itemCount,
        ))
      ]),
    );
  }
}
