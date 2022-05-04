import 'dart:async';
import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:web3dart/web3dart.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  AppController appController = Get.find<AppController>();

  late Timer timer;
  EtherAmount _balance = EtherAmount.zero();

  @override
  void initState() {
    super.initState();

    // FIXME
    timer = Timer.periodic(const Duration(seconds: 2), (callback) {
      appController.getCoinBalance().then((value) {
        setState(() {
          _balance = value;
        });
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
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
              child: Text(
                '${(_balance.getInWei / BigInt.parse('1000000000000000000'))}',
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
          ),

          // wallet address
          GestureDetector(
            child: Chip(label: Text(appController.getWalletShortFormat(wallet: '${appController.wallet}'))),
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
          ListTile(
            leading: Icon(Icons.currency_bitcoin_outlined),
            title: Text("Faucet"),
            onTap: () {
              log("Faucet");
            },
          ),
          ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text("Buy Clam Token"),
            onTap: () {
              log("Buy Clam Token");
            },
          ),
          ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text("Send Coin"),
            onTap: () {
              log("Send Coin");
            },
          ),
        ],
      ),
    );
  }
}
