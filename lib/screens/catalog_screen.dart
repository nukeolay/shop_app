import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/categories_grid.dart';
import '../notifiers/categories.dart';
import '../widgets/custom_navigation_bar.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool _isLoading = false;
  bool _isInit = true;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Categories>(context).fetchAndSetCategories();
      
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
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : const CategoriesGrid(),
        bottomNavigationBar: const CustomNavigationBar(),
      ),
    );
  }
}
