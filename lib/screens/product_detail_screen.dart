import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import '../providers/product.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;

  static const routeName = '/product-detail';

  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //extract values from routing arguments
    final productId = ModalRoute.of(context)!.settings.arguments as String;

    // now fetch data using product ID from data source
    // This can done using State management

    // Provider listener
    final loadedProduct = Provider.of<ProductsProvider>(context, listen: false)
        .findById(productId);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id!,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 10),
                Text(
                  '\$${loadedProduct.price}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    loadedProduct.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                const SizedBox(
                  height: 800,
                ) // added for Sliver effect, remove it later
              ],
            ),
          ),
        ],
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(loadedProduct.title),
    //   ),
    //   body: SingleChildScrollView(
    //     child: Column(
    //       children: [
    //         Container(
    //           height: 300,
    //           width: double.infinity,
    //           child: Hero(
    //             tag: loadedProduct.id!,
    //             child: Image.network(
    //               loadedProduct.imageUrl,
    //               fit: BoxFit.cover,
    //             ),
    //           ),
    //         ),
    //         const SizedBox(height: 10),
    //         Text(
    //           '\$${loadedProduct.price}',
    //           style: const TextStyle(
    //             color: Colors.grey,
    //             fontSize: 20,
    //           ),
    //         ),
    //         const SizedBox(height: 10),
    //         Container(
    //           padding: const EdgeInsets.symmetric(horizontal: 10),
    //           width: double.infinity,
    //           child: Text(
    //             loadedProduct.description,
    //             textAlign: TextAlign.center,
    //             softWrap: true,
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }
}
