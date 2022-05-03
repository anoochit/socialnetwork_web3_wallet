import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';

class CreateWalletPage extends StatefulWidget {
  const CreateWalletPage({Key? key}) : super(key: key);

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  AppController appController = Get.find<AppController>();

  String _menonic = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Wallet"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Instruction
            Text("You can create new wallet,"),

            // menonic code
            SelectableText(_menonic),

            // Create wallet
            ElevatedButton(
              onPressed: () {
                // create mnemonic and create wallet
              },
              child: Text("Create Wallet"),
            ),

            // Import private key
            ElevatedButton(
              onPressed: () {
                // show dialog with text input
              },
              child: Text("Import Wallet"),
            )
          ],
        ),
      ),
    );
  }
}
