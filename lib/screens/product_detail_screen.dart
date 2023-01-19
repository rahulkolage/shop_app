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
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
    );
  }
}
