import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './product_item.dart';
import './../providers/products_provider.dart';
import '../providers/product.dart';

class ProductGrid extends StatelessWidget {
  // no need for commented code below
  // we will fetch data using product listener
  // const ProductGrid({
  //   Key? key,
  //   required this.loadedProducts,
  // }) : super(key: key);

  // final List<Product> loadedProducts;

  @override
  Widget build(BuildContext context) {
    // Adding listener, which type of data we want to listen to
    final productsData = Provider.of<ProductsProvider>(context);

    // fetch products from productsData object
    final products = productsData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: products[index],
        // create: (context) {
        //   return products[index];
        // },
        child: ProductItem(),
        // child: ProductItem(
        //   products[index].id,
        //   products[index].title,
        //   products[index].imageUrl,
        // ),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
