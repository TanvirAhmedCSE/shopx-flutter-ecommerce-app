import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/bindings.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'data/models/cart_item_model.dart';
import 'data/models/order_model.dart';
import 'data/models/product_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(CartItemAdapter());
  Hive.registerAdapter(OrderItemAdapter());
  Hive.registerAdapter(OrderModelAdapter());

  await Hive.openBox('profile');

  runApp(const ShopXApp());
}

class ShopXApp extends StatelessWidget {
  const ShopXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ShopX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
      initialBinding: AppBindings(),
      defaultTransition: Transition.cupertino,
    );
  }
}
