import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/utils.dart';
import 'package:web3dart/web3dart.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  AppController appController = Get.find<AppController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Wallet"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          // balance
          const Center(child: Text("Balance (ETH)")),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: StreamBuilder<EtherAmount>(
                  initialData: EtherAmount.zero(),
                  stream: appController.getCoinBalance(),
                  builder: (context, snapshot) {
                    return Text(
                      '${snapshot.data!.getValueInUnit(EtherUnit.ether)}',
                      style: Theme.of(context).textTheme.headline3,
                    );
                  }),
            ),
          ),

          // wallet address
          GestureDetector(
            child: Chip(label: Text('${appController.wallet}')),
            onTap: () {
              // copy wallet address
              FlutterClipboard.copy('${appController.wallet}').then((value) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Wallet address copied!"),
                  duration: Duration(seconds: 2),
                ));
              });
            },
          ),

          // action button
        ],
      ),
    );
  }
}
