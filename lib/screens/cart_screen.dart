import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/empty.dart';
import '../widgets/custom_navigation_bar.dart';
import '../providers/orders.dart';
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);
  static const routeName = '/cart';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    Cart cart = Provider.of<Cart>(context);
    return Scaffold(
      body: SafeArea(
        child: cart.totalAmount == 0
            ? const EmptyWidget(
                emptyIcon: Icons.shopping_bag_outlined,
                emptyText: 'Корзина пуста',
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Card(
                      elevation: 0,
                      color: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: const EdgeInsets.all(15),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Сумма',
                              style: TextStyle(fontSize: 20),
                            ),
                            const Spacer(),
                            Chip(
                              label: Text(
                                '${cart.totalAmount.toStringAsFixed(1)} ₽',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .primaryTextTheme
                                        .headline6!
                                        .color),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            OrderButton(cart),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...cart.cartItems!.entries
                        .map(
                          (item) => CartItem(
                              id: item.value.id,
                              productId: item.key,
                              title: item.value.title,
                              quantity: item.value.quantity,
                              price: item.value.price),
                        )
                        .toList(),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;
  const OrderButton(this.cart, {Key? key}) : super(key: key);

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (_isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                widget.cart.cartItems!.values.toList(),
                widget.cart.totalAmount,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
            },
      child: _isLoading
          ? const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(),
            )
          : const Text('ОФОРМИТЬ ЗАКАЗ'),
    );
  }
}
