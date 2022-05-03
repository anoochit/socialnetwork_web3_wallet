import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/pages/feed.dart';
import 'package:snwallet/pages/profile.dart';
import 'package:snwallet/utils.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // String? _walletAddress;
  // EtherAmount _walletBalance = EtherAmount.zero();

  int _currentIndex = 0;
  final List<String> _listTitle = ["Feed", "Chat", "Notification", "Profile"];

  AppController appController = Get.find<AppController>();

  @override
  void initState() {
    super.initState();
    // get wallet address and balance
    //updateWallet();
    // connect contract
    //readContract();
  }

  // update ui wallet
  // updateWallet() {
  //   getWalletAddress().then((address) {
  //     log('Wallet Address = ${address.hex}');
  //     getBalance().then((balance) {
  //       log('Balance = ${balance.getInEther}');
  //       setState(() {
  //         _walletAddress = address.hex;
  //         _walletBalance = balance;
  //         currentWallet = address;
  //       });
  //     });
  //   });
  // }

  // update ui balance
  // updateBalance() {
  //   getBalance().then((balance) {
  //     log('Balance = ${balance.getInEther}');
  //     setState(() {
  //       _walletBalance = balance;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_listTitle[_currentIndex]),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // feed
          FeedPage(),
          // chat
          Container(),
          // notification
          Container(),
          // profile
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_outlined),
              selectedIcon: Icon(Icons.chat),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Notification',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              selectedIcon: Icon(Icons.account_circle),
              label: 'Profile',
            ),
          ]),
    );
  }
}
