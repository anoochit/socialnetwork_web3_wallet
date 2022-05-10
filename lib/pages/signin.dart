import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/controllers/wallet_controller.dart';
import 'package:snwallet/pages/home.dart';

class SignInPage extends StatelessWidget {
  SignInPage({Key? key}) : super(key: key);

  final AppController appController = Get.find<AppController>();

  final WalletController walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      initialData: FirebaseAuth.instance.currentUser,
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // user is not signin
        if (!snapshot.hasData) {
          log("user is not signin");
          // show signup page
          return SignInScreen(
            providerConfigs: const [
              EmailProviderConfiguration(),
            ],
            actions: [
              AuthStateChangeAction<SignedIn>(
                ((context, state) {
                  log('User id = ${state.user!.uid}');
                  // load user info
                  appController.getUser(uid: state.user!.uid);
                  // if wallet exist load wallet
                  walletController.getWalletData();
                }),
              ),
              AuthStateChangeAction<UserCreated>(
                ((context, state) {
                  log("User created in Firebase Auth ${state.credential.user!.uid} ");
                  // create user data in firestore
                  String _uid = state.credential.user!.uid;
                  String _displayName = state.credential.user!.email!.split('@')[0];
                  appController.createUser(
                    uid: _uid,
                    displayName: _displayName,
                  );
                }),
              ),
            ],
          );
        }

        // load user data when already login
        appController.getUser(uid: FirebaseAuth.instance.currentUser!.uid);
        // if wallet exist load wallet
        walletController.getWalletData();
        // user already signin goto home page
        return const HomePage();
      },
    );
  }
}
