import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '/notifiers/product.dart';
import '/models/category.dart';

class CategoryBottomSheet extends StatefulWidget {
  final Product _editedProduct;

  const CategoryBottomSheet(this._editedProduct, {Key? key}) : super(key: key);

  @override
  State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
  var _categoryBottomSheetItems;
  var _selectedCategories;
  var _selectCategoriesButtonColor;
  var _editedProduct;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
      ),
      child: MultiSelectBottomSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.8,
        title: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Укажите категории и коллекции'),
        ),
        listType: MultiSelectListType.CHIP,
        selectedColor: Colors.black,
        selectedItemsTextStyle: const TextStyle(color: Colors.white),
        cancelText: const Text('Отмена'),
        confirmText: const Text('OK'),
        items: _categoryBottomSheetItems,
        initialValue: _selectedCategories,
        onConfirm: (values) {
          setState(() {
            _selectedCategories = values as List<Category>;

            if (_selectedCategories.isEmpty) {
              _selectCategoriesButtonColor = Theme.of(context).errorColor;
            } else {
              _selectCategoriesButtonColor = Colors.grey.shade100;
              _editedProduct.categoryIds.clear();
              _editedProduct.categoryIds.addAll(
                  _selectedCategories.map((category) => category.id).toList());
            }
          });
        },
      ),
    );
  }
}
