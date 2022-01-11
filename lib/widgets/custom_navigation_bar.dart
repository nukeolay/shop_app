import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/catalog_screen.dart';
import '../notifiers/cart.dart';
import '../features/account_menu/screens/account_menu_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/cart_screen.dart';
import './badge.dart';

class CustomNavigationBar extends StatefulWidget {
  final int currentIndex;
  const CustomNavigationBar({
    this.currentIndex = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  late int _currentIndex;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    _currentIndex = widget.currentIndex;
    if (_isInit) {
      _currentIndex =
          int.tryParse(ModalRoute.of(context)!.settings.arguments.toString()) ??
              _currentIndex;
      _isInit = false;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BottomNavigationBar(
          elevation: 0,
          iconSize: 26,
          enableFeedback: true,
          selectedItemColor: Colors.blueGrey,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: (i) {
            switch (i) {
              case 0:
                Navigator.of(context).pushReplacementNamed('/', arguments: i);
                break;
              case 1:
                Navigator.of(context).pushReplacementNamed(
                    CatalogScreen.routeName,
                    arguments: i);
                break;
              case 2:
                Navigator.of(context)
                    .pushReplacementNamed(CartScreen.routeName, arguments: i);
                break;
              case 3:
                Navigator.of(context).pushReplacementNamed(
                    WishlistScreen.routeName,
                    arguments: i);
                break;
              case 4:
                Navigator.of(context).pushReplacementNamed(
                    AccountMenuScreen.routeName,
                    arguments: i);
                break;
              default:
                Navigator.of(context).pushReplacementNamed('/', arguments: i);
            }
            setState(() {
              _currentIndex = i;
            });
          },
          items: [
            /// Home
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Главная",
            ),

            /// Catalog
            const BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: "Каталог",
            ),

            /// Basket
            BottomNavigationBarItem(
              icon: Consumer<Cart>(
                builder: (_, cart, ch) => cart.itemCount == 0
                    ? const Icon(Icons.shopping_bag_outlined)
                    : (Badge(
                        value: cart.itemCount.toString(),
                        child: ch,
                        bgColor: Colors.transparent,
                        top: 9.0,
                        right: 5.0,
                      )),
                child: const Icon(Icons.shopping_bag),
              ),
              label: "Корзина",
            ),

            /// Whishlist
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded),
              label: "Вишлист",
            ),

            /// Account
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Аккаунт",
            ),
          ]),
    );
  }
}
