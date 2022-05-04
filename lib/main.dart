import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/pages/create_wallet.dart';
import 'package:snwallet/pages/home.dart';
import 'package:snwallet/pages/signin.dart';
import 'package:snwallet/pages/wallet.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

// mnemonic = scale habit artwork bag mail electric demand section evoke cost promote wonder

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  AppController appController = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      home: SignInPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/signin': (context) => SignInPage(),
        '/create_wallet': (context) => CreateWalletPage(),
        '/wallet': (context) => WalletPage(),
      },
    );
  }
}
