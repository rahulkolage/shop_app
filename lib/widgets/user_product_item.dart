import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../providers/products_provider.dart';
import './../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserProductItem(this.id, this.title, this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);

    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
          backgroundImage: NetworkImage(
              imageUrl)), // Image.network won't work with backgroundImage
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
              icon: const Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              onPressed: () async {
                // we can pass callback function from user_producs_screen to this page constructor
                // or can add provider here directly

                try {
                  await Provider.of<ProductsProvider>(context, listen: false)
                      .deleteProduct(id);
                } catch (error) {
                  scaffold.showSnackBar(const SnackBar(
                      content: Text(
                    'Deleting failed!',
                    textAlign: TextAlign.center,
                  )));
                }
              },
              icon: const Icon(Icons.delete),
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
