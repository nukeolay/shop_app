import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/empty.dart';
import '../widgets/custom_navigation_bar.dart';
import '../notifiers/orders.dart';
import '../notifiers/cart.dart' show Cart;
import '../widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;
  bool _isInit = true;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Cart>(context).fetchAndSetCart();
      // await Provider.of<Products>(context).fetchAndSetProducts();
      setState(() {
        _isLoading = false;
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Cart cart = Provider.of<Cart>(context);
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : cart.totalAmount == 0
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
                                FittedBox(
                                  alignment: Alignment.centerLeft,
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    padding: const EdgeInsets.all(2.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${cart.totalAmount.toStringAsFixed(2)} ₽',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryTextTheme
                                                .headline6!
                                                .color),
                                      ),
                                    ),
                                  ),
                                ),
                                OrderButton(cart),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...cart.cartItems.entries
                            .map(
                              (item) => CartItem(
                                  // id: item.value.id,
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
                widget.cart.cartItems.values.toList(),
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
