import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';

import './providers/auth.dart';
import './providers/products_provider.dart';
import './providers/cart.dart';
import './providers/orders.dart';

import './helpers/custom_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) {
              return Auth();
            },
          ),
          // first argument: i.e. Auth class, type of data that you depend on
          // second argument: i.e. ProductsProvider, type of data you provide here.
          ChangeNotifierProxyProvider<Auth, ProductsProvider>(
            // ctx: new context generated, we can use _ in place too.
            // value: is auth object of Auth provider which is passed to ChangeNotifierProxyProvider
            // previous: is previous state i.e. old products object
            update: (ctx, auth, previousProducts) => ProductsProvider(
                auth.token,
                auth.userId,
                previousProducts == null ? [] : previousProducts.items),
            create: (ctx) {
              // return instane of provider class
              return ProductsProvider(null, null, []);
            },
          ),
          ChangeNotifierProvider(
            create: (ctx) {
              return Cart();
            },
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (ctx, auth, previousOrders) => Orders(
                auth.token,
                auth.userId,
                previousOrders == null ? [] : previousOrders.orders),
            create: (ctx) {
              return Orders(null, null, []);
            },
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'MyShop',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              colorScheme: ColorScheme.fromSwatch(
                accentColor: Colors.deepOrange,
                primarySwatch: Colors.purple,
              ),
              fontFamily: 'Lato',
              textTheme: const TextTheme(
                button: TextStyle(color: Colors.white),
              ),
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CustomPageTransitionBuilder(),
                  TargetPlatform.iOS: CustomPageTransitionBuilder(),
                },
              ),
            ),
            // if not authenticated, instead of showing AuthScreen() directly,
            // try to call auto login. and in buidler based on connection state
            // we want check if ConnectionState.waiting then show some waiting indicator
            // for other case like success or fail, we can use authResultSnapshot.data == false
            // then return AuthScreen or return ProductsOverviewScreen,
            // but that is not needed as call to tryAutoLogin(), this will rebuild.
            // and auth.isAuth get success and will render ProductsOverviewScreen
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              CartScreen.routeName: (context) => CartScreen(),
              OrdersScreen.routeName: (context) => OrdersScreen(),
              UserProductsScreen.routeName: (context) => UserProductsScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen(),
            },
          ),
        ));

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
