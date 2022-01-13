import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/core/presentation/routes/routes.dart';
import '../notifiers/products.dart';
import '../notifiers/cart.dart';
import '../notifiers/product.dart';

class CartItem extends StatefulWidget {
  const CartItem({
    Key? key,
    // required this.id,
    required this.productId,
    required this.price, // TODO может удалить лишние параметры
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
        .getProductById(widget.productId);
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
                borderRadius: BorderRadius.circular(8.0),
                child: FadeInImage(
                  width: 60,
                  height: 80,
                  placeholder:
                      const AssetImage('assets/images/placeholder.jpg'),
                  image: NetworkImage(
                    product.imageUrls[0],
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
                      child: product.isOnSale()
                          ? Row(
                              children: [
                                Text(
                                  '${product.price.toStringAsFixed(2)} ₽',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '  ${product.actualPrice().toStringAsFixed(2)} ₽',
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            )
                          : Text('${product.price.toStringAsFixed(2)} ₽'),
                    ),
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
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
                                    productId: widget.productId,
                                    price: product.price,
                                    salePrice: product.salePrice,
                                    title: product.title,
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
              product.isOnSale()
                  ? Column(
                      children: [
                        Text(
                          '${(widget.quantity * product.actualPrice()).toStringAsFixed(2)} ₽',
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          '${(widget.quantity * product.price).toStringAsFixed(2)} ₽',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '${(widget.quantity * product.actualPrice()).toStringAsFixed(2)} ₽',
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(
            Routes.productDetail,
            arguments: product.id,
          );
        },
      ),
    );
  }
}
