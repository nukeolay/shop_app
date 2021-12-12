import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatefulWidget {
  static const String routeName = '/detail-screen';

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

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              actions: [
                IconButton(
                  splashRadius: 1,
                  icon: Icon(
                    loadedProduct.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: loadedProduct.isFavorite
                        ? Colors.blueGrey
                        : Colors.grey,
                  ),
                  onPressed: () async {
                    try {
                      setState(() {});
                      await loadedProduct.toggleFavorite(
                        auth.token,
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
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.all(0.0),
                title: Container(
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      loadedProduct.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blueGrey[800]),
                    ),
                  ),
                ),
                background: Hero(
                  tag: productId,
                  child: Image.network(
                    loadedProduct.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      loadedProduct.description,
                      textAlign: TextAlign.start,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 50.0,
            color: Colors.blueGrey,
          ),
          AnimatedOpacity(
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
                  productId,
                  loadedProduct.price,
                  loadedProduct.title,
                );
                _addItem = false;
              }
            }),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                cart.productQuantity(productId) > 0
                    ? GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: const SizedBox(
                          width: 60,
                          height: 40,
                          child: Icon(
                            Icons.remove,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _opacity = 0.0;
                            _removeItem = true;
                          });
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
                      )
                    : const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                        ),
                      ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    children: [
                      Text(
                        cart.productQuantity(productId) > 0
                            ? '${cart.productQuantity(productId)} x ${loadedProduct.price} ₽'
                            : '${loadedProduct.price} ₽',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      if (cart.productQuantity(productId) > 0)
                        const SizedBox(
                          width: 60,
                          height: 40,
                          child: Icon(
                            Icons.add,
                            size: 30,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
