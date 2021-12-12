import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/badge.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    final scaffold = ScaffoldMessenger.of(context);

    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight - 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: GridTile(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        ProductDetailScreen.routeName,
                        arguments: product.id,
                      );
                    },
                    child: Hero(
                      tag: product.id,
                      child: FadeInImage(
                        placeholder:
                            const AssetImage('assets/images/placeholder.jpg'),
                        image: NetworkImage(
                          product.imageUrl,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  header: Container(
                    alignment: Alignment.centerLeft,
                    child: Consumer<Product>(
                      builder: (ctx, product, _) => IconButton(
                        splashRadius: 1,
                        icon: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product.isFavorite
                              ? Colors.blueGrey
                              : Colors.grey,
                        ),
                        onPressed: () async {
                          try {
                            await product.toggleFavorite(
                              auth.token,
                              auth.userId,
                            );
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: product.isFavorite
                                    ? const Text(
                                        'Товар добален в список желаний')
                                    : const Text(
                                        'Товар удален из списка желаний'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          } catch (error) {
                            scaffold.showSnackBar(
                              SnackBar(
                                content: Text(error.toString()),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
              child: Text(
                product.title,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            Consumer<Cart>(
              builder: (context, cart, _) => GestureDetector(
                child: Chip(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      cart.productQuantity(product.id) > 0
                          ? Badge(
                              value:
                                  cart.productQuantity(product.id).toString(),
                                  color: Colors.transparent,
                                  top: 9,
                                  right: 5,
                              child: const Icon(
                                Icons.shopping_bag,
                                color: Colors.blueGrey,
                                size: 26,
                              ),
                            )
                          : const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.blueGrey,
                              size: 26,
                            ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0.0),
                        child: Text(
                          '${product.price.floor()} ₽',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  cart.addItem(
                    product.id,
                    product.price,
                    product.title,
                  );
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Товар добавлен в корзину',
                      ),
                      duration: const Duration(seconds: 1),
                      action: SnackBarAction(
                          textColor: Colors.white,
                          label: 'ОТМЕНА',
                          onPressed: () {
                            cart.removeSingleItem(product.id);
                          }),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
