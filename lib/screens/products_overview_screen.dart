import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../widgets/products_grid.dart';
import './../widgets/badge.dart';
import './../widgets/app_drawer.dart';
import './../providers/cart.dart';
import './cart_screen.dart';
import './../providers/products_provider.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showFavoritesOnly = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // Provider.of(context).fetchAndSetProducts();
    // this will not work in initState as widget is not completely wired up

    // it will work if we set listen: false
    // Two work arounds are
    // 1. use Future.delayed(Duration.zero).then(() {Provider.of(context).fetchAndSetProducts();})
    // 2. Use didChangeDependencies life cycle method, which run after widget fully initialized but before
    //    build ran for first time. But didChangeDependencies() will run multiple times

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
        // here we used .then approach instead of async await
        Provider.of<ProductsProvider>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // // instead use Stateful widget
    // final productData = Provider.of<ProductsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showFavoritesOnly = true;
                } else {
                  // show all items
                  _showFavoritesOnly = false;
                }
              });
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
          // we are using Consumer approach as we don't want to fire build of whole widget
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch!, // passing IconButton to builder child
              value: cart.itemCount
                  .toString(), // count of products using Consumer approach
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(_showFavoritesOnly),
    );
  }
}
