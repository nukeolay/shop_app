import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/features/catalog/widgets/catalog_title.dart';
import 'package:shop_app/features/catalog/widgets/category_item.dart';
import '../../../notifiers/categories.dart';
import '../../../core/presentation/widgets/empty.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _categoriesProvider = Provider.of<Categories>(context);
    final _categories = _categoriesProvider
        .categories; // TODO сделать метод возвращающий categoryWithProducts
    final _collections = _categoriesProvider
        .collections; // TODO сделать метод возвращающий collectionsWithProducts

    return _categories.isEmpty
        ? const EmptyWidget(
            emptyIcon: Icons.menu_book,
            emptyText: "Продукты пока не разделены по категориям")
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(10.0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                const CatalogTitle('Категории'),
                ..._categories.map((item) => CategoryItem(item)).toList(),
                const CatalogTitle('Коллекции'),
                ..._collections.map((item) => CategoryItem(item)).toList(),
              ],
            ),
          );
  }
}
