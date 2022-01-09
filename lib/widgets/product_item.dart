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
              ClipRRect(
                borderRadius: BorderRadius.circular(14.0),
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight - 20,
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.0),
                          child: FadeInImage(
                            placeholder: const AssetImage(
                                'assets/images/placeholder.jpg'),
                            image: NetworkImage(
                              product.imageUrls[0],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    header: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [
                            0.0,
                            1.0,
                          ],
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.0),
                          ],
                        ),
                      ),
                      child: Consumer<Product>(
                        builder: (ctx, product, _) => Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (product.isOnSale())
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'SALE!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            toggleFavoriteButton(
                              product,
                              auth,
                              context,
                              scaffold,
                            ),
                          ],
                        ),
                      ),
                    ),
                    footer: Container(
                      // padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [
                            0.0,
                            1.0,
                          ],
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.0),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: Text(
                              product.title,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Consumer<Cart>(
                            builder: (context, cart, _) {
                              bool isInCart = cart.isProductInCart(product.id);
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (isInCart)
                                    removeFromCartButton(
                                        cart, product, context),
                                  if (isInCart) priceWhenInCart(cart, product),
                                  if (!isInCart)
                                    product.isOnSale()
                                        ? salePrice(product)
                                        : regularPrice(product),
                                  addToCartButton(cart, product, context),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconButton toggleFavoriteButton(
    Product product,
    Auth auth,
    BuildContext context,
    ScaffoldMessengerState scaffold,
  ) {
    return IconButton(
      splashRadius: 1,
      icon: Icon(
        product.isFavorite
            ? Icons.favorite_rounded
            : Icons.favorite_border_rounded,
        color: Colors.white,
      ),
      onPressed: () async {
        try {
          await product.toggleFavorite(
            // auth.token,
            auth.userId,
          );
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: product.isFavorite
                  ? const Text('Товар добален в список желаний')
                  : const Text('Товар удален из списка желаний'),
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
    );
  }

  IconButton removeFromCartButton(
      Cart cart, Product product, BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.remove,
        size: 24,
        color: Colors.white,
      ),
      onPressed: () {
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
    );
  }

  Column priceWhenInCart(Cart cart, Product product) {
    return Column(
      children: [
        Text(
          '${cart.productQuantity(product.id)} шт.',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w100,
            color: Colors.white,
          ),
        ),
        Text(
          '${(product.actualPrice() * cart.productQuantity(product.id)).toStringAsFixed(2)} ₽',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w100,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Padding regularPrice(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '${product.actualPrice().toStringAsFixed(2)} ₽',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w100,
          color: Colors.white,
        ),
      ),
    );
  }

  Padding salePrice(Product product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            '${product.salePrice.toStringAsFixed(2)} ₽',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${product.price.toStringAsFixed(2)} ₽',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w100,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }

  IconButton addToCartButton(Cart cart, Product product, BuildContext context) {
    return IconButton(
      icon: Icon(
        cart.productQuantity(product.id) > 0
            ? Icons.add
            : Icons.shopping_bag_outlined,
        size: 24,
        color: Colors.white,
      ),
      onPressed: () {
        cart.addItem(
          productId: product.id,
          price: product.price,
          salePrice: product.salePrice,
          title: product.title,
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
    );
  }
}
