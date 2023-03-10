import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../screens/product_detail_screen.dart';
import './../providers/product.dart';
import './../providers/cart.dart';
import './../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // we will get data using Provider
  // final String id;
  // final String title;
  // final String imageUrl;

  // const ProductItem(this.id, this.title, this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);

    // added listen property as we are not interested in changes to cart
    // becasuse here we only want to tell cart that added new item to cart
    // and not interested in changes to cart
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            // <===== using Consumer, chap. 200
            builder: (ctx, product, _) => IconButton(
              //child IS REPLACED with "_" as currently it is not required
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () {
                product.toggleFavoriteStatus(authData.token!, authData.userId!);
              },
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(product.id!, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Added item to the cart!'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: (() {
                      cart.removeItem(product.id!);
                    }),
                  ),
                ),
              );
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                  arguments: product.id);
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => ProductDetailScreen(title),
              //   ),
              // );
            },
            child: Hero(
              tag: product.id!,
              child: FadeInImage(
                placeholder:
                    const AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            )
            // Image.network(
            //   product.imageUrl,
            //   fit: BoxFit.cover,
            // ),
            ),
      ),
    );

    // return ClipRRect(
    //   borderRadius: BorderRadius.circular(10),
    //   child: GridTile(
    //     footer: GridTileBar(
    //       backgroundColor: Colors.black87,
    //       leading: IconButton(
    //         icon: Icon(
    //           product.isFavorite ? Icons.favorite : Icons.favorite_border,
    //         ),
    //         onPressed: () {
    //           product.toggleFavoriteStatus();
    //         },
    //         color: Theme.of(context).colorScheme.secondary,
    //       ),
    //       title: Text(
    //         product.title,
    //         textAlign: TextAlign.center,
    //       ),
    //       trailing: IconButton(
    //         icon: const Icon(Icons.shopping_cart),
    //         onPressed: () {},
    //         color: Theme.of(context).colorScheme.secondary,
    //       ),
    //     ),
    //     child: GestureDetector(
    //       onTap: () {
    //         Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
    //             arguments: product.id);
    //         // Navigator.of(context).push(
    //         //   MaterialPageRoute(
    //         //     builder: (context) => ProductDetailScreen(title),
    //         //   ),
    //         // );
    //       },
    //       child: Image.network(
    //         product.imageUrl,
    //         fit: BoxFit.cover,
    //       ),
    //     ),
    //   ),
    // );
  }
}
