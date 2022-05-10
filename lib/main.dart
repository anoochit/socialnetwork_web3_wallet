import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/controllers/faucet_controller.dart';
import 'package:snwallet/controllers/post_controller.dart';
import 'package:snwallet/controllers/wallet_controller.dart';
import 'package:snwallet/pages/create_post.dart';
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

  final AppController appController = Get.put(AppController());
  final WalletController walletController = Get.put(WalletController());
  final PostController postController = Get.put(PostController());
  final FaucetContractController faucetContractController = Get.put(FaucetContractController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      home: SignInPage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/signin': (context) => SignInPage(),
        '/create_wallet': (context) => const CreateWalletPage(),
        '/wallet': (context) => const WalletPage(),
        '/create_post': (context) => CreatePostPage(),
      },
    );
  }
}
