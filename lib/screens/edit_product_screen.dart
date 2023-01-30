import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../providers/product.dart';
import './../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // final _priceFocusNode = FocusNode(); // without FocusNode it works
  // final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments;

      // execute only when product id is pass as argument i.e. edit case
      if (productId != null) {
        // loading product
        // listen: false set to get id one time, not setting listener
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId.toString());

        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          // 'imageUrl': _editedProduct.imageUrl, //  can't use if controller is used
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // _priceFocusNode.dispose();
    // _descriptionFocusNode.dispose();

    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jepg'))) {
        return;
      }

      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final form = _form.currentState!;
    final isValid = form.validate();
    if (!isValid) {
      return;
    }
    form.save();
    setState(() {
      _isLoading = true;
    });

    // listen:false , as we are not interested in changes to product, but want to
    //// dispatch action
    if (_editedProduct.id != null) {
      // editing
      await Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        // adding
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('An Error Occured!'),
                  content: const Text('Something went wrong.'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(); // close dialog box
                        },
                        child: const Text('Okay'))
                  ],
                ));
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  // void _saveForm() {
  //   final form = _form.currentState!;
  //   final isValid = form.validate();
  //   if (!isValid) {
  //     return;
  //   }
  //   form.save();
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   // listen:false , as we are not interested in changes to product, but want to
  //   //// dispatch action
  //   if (_editedProduct.id != null) {
  //     // editing
  //     Provider.of<ProductsProvider>(context, listen: false)
  //         .updateProduct(_editedProduct.id, _editedProduct);
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   } else {
  //     // adding
  //     Provider.of<ProductsProvider>(context, listen: false)
  //         .addProduct(_editedProduct)
  //         .catchError((error) {
  //       return showDialog<Null>(
  //           context: context,
  //           builder: (ctx) => AlertDialog(
  //                 title: const Text('An Error Occured!'),
  //                 content: const Text('Something went wrong.'),
  //                 actions: [
  //                   TextButton(
  //                       onPressed: () {
  //                         Navigator.of(ctx).pop(); // close dialog box
  //                       },
  //                       child: const Text('Okay'))
  //                 ],
  //               ));
  //     }).then((_) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       Navigator.of(context).pop();
  //     });
  //   }

  //   // Navigator.of(context).pop();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                // autovalidateMode: AutovalidateMode.always,
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'].toString(),
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      // onFieldSubmitted: (_) {
                      //   FocusScope.of(context).requestFocus(_priceFocusNode);
                      // },
                      onSaved: (newValue) {
                        _editedProduct = Product(
                          title: newValue!,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        // return null;  // this indicates there is not error
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'].toString(),
                      decoration: const InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      // focusNode: _priceFocusNode,
                      onSaved: (newValue) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(newValue!),
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        // return null;  // this indicates there is not error
                        if (value!.isEmpty) {
                          return 'Please enter a price.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number.';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than 0.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'].toString(),
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      // textInputAction: TextInputAction.next, // not needed with multipline input
                      keyboardType: TextInputType.multiline,
                      // focusNode: _descriptionFocusNode,
                      onSaved: (newValue) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          description: newValue!,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        // return null;  // this indicates there is not error
                        if (value!.isEmpty) {
                          return 'Please enter description.';
                        }
                        if (value.length < 10) {
                          return 'should be atleast 10 characters long.';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller:
                                _imageUrlController, // this is for getting value before form submission for preview
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              // _saveForm is wrapped inside anonymous function, onFieldSubmitted expects a function that
                              // takes String as value & _saveForm doesn't take string value , so it's wrong format
                              _saveForm();
                            },
                            onSaved: ((newValue) {
                              _editedProduct = Product(
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: newValue!,
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            }),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter an image URL.';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL.';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jepg')) {
                                return 'Please enter a valid image URL.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
