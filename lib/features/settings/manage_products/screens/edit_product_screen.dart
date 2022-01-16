import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/features/settings/manage_products/widgets/select_category_bottom_sheet.dart';

import '/features/settings/core/widgets/menu_button.dart';
import '/models/category.dart';
import '/core/presentation/routes/routes.dart';
import '/notifiers/categories.dart';
import '/notifiers/products.dart';
import '/notifiers/product.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _form = GlobalKey<FormState>();

  final _priceFocusNode = FocusNode();
  final _salePriceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  late Product _editedProduct;
  late List<Category> _categories;
  late Color _selectImageUrlsButtonColor;
  late Color _selectCategoriesButtonColor;

  bool _isInit = true;
  bool _isLoading = false;

  @override
  void initState() {
    _editedProduct = Product(
      id: '',
      title: '',
      price: 0,
      salePrice: 0,
      description: '',
      categoryIds: [],
      imageUrls: [],
    );
    _categories = [];
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final String? productId =
          ModalRoute.of(context)!.settings.arguments as String?;
      _categories = Provider.of<Categories>(context, listen: false)
          .fullListExceptWildcard;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context, listen: false)
            .getProductById(productId);
        _isInit = false;
      }
      _validateButtonsColor();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _salePriceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _validateButtonsColor() {
    if (_editedProduct.imageUrls.isEmpty) {
      setState(() {
        _selectImageUrlsButtonColor = Theme.of(context).errorColor;
      });
    } else {
      setState(() {
        _selectImageUrlsButtonColor = Colors.grey.shade100;
      });
    }
    if (_editedProduct.categoryIds.isEmpty) {
      setState(() {
        _selectCategoriesButtonColor = Theme.of(context).errorColor;
      });
    } else {
      setState(() {
        _selectCategoriesButtonColor = Colors.grey.shade100;
      });
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _saveForm() async {
    final bool _isValid = _form.currentState!.validate();
    _validateButtonsColor();
    if (_isValid &&
        _editedProduct.imageUrls.isNotEmpty &&
        _editedProduct.categoryIds.isNotEmpty) {
      _form.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      if (_editedProduct.id != '') {
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editedProduct);
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
                  child: const Text('OK'),
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
            icon: const Icon(Icons.save, color: Colors.green),
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
                          return 'Укажите название';
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: MenuButton(
                        buttonIcon: Icons.category_rounded,
                        color: _selectCategoriesButtonColor,
                        buttonText: 'Выбор категорий и коллекций',
                        buttonAction: () async {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (ctx) => SelectCategoryBottomSheet(
                              categories: _categories,
                              editedProduct: _editedProduct,
                            ),
                          );
                          _validateButtonsColor();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: MenuButton(
                        buttonIcon: Icons.add_photo_alternate_rounded,
                        buttonText: 'Управление изображениями продукта',
                        color: _selectImageUrlsButtonColor,
                        buttonAction: () async {
                          // сделал async await чтобы после возвращения на эту страницу обновлялся цвет кнопки (выбраны изображения или нет)
                          await Navigator.of(context).pushNamed(
                            Routes.addImageToProduct,
                            arguments: [
                              _editedProduct,
                            ],
                          );
                          _validateButtonsColor();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
