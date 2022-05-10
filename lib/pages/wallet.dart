import 'dart:developer';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/controllers/faucet_controller.dart';
import 'package:snwallet/controllers/wallet_controller.dart';
import 'package:web3dart/web3dart.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  AppController appController = Get.find<AppController>();
  WalletController walletController = Get.find<WalletController>();
  FaucetContractController faucetContractController = Get.find<FaucetContractController>();

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
                  stream: walletController.getCoinBalanceStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      EtherAmount _balance = snapshot.data!;
                      return Text(
                        fmt.format(_balance.getValueInUnit(EtherUnit.ether)),
                        style: Theme.of(context).textTheme.headline2,
                      );
                    }
                    return const CircularProgressIndicator();
                  }),
            ),
          ),

          // wallet address
          GestureDetector(
            child: Chip(
              label: Text(
                walletController.getWalletShortFormat(wallet: '${walletController.wallet}'),
              ),
            ),
            onTap: () {
              // copy wallet address
              FlutterClipboard.copy('${walletController.wallet}').then((value) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Wallet address copied!"),
                  duration: Duration(seconds: 2),
                ));
              });
            },
          ),

          // get ETH fron Faucet contract
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text("Get ETH from Faucet"),
            onTap: () async {
              log("Faucet");
              await faucetContractController.readFaucetContract();
              await faucetContractController.callFaucetWithdraw(credentials: walletController.credentials);
            },
          ),

          // send coin
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text("Send ETH"),
            onTap: () async {
              log("Send Coin");
              final result = await walletController.sendCoin(
                to: '0x57ceAFF4353D196ebD5f72f88dc62C1E9A37aF8f',
                amount: '0.5',
              );
              log('result = $result');
            },
          ),

          // swap ETH with Clam Coin
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text("Swap GIFT Token"),
            onTap: () {
              log("Swap GIFT Token, call swap contract to swap ETH and GIFT token");
            },
          ),

          // send GIFT Token
          ListTile(
            leading: const Icon(Icons.redeem),
            title: const Text("Send GIFT"),
            onTap: () async {
              log("Send GIFT");
            },
          ),
        ],
      ),
    );
  }
}
