import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatefulWidget {
  static const String routeName = '/product-detail';

  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  var _opacity = 1.0;
  bool _removeItem = false;
  bool _addItem = false;

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    Product loadedProduct = Provider.of<Products>(context).findById(productId);

    final auth = Provider.of<Auth>(context, listen: false);
    final cart = Provider.of<Cart>(context);
    final scaffold = ScaffoldMessenger.of(context);

    final cartIsEmpty = !cart.isProductInCart(productId);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              backgroundColor: Colors.blueGrey,
              actions: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    width: 60.0,
                    alignment: Alignment.center,
                    child: Icon(
                      loadedProduct.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: loadedProduct.isFavorite
                          ? Colors.white
                          : Colors.white,
                    ),
                  ),
                  onTap: () async {
                    try {
                      setState(() {});
                      await loadedProduct.toggleFavorite(
                        // auth.token,
                        auth.userId,
                      );
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: loadedProduct.isFavorite
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
                ),
              ],
              expandedHeight: MediaQuery.of(context).size.height * 0.6,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.zero,
                background: Stack(
                  children: [
                    PageView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: loadedProduct.imageUrl.length,
                      itemBuilder: (context, index) => index == 0
                          ? Hero(
                              tag: productId,
                              child: Image.network(
                                loadedProduct.imageUrl[index],
                                fit: BoxFit.cover,
                              ),
                            )
                          : FadeInImage(
                              placeholder: const AssetImage(
                                  'assets/images/placeholder.jpg'),
                              image: NetworkImage(
                                loadedProduct.imageUrl[index],
                              ),
                              fit: BoxFit.cover,
                            ),
                    ),
                    Container(
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [
                            0.0,
                            1.0,
                          ],
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.black.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            loadedProduct.title,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                        ),
                        Text(
                          loadedProduct.category.toString(),
                          textAlign: TextAlign.start,
                          softWrap: true,
                        ),
                        Text(
                          loadedProduct.description,
                          textAlign: TextAlign.start,
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.blueGrey,
          height: 50,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _opacity,
            onEnd: () => setState(() {
              _opacity = 1.0;
              if (_removeItem) {
                cart.removeSingleItem(
                  productId,
                );
                _removeItem = false;
              }
              if (_addItem) {
                cart.addItem(
                  productId: productId,
                  price: loadedProduct.price,
                  salePrice: loadedProduct.salePrice,
                  title: loadedProduct.title,
                );
                _addItem = false;
              }
            }),
            child: cartIsEmpty
                ? GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (loadedProduct.isOnSale())
                          Text(
                            '${loadedProduct.price.toStringAsFixed(2)} ₽   ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 18,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          '${loadedProduct.actualPrice().toStringAsFixed(2)} ₽',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          width: 40,
                          height: double.infinity,
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _opacity = 0.0;
                        _addItem = true;
                      });
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Товар добавлен в корзину',
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      removeItemFromCartButton(context),
                      Text(
                        '${cart.productQuantity(productId)} x ${loadedProduct.actualPrice().toStringAsFixed(2)} ₽',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      addItemToCartButton(context),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget removeItemFromCartButton(BuildContext context) {
    return cartActionButton(
      context: context,
      icon: Icons.remove,
      action: () {
        setState(() {
          _opacity = 0.0;
          _removeItem = true;
        });
      },
      snackBarText: 'Товар удален из корзины',
    );
  }

  Widget addItemToCartButton(BuildContext context) {
    return cartActionButton(
      context: context,
      icon: Icons.add,
      action: () {
        setState(() {
          _opacity = 0.0;
          _addItem = true;
        });
      },
      snackBarText: 'Товар добавлен в корзину',
    );
  }
}

Widget cartActionButton({
  required BuildContext context,
  required Function action,
  required IconData icon,
  required String snackBarText,
}) {
  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    child: SizedBox(
      width: 60,
      height: 40,
      child: Icon(
        icon,
        size: 30,
        color: Colors.white,
      ),
    ),
    onTap: () {
      action();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            snackBarText,
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    },
  );
}
