import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/presentation/routes/routes.dart';
import '/notifiers/product.dart';
import '../widgets/manage_product_item.dart';
import '../../../notifiers/products.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Управление товарами'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.editProduct);
            },
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _refreshProducts(context),
          builder: (ctx, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => _refreshProducts(context),
                      child: Consumer<Products>(
                        builder: (ctx, productData, _) {
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: productData.products.length,
                            itemBuilder: (_, index) {
                              Product product = productData.products[index];
                              return Column(
                                children: [
                                  ManageProductItem(
                                    id: product.id,
                                    title: product.title,
                                    imageUrl: product.imageUrls[0],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}
