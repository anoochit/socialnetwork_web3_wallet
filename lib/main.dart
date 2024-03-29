import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/controllers/faucet_controller.dart';
import 'package:snwallet/controllers/gifttoken_controller.dart';
import 'package:snwallet/controllers/post_controller.dart';
import 'package:snwallet/controllers/swap_controller.dart';
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

// mnemonic
// emulator 1 = scale habit artwork bag mail electric demand section evoke cost promote wonder
// wallet = 0xc5b10168cc35b8bc4042c4b529bfbb2052772d14

// emulator 2 = thunder enjoy cruise bomb west swim neglect connect check defy cereal sick
// wallet = 0x76cfc02cfe0f5a9e10b827227b3b1cf550061ad9

// GIFT Token Contract = 0xE557638C01f783b9124A5F354bC256229f1ea431
// Swap Contract = 0x824724e43F3268a5E4f6c529e724Bc1Ad535044A

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final AppController appController = Get.put(AppController());
  final WalletController walletController = Get.put(WalletController());
  final PostController postController = Get.put(PostController());
  final FaucetContractController faucetContractController = Get.put(FaucetContractController());
  final GiftTokenController giftTokenController = Get.put(GiftTokenController());
  final SwapTokenController swapTokenController = Get.put(SwapTokenController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ),
      ),
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
