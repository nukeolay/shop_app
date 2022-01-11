import 'package:flutter/material.dart';
import 'package:shop_app/features/account_menu/screens/account_menu_screen.dart';
import 'package:shop_app/features/account_menu/screens/edit_category_screen.dart';
import 'package:shop_app/features/account_menu/screens/edit_product_screen.dart';
import 'package:shop_app/features/account_menu/screens/manage_categories_screen.dart';
import 'package:shop_app/features/account_menu/screens/manage_products_screen.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/catalog_screen.dart';
import 'package:shop_app/screens/category_screen.dart';
import 'package:shop_app/screens/home_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/wishlist_screen.dart';

class Routes {
  static const String auth = '/auth-screen';
  static const String home = '/home-screen';
  static const String catalog = '/catalog-screen';
  static const String category = '/category-screen';
  static const String productDetail = '/product-detail-screen';
  static const String cart = '/cart-screen';
  static const String wishlist = '/wishlist-screen';
  static const String accountMenu = '/account-menu-screen';
  static const String manageProducts = '/manage-products-screen';
  static const String manageCategories = '/manage-categories-screen';
  static const String editProduct = '/edit-product-screen';
  static const String editCategory = '/edit-category-screen';
  static const String orders = '/orders-screen';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        switch (settings.name) {
          case auth:
            return const AuthScreen();
          case home:
            return const HomeScreen();
          case catalog:
            return const CatalogScreen();
          case category:
            return const CategoryScreen();
          case productDetail:
            return const ProductDetailScreen();
          case cart:
            return const CartScreen();
          case wishlist:
            return const WishlistScreen();
          case accountMenu:
            return const AccountMenuScreen();
          case manageProducts:
            return const ManageProductsScreen();
          case manageCategories:
            return const ManageCategoriesScreen();
          case editProduct:
            return const EditProductScreen();
          case editCategory:
            return const EditCategoryScreen();
          case orders:
            return const OrdersScreen();
          default:
            return const AuthScreen();
        }
      },
    );
  }
}
