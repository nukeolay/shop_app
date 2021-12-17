import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_navigation_bar.dart';
import '../providers/products.dart';
import '../widgets/products_grid.dart';

class CatalogScreen extends StatefulWidget {
  static String routeName = '/products-overview';
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
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : const ProductsGrid(false),
        bottomNavigationBar: const CustomNavigationBar(),
      ),
    );
  }
}
