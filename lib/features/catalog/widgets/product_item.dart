import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/core/presentation/routes/routes.dart';
import '../../../notifiers/auth.dart';
import '../../../notifiers/cart.dart';
import '../../../notifiers/product.dart';

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
              Routes.productDetail,
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


// class ProductDetailBottomSheet extends StatefulWidget {
//   final Product product;
//   const ProductDetailBottomSheet(this.product, {Key? key}) : super(key: key);

//   @override
//   State<ProductDetailBottomSheet> createState() =>
//       _ProductDetailBottomSheetState();
// }

// class _ProductDetailBottomSheetState extends State<ProductDetailBottomSheet> {
//   var _opacity = 1.0;
//   bool _removeItem = false;
//   bool _addItem = false;

//   @override
//   Widget build(BuildContext context) {
//     final productId = widget.product.id;
//     List<Category> categories = Provider.of<Categories>(context)
//         .getCategoriesByIds(widget.product.categoryIds);
//     final cart = Provider.of<Cart>(context);
//     final cartIsEmpty = !cart.isProductInCart(productId);
//     final size = MediaQuery.of(context).size;
//     return DraggableScrollableSheet(
//       initialChildSize: 0.7,
//       minChildSize: 0.5,
//       maxChildSize: 0.9,
//       builder: (_, controller) => Container(
//         padding: const EdgeInsets.all(0.0),
//         decoration: BoxDecoration(
//           color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
//           borderRadius: const BorderRadius.vertical(
//             top: Radius.circular(16.0),
//           ),
//         ),
//         child: ClipRRect(
//           borderRadius: const BorderRadius.vertical(
//             top: Radius.circular(16.0),
//           ),
//           child: Column(
//             children: [
//               Expanded(
//                 child: ListView(
//                   controller: controller,
//                   shrinkWrap: true,
//                   physics: const BouncingScrollPhysics(),
//                   children: [
//                     SizedBox(
//                       height: size.height * 0.5,
//                       child: PageView.builder(
//                         controller: PageController(viewportFraction: 0.9),
//                         physics: const BouncingScrollPhysics(),
//                         itemCount: widget.product.imageUrls.length,
//                         itemBuilder: (context, index) => Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 4.0,
//                             vertical: 10.0,
//                           ),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(
//                               16.0,
//                             ),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(10.0),
//                             child: FadeInImage(
//                               placeholder: const AssetImage(
//                                   'assets/images/placeholder.jpg'),
//                               image: NetworkImage(
//                                 widget.product.imageUrls[index],
//                               ),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8.0),
//                             child: Text(
//                               widget.product.title,
//                               textAlign: TextAlign.start,
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blueGrey.shade700,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             categories
//                                 .map(
//                                     (category) => category.titles[Languages.ru])
//                                 .toList()
//                                 .toString(),
//                             textAlign: TextAlign.start,
//                             softWrap: true,
//                           ),
//                           Text(
//                             widget.product.description,
//                             textAlign: TextAlign.start,
//                             softWrap: true,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 color: Colors.grey,
//                 height: 50,
//                 child: AnimatedOpacity(
//                   duration: const Duration(milliseconds: 300),
//                   opacity: _opacity,
//                   onEnd: () => setState(() {
//                     _opacity = 1.0;
//                     if (_removeItem) {
//                       cart.removeSingleItem(
//                         productId,
//                       );
//                       _removeItem = false;
//                     }
//                     if (_addItem) {
//                       cart.addItem(
//                         productId: productId,
//                         price: widget.product.price,
//                         salePrice: widget.product.salePrice,
//                         title: widget.product.title,
//                       );
//                       _addItem = false;
//                     }
//                   }),
//                   child: cartIsEmpty
//                       ? GestureDetector(
//                           behavior: HitTestBehavior.translucent,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               if (widget.product.isOnSale())
//                                 Text(
//                                   '${widget.product.price.toStringAsFixed(2)} ₽   ',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.5),
//                                     fontSize: 18,
//                                     decoration: TextDecoration.lineThrough,
//                                   ),
//                                 ),
//                               Text(
//                                 '${widget.product.actualPrice().toStringAsFixed(2)} ₽',
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                 ),
//                               ),
//                               const SizedBox(
//                                 width: 40,
//                                 height: double.infinity,
//                                 child: Icon(
//                                   Icons.shopping_bag_outlined,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           onTap: () {
//                             setState(() {
//                               _opacity = 0.0;
//                               _addItem = true;
//                             });
//                             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 behavior: SnackBarBehavior.floating,
//                                 content: Text(
//                                   'Товар добавлен в корзину',
//                                 ),
//                                 duration: Duration(seconds: 1),
//                               ),
//                             );
//                           },
//                         )
//                       : Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             removeItemFromCartButton(context),
//                             Text(
//                               '${cart.productQuantity(productId)} x ${widget.product.actualPrice().toStringAsFixed(2)} ₽',
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                               ),
//                             ),
//                             addItemToCartButton(context),
//                           ],
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget removeItemFromCartButton(BuildContext context) {
//     return cartActionButton(
//       context: context,
//       icon: Icons.remove,
//       action: () {
//         setState(() {
//           _opacity = 0.0;
//           _removeItem = true;
//         });
//       },
//       snackBarText: 'Товар удален из корзины',
//     );
//   }

//   Widget addItemToCartButton(BuildContext context) {
//     return cartActionButton(
//       context: context,
//       icon: Icons.add,
//       action: () {
//         setState(() {
//           _opacity = 0.0;
//           _addItem = true;
//         });
//       },
//       snackBarText: 'Товар добавлен в корзину',
//     );
//   }
// }

// Widget cartActionButton({
//   required BuildContext context,
//   required Function action,
//   required IconData icon,
//   required String snackBarText,
// }) {
//   return GestureDetector(
//     behavior: HitTestBehavior.translucent,
//     child: SizedBox(
//       width: 60,
//       height: 40,
//       child: Icon(
//         icon,
//         size: 30,
//         color: Colors.white,
//       ),
//     ),
//     onTap: () {
//       action();
//       ScaffoldMessenger.of(context).hideCurrentSnackBar();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.black.withOpacity(0.5),
//           content: Text(
//             snackBarText,
//           ),
//           duration: const Duration(seconds: 1),
//         ),
//       );
//     },
//   );
// }
