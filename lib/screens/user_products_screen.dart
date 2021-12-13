import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import '../providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({Key? key}) : super(key: key);
  static const String routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    final Products productData = Provider.of<Products>(
      context,
      listen: false,
    );
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Управление товарами'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Consumer<Products>(builder: (ctx, productData, _) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: productData.items.length,
                        itemBuilder: (_, index) => Column(
                              children: [
                                UserProductItem(
                                  id: productData.items[index].id,
                                  title: productData.items[index].title,
                                  imageUrl: productData.items[index].imageUrl[0],
                                ),
                                const Divider()
                              ],
                            )),
                  );
                }),
              ),
      ),
    );
  }
}
