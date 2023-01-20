import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../screens/product_detail_screen.dart';
import './../providers/product.dart';
import './../providers/cart.dart';

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

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(       // <===== using Consumer, chap. 200
            builder: (ctx, product, _) => IconButton(   //child IS REPLACED with "_" as currently it is not required
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () {
                product.toggleFavoriteStatus();
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
              cart.addItem(product.id, product.price, product.title);
              
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
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
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
