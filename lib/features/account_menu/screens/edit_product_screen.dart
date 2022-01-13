import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/notifiers/products.dart';
import '/notifiers/product.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _salePriceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();

  final _form = GlobalKey<FormState>();

  late Product _editedProduct;

  bool _isInit = true;
  bool _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    _editedProduct = Product(
      id: '',
      title: '',
      price: 0,
      salePrice: 0,
      description: '',
      categoryIds: [],
      imageUrls: [],
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final String? productId =
          ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context, listen: false)
            .getProductById(productId);
        _imageUrlController.text = _editedProduct.imageUrls[0];
        _isInit = false;
      }
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _salePriceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    String value = _imageUrlController.text;
    if ((!value.startsWith('http') && !value.startsWith('https')) ||
        (!value.endsWith('.png') &&
            !value.endsWith('.jpg') &&
            !value.endsWith('.jpeg') &&
            !value.endsWith('.gif'))) {
      return;
    } else {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final bool _isValid = _form.currentState!.validate();
    if (_isValid) {
      _form.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      if (_editedProduct.id != '') {
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
      } else {
        try {
          await Provider.of<Products>(context, listen: false)
              .addProduct(_editedProduct);
        } catch (error) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Ошибка!'),
              content: Text('Что-то пошло не так: ${error.toString}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Ok'),
                ),
              ],
            ),
          );
        }
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование товара'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    TextFormField(
                      initialValue: _editedProduct.title,
                      decoration: const InputDecoration(labelText: 'Название'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Укажите значение';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: '$value',
                          price: _editedProduct.price,
                          salePrice: _editedProduct.salePrice,
                          description: _editedProduct.description,
                          imageUrls: _editedProduct.imageUrls,
                          categoryIds: _editedProduct.categoryIds,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _editedProduct.price.toString(),
                      decoration: const InputDecoration(labelText: 'Цена'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_salePriceFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Укажите цену';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Укажите корректное значение';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Укажите значение больше 0';
                        }
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          price: double.parse(value!),
                          salePrice: _editedProduct.salePrice,
                          description: _editedProduct.description,
                          imageUrls: _editedProduct.imageUrls,
                          categoryIds: _editedProduct.categoryIds,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _editedProduct.salePrice.toString(),
                      decoration:
                          const InputDecoration(labelText: 'Цена по скидке'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _salePriceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Укажите цену';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Укажите корректное значение';
                        }
                        if (double.parse(value) < 0) {
                          return 'Укажите положительное значение или 0';
                        }
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          salePrice: double.parse(value!),
                          description: _editedProduct.description,
                          imageUrls: _editedProduct.imageUrls,
                          categoryIds: _editedProduct.categoryIds,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _editedProduct.description,
                      decoration: const InputDecoration(labelText: 'Описание'),
                      maxLines: 10,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Укажите описание';
                        }
                        if (value.length < 10) {
                          return 'Не менее 10 символов';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          salePrice: _editedProduct.salePrice,
                          description: '$value',
                          imageUrls: _editedProduct.imageUrls,
                          categoryIds: _editedProduct.categoryIds,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          width: 100,
                          height: 100,
                          child: _imageUrlController.text.isEmpty
                              ? const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.red,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: FadeInImage(
                                    imageErrorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.red,
                                    ),
                                    placeholder: const AssetImage(
                                        'assets/images/placeholder.jpg'),
                                    image: NetworkImage(
                                      _imageUrlController.text,
                                    ),
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Ссылка на изображение'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onChanged: (_) {
                              setState(() {});
                            },
                            onFieldSubmitted: (_) => _saveForm(),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Введите ссылку';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Введите ссылку';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg') &&
                                  !value.endsWith('.gif')) {
                                return 'Введите ссылку на изображение';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct.imageUrls.add('$value');
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                salePrice: _editedProduct.salePrice,
                                description: _editedProduct.description,
                                imageUrls: _editedProduct.imageUrls,
                                categoryIds: _editedProduct.categoryIds,
                                isFavorite: _editedProduct.isFavorite,
                              );
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
