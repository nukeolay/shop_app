import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/widgets/category_item.dart';
import '../models/category.dart';
import '../providers/categories.dart';
import '../widgets/empty.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoriesData = Provider.of<Categories>(context);
    final categories = categoriesData.categories;
    categories.removeWhere((category) => category.isCollection);
    final collections = categoriesData.categories;
    collections.removeWhere((category) => !category.isCollection);
    final List<dynamic> resultList = [];
    resultList
        .addAll(['Categories', ...categories, 'Collections', ...collections]);
    return categories.isEmpty
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
                ...resultList.map((item) => CategoryItem(item)).toList()
              ],
            ),
          );
  }
}
