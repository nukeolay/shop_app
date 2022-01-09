import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/categories_grid.dart';
import '../providers/categories.dart';
import '../widgets/custom_navigation_bar.dart';

class CategoriesScreen extends StatefulWidget {
  static String routeName = '/categories-screen';
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
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
