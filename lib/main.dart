import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/categories.dart';
import '../providers/cart.dart';
import '../providers/products.dart';
import '../providers/auth.dart';
import '../providers/orders.dart';
import 'screens/catalog_screen.dart';
import '../screens/home_screen.dart';
import '../helpers/custom_route.dart';
import '../screens/edit_product_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/manage_products_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/product_detail_screen.dart';
import 'screens/category_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/account_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.blueGrey),
    );
    return MultiProvider(
      providers: [
        // TODO вынести в отдельный файл как у индуса
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
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Voda Jewel',
          theme: ThemeData(
            fontFamily: 'Montserrat',
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            }),
            primarySwatch: Colors.blueGrey,
            appBarTheme: const AppBarTheme(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Color(0xFF455A50),
            ),
            colorScheme: ThemeData.light()
                .colorScheme
                .copyWith(secondary: Colors.deepOrange),
            progressIndicatorTheme:
                const ProgressIndicatorThemeData(color: Colors.blueGrey),
          ),
          home: auth.isLogged
              ? const HomeScreen()
              : FutureBuilder(
                  future: auth.tryAutologin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          routes: {
            CategoryScreen.routeName: (ctx) => const CategoryScreen(),
            WishlistScreen.routeName: (ctx) => const WishlistScreen(),
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            ManageProductsScreen.routeName: (ctx) =>
                const ManageProductsScreen(),
            EditProductScreen.routeName: (ctx) => const EditProductScreen(),
            AccountScreen.routeName: (ctx) => const AccountScreen(),
            HomeScreen.routeName: (ctx) => const HomeScreen(),
            AuthScreen.routeName: (ctx) => const AuthScreen(),
            CatalogScreen.routeName: (ctx) => const CatalogScreen(),
          },
        ),
      ),
    );
  }
}
