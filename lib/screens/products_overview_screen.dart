import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../widgets/products_grid.dart';
import './../providers/products_provider.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatelessWidget {
  // ProductsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              // print(selectedValue);
              if (selectedValue == FilterOptions.Favorites) {
                productData.showFavoritesOnly();
              } else {
                // show all items
                productData.showAll();
              }
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: FilterOptions.Favorites,
                  child: Text('Only Favorites')),
              const PopupMenuItem(
                  value: FilterOptions.All, child: Text('Show All')),
            ],
          ),
        ],
      ),
      body: ProductGrid(),
    );
  }
}
