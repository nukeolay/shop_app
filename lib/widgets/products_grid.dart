import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/categories.dart';
import '../widgets/empty.dart';
import '../providers/products.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyFavorites;
  final String? categoryId;
  const ProductsGrid({
    this.showOnlyFavorites = false,
    this.categoryId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context, listen: false);
    final List<Product> products = showOnlyFavorites
        ? productsData.favoriteItems
        : categoryId == null ||
                Provider.of<Categories>(context, listen: false)
                        .getCategoryById(categoryId!)
                        .category ==
                    '*'
            ? productsData.products
            : productsData.productsByCategory(categoryId!);

    return products.isEmpty
        ? EmptyWidget(
            emptyIcon:
                categoryId == null ? Icons.favorite_border : Icons.menu_book,
            emptyText: categoryId == null
                ? 'В избранном пока нет товаров'
                : 'В данной категории нет товаров',
          )
        : GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(10.0),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
              value: products[index],
              child: const ProductItem(),
            ),
          );
  }
}
