import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';

import './providers/products_provider.dart';
import './providers/cart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) {
            // return instane of provider class
            return ProductsProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (ctx) {
            return Cart();
          },
        )
      ],
      child: MaterialApp(
        title: 'MyShop',
        theme: ThemeData(
            primarySwatch: Colors.purple,
            colorScheme: ColorScheme.fromSwatch(
              accentColor: Colors.deepOrange,
              primarySwatch: Colors.purple,
            ),
            fontFamily: 'Lato'),
        home: ProductsOverviewScreen(),
        routes: {
          ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
          CartScreen.routeName: (context) => CartScreen(),
        },
      ),
    );

    // return ChangeNotifierProvider(
    //   create: (context) {
    //     // return instane of provider class
    //     return ProductsProvider();
    //   },
    //   child: MaterialApp(
    //     title: 'MyShop',
    //     theme: ThemeData(
    //         primarySwatch: Colors.purple,
    //         colorScheme: ColorScheme.fromSwatch(
    //           accentColor: Colors.deepOrange,
    //           primarySwatch: Colors.purple,
    //         ),
    //         fontFamily: 'Lato'),
    //     home: ProductsOverviewScreen(),
    //     routes: {
    //       ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
    //     },
    //   ),
    // );
  }
}
