import 'dart:async';
import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

  final fmt = NumberFormat("#,##0.00", "en_US");

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
                  stream: appController.getCoinBalanceStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      EtherAmount _balance = snapshot.data!;
                      return Text(
                        fmt.format(_balance.getValueInUnit(EtherUnit.ether)),
                        style: Theme.of(context).textTheme.headline2,
                      );
                    }
                    return CircularProgressIndicator();
                  }),
            ),
          ),

          // wallet address
          GestureDetector(
            child: Chip(
              label: Text(
                appController.getWalletShortFormat(wallet: '${appController.wallet}'),
              ),
            ),
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

          // get ETH fron Faucet contract
          ListTile(
            leading: Icon(Icons.currency_bitcoin_outlined),
            title: Text("Get ETH from Faucet"),
            onTap: () async {
              log("Faucet");
              await appController.readFaucetContract();
              await appController.callFaucetWithdraw();
            },
          ),

          // swap ETH with Clam Coin
          ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text("Swap CLAM Token"),
            onTap: () {
              log("Buy Clam Token");
            },
          ),

          // send coin
          ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text("Send ETH"),
            onTap: () async {
              log("Send Coin");
              final result =
                  await appController.sendCoin(to: '0x57ceAFF4353D196ebD5f72f88dc62C1E9A37aF8f', amount: '0.5');
              log('send coint = $result');
            },
          ),
          // send Clam Token
        ],
      ),
    );
  }
}
