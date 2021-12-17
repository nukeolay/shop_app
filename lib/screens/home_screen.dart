import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/products_grid.dart';
import '../providers/products.dart';
import '../widgets/custom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        appBar: AppBar(
          centerTitle: true,
          title: const Padding(
              padding: EdgeInsets.only(
                top: 15,
                left: 30,
                right: 30,
              ),
              child: Image(
                image: AssetImage('assets/images/logo_named.png'),
              )),
          automaticallyImplyLeading: false,
        ),
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
