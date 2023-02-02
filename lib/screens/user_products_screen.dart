import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './edit_product_screen.dart';
import './../providers/products_provider.dart';
import './../widgets/app_drawer.dart';
import './../widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  const UserProductsScreen({super.key});

  Future<void> _refreshProducts(BuildContext ctx) async {
    await Provider.of<ProductsProvider>(ctx, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // moving this listener to specific section using Consumer approach to avoid infinite loop
    // as whenever product changes, we rebuild entire widget
    // because future builder & calling _refreshProducts, fetches products,
    // This updates products, retriggers build, retriggers future builder

    // final productsData = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, dataSnapshot) =>
            dataSnapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<ProductsProvider>(
                      builder:(ctx, productsData, _) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: ListView.builder(
                            itemBuilder: (_, index) => Column(
                              children: [
                                UserProductItem(
                                  productsData.items[index].id!,
                                  productsData.items[index].title,
                                  productsData.items[index].imageUrl,
                                ),
                                Divider(),
                              ],
                            ),
                            itemCount: productsData.items.length,
                          )),
                    ),
                  ),
      ),
    );
  }
}
