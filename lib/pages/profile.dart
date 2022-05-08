import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
        init: AppController(),
        builder: (appController) {
          return ListView(
            children: [
              // circular avatar
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircleAvatar(
                  radius: 64,
                ),
              ),

              // name
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${appController.displayName}',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ],
                  ),
                ),
              ),

              // statistic

              // wallet
              ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text("Wallet"),
                onTap: () {
                  // check user already has wallet if not just create one
                  appController.walletExist().then((walletExist) {
                    if (walletExist) {
                      // exist goto wallet page
                      Get.toNamed('/wallet');
                    } else {
                      // not exist create one
                      Get.toNamed('/create_wallet');
                    }
                  });
                },
              ),

              // clear local data
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text("Clear wallet data"),
                onTap: () => appController.walletClear(),
              ),

              // signout
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text("Sign Out"),
                onTap: () => FirebaseAuth.instance.signOut(),
              )
            ],
          );
        });
  }
}
