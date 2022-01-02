import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Column(
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
                            product.imageUrl[0],
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
                          icon: Container(
                            padding: const EdgeInsets.all(4.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white.withOpacity(0.7),
                            ),
                            child: Icon(
                              product.isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: product.isFavorite
                                  ? Colors.blueGrey
                                  : Colors.blueGrey,
                            ),
                          ),
                          onPressed: () async {
                            try {
                              await product.toggleFavorite(
                                // auth.token,
                                auth.userId,
                              );
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 4.0,
                ),
                child: Text(
                  product.title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Consumer<Cart>(
                builder: (context, cart, _) => Padding(
                  padding: cart.productQuantity(product.id) > 0
                      ? const EdgeInsets.only(left: 0.0)
                      : const EdgeInsets.only(left: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (cart.productQuantity(product.id) > 0)
                        GestureDetector(
                          child: FittedBox(
                            child: Container(
                              padding: const EdgeInsets.all(2.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  width: 2.0,
                                  color: Colors.blueGrey.shade300,
                                ),
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 24,
                                color: Colors.blueGrey.shade300,
                              ),
                            ),
                          ),
                          onTap: () {
                            cart.removeSingleItem(product.id);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Товар удален из корзины',
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      cart.productQuantity(product.id) > 0
                          ? Column(
                              children: [
                                Text(
                                  '${cart.productQuantity(product.id)} шт.',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w100,
                                  ),
                                ),
                                Text(
                                  '${(product.price * cart.productQuantity(product.id)).toStringAsFixed(2)} ₽',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w100,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              '${product.price.toStringAsFixed(2)} ₽',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                      GestureDetector(
                        child: FittedBox(
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                width: 2.0,
                                color: Colors.blueGrey.shade300,
                              ),
                            ),
                            child: Icon(
                              cart.productQuantity(product.id) > 0
                                  ? Icons.add
                                  : Icons.shopping_bag_outlined,
                              size: 24,
                              color: Colors.blueGrey.shade300,
                            ),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
