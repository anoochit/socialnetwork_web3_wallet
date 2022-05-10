import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/controllers/wallet_controller.dart';
import 'package:snwallet/widgets/useravatar.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final WalletController walletController = Get.find<WalletController>();

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
              child: UserAvatar(),
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

            // wallet
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text("Wallet"),
              onTap: () {
                // check user already has wallet if not just create one
                walletController.walletExist().then((walletExist) {
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
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Clear wallet data"),
                      content: const Text("Are you sure you want to clear all wallet data?"),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                        TextButton(
                          child: const Text("Clear"),
                          onPressed: () {
                            walletController.walletClear();
                            Get.back();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            // signout
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Sign Out"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Sign Out"),
                      content: const Text("ADo you want to sign out?"),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                        TextButton(
                          child: const Text("Sign Out"),
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                            Get.back();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            )
          ],
        );
      },
    );
  }
}
