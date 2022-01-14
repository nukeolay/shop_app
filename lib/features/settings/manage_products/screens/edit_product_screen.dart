import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

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
  late List<Category> _selectedCategories;
  late List<MultiSelectItem<Category>> _categoryBottomSheetItems;
  Color _selectImageUrlsButtonColor = Colors.blueGrey.shade100;
  Color _selectCategoriesButtonColor = Colors.blueGrey.shade100;

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
    _selectedCategories = [];
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
        _selectedCategories = Provider.of<Categories>(context, listen: false)
            .getCategoriesByIds(_editedProduct.categoryIds);
        _isInit = false;
      }
      _categoryBottomSheetItems = _categories
          .map((category) =>
              MultiSelectItem<Category>(category, category.category))
          .toList();
    }
    if (_selectedCategories.isEmpty) {
      _selectCategoriesButtonColor = Theme.of(context).errorColor;
    }
    if (_editedProduct.imageUrls.isEmpty) {
      _selectImageUrlsButtonColor = Theme.of(context).errorColor;
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

  Future<void> _saveForm() async {
    final bool _isValid = _form.currentState!.validate();
    if (_isValid &&
        _editedProduct.imageUrls.isNotEmpty &&
        _selectedCategories.isNotEmpty) {
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

  void _addImageUrls(List<String> imageUrls) {
    setState(() {
      _editedProduct.imageUrls.clear();
      _editedProduct.imageUrls.addAll(imageUrls);
      if (_editedProduct.imageUrls.isEmpty) {
        _selectImageUrlsButtonColor = Theme.of(context).errorColor;
      } else {
        _selectImageUrlsButtonColor = Colors.grey.shade100;
      }
    });
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
                            builder: (ctx) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16.0),
                                    topRight: Radius.circular(16.0),
                                  ),
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor
                                      .withOpacity(0.9),
                                ),
                                child: MultiSelectBottomSheet(
                                  initialChildSize: 0.7,
                                  maxChildSize: 0.8,
                                  title: const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child:
                                        Text('Укажите категории и коллекции'),
                                  ),
                                  listType: MultiSelectListType.CHIP,
                                  selectedColor: Colors.black,
                                  selectedItemsTextStyle:
                                      const TextStyle(color: Colors.white),
                                  cancelText: const Text('Отмена'),
                                  confirmText: const Text('OK'),
                                  items: _categoryBottomSheetItems,
                                  initialValue: _selectedCategories,
                                  onConfirm: (values) {
                                    setState(() {
                                      _selectedCategories =
                                          values as List<Category>;

                                      if (_selectedCategories.isEmpty) {
                                        _selectCategoriesButtonColor =
                                            Theme.of(context).errorColor;
                                      } else {
                                        _selectCategoriesButtonColor =
                                            Colors.grey.shade100;
                                        _editedProduct.categoryIds.clear();
                                        _editedProduct.categoryIds.addAll(
                                            _selectedCategories
                                                .map((category) => category.id)
                                                .toList());
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: MenuButton(
                        buttonIcon: Icons.add_photo_alternate_rounded,
                        buttonText: 'Управление изображениями продукта',
                        color: _selectImageUrlsButtonColor,
                        buttonAction: () => Navigator.of(context).pushNamed(
                          Routes.addImageToProduct,
                          arguments: [_editedProduct.imageUrls, _addImageUrls],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
