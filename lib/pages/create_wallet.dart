import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/wallet_controller.dart';

class CreateWalletPage extends StatefulWidget {
  const CreateWalletPage({Key? key}) : super(key: key);

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  WalletController walletController = Get.find<WalletController>();

  TextEditingController seedTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Wallet"),
      ),
      body: GetBuilder<WalletController>(
          init: WalletController(),
          builder: (walletController) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Instruction
                  (walletController.seed.isNotEmpty)
                      ? const Text("Please backup your seed words in safe place.")
                      : Container(),

                  // menonic code
                  (walletController.seed.isNotEmpty)
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(),
                            ),
                            child: Text('${walletController.seed}'),
                          ),
                        )
                      : Container(),

                  (walletController.seed.isNotEmpty)
                      ? ElevatedButton(
                          onPressed: () {
                            FlutterClipboard.copy('${walletController.seed}').then((value) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(content: Text("Copied seed words to clipboard")));
                            });
                            Get.back();
                          },
                          child: const Text("Copy to clip board"))
                      : Container(),

                  // Create wallet
                  (walletController.seed.isEmpty)
                      ? ElevatedButton(
                          onPressed: () {
                            walletController.walletExist().then((exist) async {
                              // if wallet exist
                              if (!exist) {
                                // create new wallet
                                await walletController.createWallet();
                              }
                            });
                          },
                          child: const Text("Create Wallet"),
                        )
                      : Container(),

                  // Import private key
                  (walletController.seed.isEmpty)
                      ? ElevatedButton(
                          onPressed: () {
                            // show dialog with text input
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Import Wallet"),
                                    content: TextFormField(
                                      controller: seedTextController,
                                      decoration: const InputDecoration(hintText: 'paste your seed words'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          // create wallet with seed words
                                          if (seedTextController.text.trim().isNotEmpty) {
                                            await walletController.createWallet(
                                                mnemonic: seedTextController.text.trim());
                                          }
                                          // go back
                                          Get.back(closeOverlays: true);
                                        },
                                        child: const Text("Import"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // go back
                                          Get.back(closeOverlays: true);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                    ],
                                  );
                                });
                          },
                          child: const Text("Import Wallet"),
                        )
                      : Container()
                ],
              ),
            );
          }),
    );
  }
}
