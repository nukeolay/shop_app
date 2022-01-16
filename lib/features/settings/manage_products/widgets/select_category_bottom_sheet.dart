import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '/notifiers/product.dart';
import '/models/category.dart';

class SelectCategoryBottomSheet extends StatefulWidget {
  final Product editedProduct;
  final List<Category> categories;

  const SelectCategoryBottomSheet({
    required this.editedProduct,
    required this.categories,
    Key? key,
  }) : super(key: key);

  @override
  State<SelectCategoryBottomSheet> createState() =>
      _SelectCategoryBottomSheetState();
}

class _SelectCategoryBottomSheetState extends State<SelectCategoryBottomSheet> {
  late List<MultiSelectItem<Category>> _categoryBottomSheetItems;
  late List<Category> _selectedCategories;
  late bool isValid;

  @override
  void initState() {
    _categoryBottomSheetItems = widget.categories
        .map((category) =>
            MultiSelectItem<Category>(category, category.category))
        .toList();
    _selectedCategories = widget.editedProduct.categoryIds.isEmpty
        ? []
        : widget.editedProduct.categoryIds.map((categoryId) {
            return widget.categories
                .firstWhere((element) => element.id == categoryId);
          }).toList();
    isValid = _selectedCategories.isNotEmpty ? true : false;
    super.initState();
  }

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
        confirmText: isValid
            ? const Text('OK')
            : Text(
                'Категории не выбраны',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).errorColor),
              ),
        items: _categoryBottomSheetItems,
        initialValue: _selectedCategories,
        onSelectionChanged: (selectedCategories) {
          if (selectedCategories.isEmpty) {
            setState(() {
              isValid = false;
            });
          } else {
            setState(() {
              isValid = true;
            });
          }
        },
        onConfirm: (values) {
          values.isEmpty
              ? null
              : setState(() {
                  _selectedCategories = values as List<Category>;
                  widget.editedProduct.categoryIds.clear();
                  widget.editedProduct.categoryIds.addAll(_selectedCategories
                      .map((category) => category.id)
                      .toList());
                });
        },
      ),
    );
  }
}
