import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/user_product_item.dart';
import '../providers/products.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({Key? key}) : super(key: key);
  static const String routeName = '/manage-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(builder: (ctx, productData, _) {
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: productData.products.length,
                            itemBuilder: (_, index) => Column(
                                  children: [
                                    UserProductItem(
                                      id: productData.products[index].id,
                                      title: productData.products[index].title,
                                      imageUrl:
                                          productData.products[index].imageUrl[0],
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
