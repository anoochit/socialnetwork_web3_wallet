import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/utils.dart';

class CreateWalletPage extends StatefulWidget {
  const CreateWalletPage({Key? key}) : super(key: key);

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  AppController appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Wallet"),
      ),
      body: GetBuilder<AppController>(
          init: AppController(),
          builder: (appController) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Instruction
                  (appController.seed.isEmpty)
                      ? Text("You can create new wallet")
                      : Text("Please backup your seed words in the safe place."),

                  // menonic code
                  (appController.seed.isNotEmpty)
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(),
                            ),
                            child: Text('${appController.seed}'),
                          ),
                        )
                      : Container(),

                  (appController.seed.isNotEmpty)
                      ? ElevatedButton(
                          onPressed: () {
                            FlutterClipboard.copy('${appController.seed}').then((value) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(content: Text("Copyed seed words to clipboard")));
                            });
                            Get.back();
                          },
                          child: Text("Copy to clip board"))
                      : Container(),

                  // Create wallet
                  (appController.seed.isEmpty)
                      ? ElevatedButton(
                          onPressed: () {
                            appController.walletExist().then((exist) {
                              // if wallet exist
                              if (exist) {
                                // load wallet data

                              } else {
                                // create new wallet
                                appController.createWallet();
                              }
                            });
                          },
                          child: Text("Create Wallet"),
                        )
                      : Container(),

                  // Import private key
                  (appController.seed.isEmpty)
                      ? ElevatedButton(
                          onPressed: () {
                            // show dialog with text input
                          },
                          child: Text("Import Wallet"),
                        )
                      : Container()
                ],
              ),
            );
          }),
    );
  }
}
