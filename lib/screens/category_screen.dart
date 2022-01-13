import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/languages.dart';
import '../models/category.dart';
import '../widgets/custom_navigation_bar.dart';
import '../notifiers/products.dart';
import '../widgets/products_grid.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isLoading = false;
  bool _isInit = true;
  late Category category;

  @override
  void didChangeDependencies() async {
    category = ModalRoute.of(context)!.settings.arguments
        as Category;

    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Products>(context).fetchAndSetProducts();
      setState(() {
        _isLoading = false;
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category.titles[Languages.en]),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ProductsGrid(categoryId: category.id),
        bottomNavigationBar: const CustomNavigationBar(currentIndex: 1),
      ),
    );
  }
}
