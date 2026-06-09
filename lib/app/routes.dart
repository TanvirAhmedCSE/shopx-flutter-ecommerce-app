import 'package:get/get.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/signup_view.dart';
import '../modules/auth/setup_profile_view.dart';
import '../modules/cart/cart_view.dart';
import '../modules/checkout/checkout_view.dart';
import '../modules/favorites/favorites_view.dart';
import '../modules/home/home_view.dart';
import '../modules/order_history/order_history_view.dart';
import '../modules/product/product_detail_view.dart';
import '../modules/search/search_view.dart';
import '../modules/splash/splash_view.dart';

class AppRoutes {
  static const splash = '/splash';
  static const home = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const setupProfile = '/setup-profile';
  static const productDetail = '/product';
  static const cart = '/cart';
  static const favorites = '/favorites';
  static const checkout = '/checkout';
  static const search = '/search';
  static const orderHistory = '/order-history';

  static final pages = [
    GetPage(name: splash, page: () => const SplashView()),
    GetPage(name: home, page: () => const HomeView()),
    GetPage(name: login, page: () => const LoginView()),
    GetPage(name: signup, page: () => const SignupView()),
    GetPage(
      name: setupProfile,
      page: () => const SetupProfileView(isEdit: false),
    ),
    GetPage(name: productDetail, page: () => const ProductDetailView()),
    GetPage(name: cart, page: () => const CartView()),
    GetPage(name: favorites, page: () => const FavoritesView()),
    GetPage(name: checkout, page: () => const CheckoutView()),
    GetPage(name: search, page: () => const SearchView()),
    GetPage(name: orderHistory, page: () => const OrderHistoryView()),
  ];
}
