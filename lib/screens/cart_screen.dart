import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../providers/cart.dart';

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
                    onPressed: () {},
                    child: const Text('ORDER NOW'),
                  )
                ],
              ),
            ))
      ]),
    );
  }
}
