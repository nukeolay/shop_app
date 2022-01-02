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

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              actions: [
                GestureDetector(
                  // splashRadius: 1,
                  child: Container(
                    width: 60.0,
                    // height: 50.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16.0)),
                      color: Colors.white.withOpacity(0.5),
                    ),
                    child: Icon(
                      loadedProduct.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: loadedProduct.isFavorite
                          ? Colors.blueGrey
                          : Colors.blueGrey,
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
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.zero,
                title: Container(
                  width: double.infinity,
                  height: 60,
                  color: Colors.black.withOpacity(0.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 4.0,
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            loadedProduct.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                background: PageView.builder(
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
                          placeholder:
                              const AssetImage('assets/images/placeholder.jpg'),
                          image: NetworkImage(
                            loadedProduct.imageUrl[index],
                          ),
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
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.blueGrey,
          //margin: EdgeInsets.only(bottom: Platform.isIOS ? 8.0 : 8.0),
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
                if (cart.productQuantity(productId) > 0)
                  GestureDetector(
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
                  ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    children: [
                      if (cart.productQuantity(productId) == 0)
                        const SizedBox(
                          width: 40,
                          height: double.infinity,
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                          ),
                        ),
                      Text(
                        cart.productQuantity(productId) > 0
                            ? '${cart.productQuantity(productId)} x ${loadedProduct.price.toStringAsFixed(2)} ₽'
                            : '${loadedProduct.price.toStringAsFixed(2)} ₽',
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
        ),
      ),
    );
  }
}
