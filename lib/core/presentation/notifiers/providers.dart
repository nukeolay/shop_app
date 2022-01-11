import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shop_app/notifiers/auth.dart';
import 'package:shop_app/notifiers/cart.dart';
import 'package:shop_app/notifiers/categories.dart';
import 'package:shop_app/notifiers/orders.dart';
import 'package:shop_app/notifiers/products.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(
    lazy: false,
    create: (ctx) => Auth(),
  ),
  ChangeNotifierProxyProvider<Auth, Products>(
    lazy: false,
    create: (ctx) => Products(false),
    update: (ctx, auth, _) => Products(auth.isLogged),
  ),
  ChangeNotifierProxyProvider<Auth, Orders>(
    lazy: false,
    create: (ctx) => Orders(null, null, []),
    update: (ctx, auth, previousOrders) => Orders(
      auth.token,
      auth.userId,
      previousOrders!.orders,
    ),
  ),
  ChangeNotifierProxyProvider<Auth, Categories>(
    lazy: false,
    create: (ctx) => Categories(false),
    update: (ctx, auth, _) => Categories(auth.isLogged),
  ),
  ChangeNotifierProxyProvider2<Auth, Products, Cart>(
    lazy: false,
    create: (ctx) => Cart(null, [], {}),
    update: (ctx, auth, products, previousCart) => Cart(
      auth.userId,
      products.products,
      previousCart!.cartItems,
    ),
  ),
];
