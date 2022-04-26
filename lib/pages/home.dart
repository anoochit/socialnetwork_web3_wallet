import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:snwallet/const.dart';
import 'package:snwallet/pages/recieve.dart';
import 'package:snwallet/utils.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _walletAddress;
  EtherAmount _walletBalance = EtherAmount.zero();

  @override
  void initState() {
    super.initState();

    // get wallet address and balance
    updateWallet();

    // connect contract
    readContract();
  }

  // update ui wallet
  updateWallet() {
    getWalletAddress().then((address) {
      log('Wallet Address = ${address.hex}');
      getBalance().then((balance) {
        log('Balance = ${balance.getInEther}');
        setState(() {
          _walletAddress = address.hex;
          _walletBalance = balance;
          currentWallet = address;
        });
      });
    });
  }

  // update ui balance
  updateBalance() {
    getBalance().then((balance) {
      log('Balance = ${balance.getInEther}');
      setState(() {
        _walletBalance = balance;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // get wallet address
            Text('Wallet = ${_walletAddress}'),
            Text('Balance = ${_walletBalance.getInEther}'),

            // update balance
            ElevatedButton(
              onPressed: () {
                // update
                updateBalance();
              },
              child: const Text("Refresh"),
            ),

            // send coin
            ElevatedButton(
              onPressed: () {
                sendCoin(toAddress: wallet1, amount: 1);
              },
              child: const Text("Send 1 ETH"),
            ),

            // recieve token
            ElevatedButton(
              onPressed: () {
                // show qrcode
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RecievePage(walletAddress: _walletAddress),
                    fullscreenDialog: true,
                  ),
                );

                // update
                updateBalance();
              },
              child: const Text("Recieve"),
            ),

            ElevatedButton(
              onPressed: () {
                callWithdraw();
              },
              child: const Text("Faucet"),
            ),
          ],
        ),
      ),
    );
  }
}
