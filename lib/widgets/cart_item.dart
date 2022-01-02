import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/product_detail_screen.dart';
import '../providers/products.dart';
import '../providers/cart.dart';
import '../providers/product.dart';

class CartItem extends StatefulWidget {
  const CartItem({
    Key? key,
    // required this.id,
    required this.productId,
    required this.price,
    required this.quantity,
    required this.title,
  }) : super(key: key);
  // final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    Product product = Provider.of<Products>(context, listen: false)
        .findById(widget.productId);
    Cart cart = Provider.of<Cart>(context);

    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 6,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FadeInImage(
                  width: 60,
                  height: 80,
                  placeholder:
                      const AssetImage('assets/images/placeholder.jpg'),
                  image: NetworkImage(
                    product.imageUrl[0],
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('${widget.price.toStringAsFixed(2)} ₽'),
                    ),
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.grey.shade400,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: const SizedBox(
                                width: 40,
                                child: Icon(
                                  Icons.remove,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  cart.removeSingleItem(
                                    widget.productId,
                                  );
                                });
                              },
                            ),
                            Text(
                              '${cart.productQuantity(widget.productId)}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: const SizedBox(
                                width: 40,
                                child: Icon(
                                  Icons.add,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  cart.addItem(
                                    widget.productId,
                                    product.price,
                                    product.title,
                                  );
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(widget.quantity * widget.price).toStringAsFixed(2)} ₽',
                style: const TextStyle(color: Colors.blueGrey),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(
            ProductDetailScreen.routeName,
            arguments: product.id,
          );
        },
      ),
    );
  }
}



// class _CartItemState extends State<CartItem> {
//   @override
//   Widget build(BuildContext context) {
//     Product product = Provider.of<Products>(context, listen: false)
//         .findById(widget.productId);
//     Cart cart = Provider.of<Cart>(context);

//     return Card(
//       elevation: 0,
//       color: Colors.grey.shade100,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       margin: const EdgeInsets.symmetric(
//         horizontal: 15,
//         vertical: 6,
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8),
//         child:
//         ListTile(
//           leading: ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: FadeInImage(
//               width: 60,
//               placeholder: const AssetImage('assets/images/placeholder.jpg'),
//               image: NetworkImage(
//                 product.imageUrl[0],
//               ),
//               fit: BoxFit.fitWidth,
//             ),
//           ),
//           title: Text(widget.title),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Text('${widget.price.toStringAsFixed(2)} ₽'),
//               ),
//               FittedBox(
//                 alignment: Alignment.centerLeft,
//                 fit: BoxFit.scaleDown,
//                 child: Container(
//                   padding: const EdgeInsets.all(2.0),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20.0),
//                     color: Colors.grey.shade400,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       GestureDetector(
//                         behavior: HitTestBehavior.translucent,
//                         child: const SizedBox(
//                           width: 40,
//                           child: Icon(
//                             Icons.remove,
//                             size: 22,
//                             color: Colors.white,
//                           ),
//                         ),
//                         onTap: () {
//                           setState(() {
//                             cart.removeSingleItem(
//                               widget.productId,
//                             );
//                           });
//                         },
//                       ),
//                       Text(
//                         '${cart.productQuantity(widget.productId)}',
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                         ),
//                       ),
//                       GestureDetector(
//                         behavior: HitTestBehavior.translucent,
//                         child: const SizedBox(
//                           width: 40,
//                           child: Icon(
//                             Icons.add,
//                             size: 22,
//                             color: Colors.white,
//                           ),
//                         ),
//                         onTap: () {
//                           setState(() {
//                             cart.addItem(
//                               widget.productId,
//                               product.price,
//                               product.title,
//                             );
//                           });
//                         },
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           trailing: Text(
//             '${(widget.quantity * widget.price).toStringAsFixed(2)} ₽',
//             style: const TextStyle(color: Colors.blueGrey),
//           ),
//         ),
//       ),
//     );
//   }
// }