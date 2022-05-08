import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:ethers/ethers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:snwallet/faucet.g.dart';
import 'package:snwallet/models/post.dart';

import 'package:bip39/bip39.dart' as bip39;
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class AppController extends GetxController {
  RxString uid = "".obs;
  RxString displayName = "".obs;

  RxString seed = "".obs;
  RxString wallet = "".obs;

  final FirebaseFirestore firebase = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  late EncryptedSharedPreferences encryptedSharedPreferences;

  // rpc server
  final String rpcUrl = "http://10.0.2.2:7545";
  final String wsUrl = 'ws://10.0.2.2:8545';
  final String blockExplorer = 'http://10.0.2.2:4000';

  // Create user data in FireStore
  createUser({required String uid, required String displayName}) {
    firebase.collection('users').doc(uid).set({
      'uid': uid,
      'displayName': displayName,
      'type': 'u',
      'wallet': '',
      'updated': DateTime.now(),
    }).then((value) {
      // set user data
      this.uid.value = uid;
      this.displayName.value = displayName;
      update();
    });
  }

  // Update user data in FireStore
  updateUser({required String displayName}) {
    firebase.collection('users').doc(auth.currentUser!.uid).update({
      'displayName': displayName,
      'updated': DateTime.now(),
    }).then((value) {
      // set user data
      uid.value = auth.currentUser!.uid;
      this.displayName.value = displayName;
      update();
    });
  }

  // update user wallet
  updateUserWallet({required String wallet}) {
    firebase.collection('users').doc(auth.currentUser!.uid).update({
      'wallet': wallet,
    });
  }

  // Get user data in FireStore
  getUser({required String uid}) {
    firebase.collection('users').doc(uid).get().then((user) {
      log('user docId =' + user.id);
      // set user data
      this.uid.value = user['uid'];
      displayName.value = user['displayName'];
      update();
    });
  }

  // Post stream
  CollectionReference<Post> getPostStream() {
    return firebase.collection('posts').withConverter<Post>(
          fromFirestore: (snapshot, _) => Post.fromJson(snapshot.data()!),
          toFirestore: (post, _) => post.toJson(),
        );
  }

  // clear wallet data
  walletClear() async {
    encryptedSharedPreferences.clear().then((value) {
      log("Wallet clear");
      wallet.value = '';
      seed.value = '';
      update();
    });
  }

  // check wallet exist
  Future<bool> walletExist() async {
    encryptedSharedPreferences = EncryptedSharedPreferences();
    //encryptedSharedPreferences.clear();
    final result = await encryptedSharedPreferences.getString("wallet");
    if (result.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  late String seedHex;
  late Chain chain;
  late ExtendedKey privateKey;
  late web3.EthPrivateKey credentials;

  // create wallet
  createWallet({String? mnemonic}) async {
    mnemonic ??= bip39.generateMnemonic();
    seedHex = bip39.mnemonicToSeedHex(mnemonic);
    chain = Chain.seed(seedHex);
    privateKey = chain.forPath("m/44'/60'/0'/0/0");
    credentials = web3.EthPrivateKey.fromHex(privateKey.privateKeyHex());

    // save to encrypted share preference
    encryptedSharedPreferences = EncryptedSharedPreferences();

    // get wallet address
    final address = await credentials.extractAddress();

    log('seed = $mnemonic');
    encryptedSharedPreferences.setString("seed", mnemonic);

    log('address = ${address.hex}');
    encryptedSharedPreferences.setString("wallet", address.hex);

    // update to firestore
    this.updateUserWallet(wallet: address.hex);

    // update data
    this.seed.value = mnemonic;
    this.wallet.value = address.hex;

    update();
  }

  // load wallet data
  Future<void> getWalletData() async {
    walletExist().then((exist) async {
      encryptedSharedPreferences = EncryptedSharedPreferences();
      final wallet = await encryptedSharedPreferences.getString("wallet");
      final seed = await encryptedSharedPreferences.getString("seed");

      log('wallet = ${wallet}');
      //log('seed = ${seed}');

      this.wallet.value = wallet;
      this.seed.value = seed;

      seedHex = bip39.mnemonicToSeedHex(this.seed.value);
      chain = Chain.seed(seedHex);
      privateKey = chain.forPath("m/44'/60'/0'/0/0");
      credentials = web3.EthPrivateKey.fromHex(privateKey.privateKeyHex());

      update();
    });
  }

  // walletShortFormat
  getWalletShortFormat({required String wallet}) {
    var first = wallet.substring(0, 5);
    var last = wallet.substring(wallet.length - 5, wallet.length);
    return first + "..." + last;
  }

  // get coin balance
  Future<EtherAmount> getCoinBalance() async {
    web3.Web3Client ethClient = web3.Web3Client(rpcUrl, Client());
    return await ethClient.getBalance(credentials.address);
  }

  // get coin balance stream
  Stream<EtherAmount> getCoinBalanceStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      EtherAmount balance = await getCoinBalance();
      yield balance;
    }
  }

  // send coin
  Future<String> sendCoin({required String to, required String amount}) async {
    web3.Web3Client ethClient = web3.Web3Client(rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });

    final result = await ethClient.sendTransaction(
      credentials,
      web3.Transaction(
        to: web3.EthereumAddress.fromHex(to),
        gasPrice: web3.EtherAmount.inWei(BigInt.one),
        maxGas: 100000,
        value: web3.EtherAmount.fromUnitAndValue(web3.EtherUnit.wei, ethers.utils.parseEther(amount)),
      ),
    );

    log('transaction result = $result ');

    return result;
  }

  // faucet contract
  late String abiCode;
  late DeployedContract contract;
  late ContractFunction withdrawFunction;

  final String faucetContractAddress = "0x0e664eaB0463697c4712D062E852E3c6c9c798dd";
  late EthereumAddress contractAddr;
  late Faucet faucet;

  readFaucetContract() async {
    // get abi
    abiCode = await rootBundle.loadString('lib/faucet.abi.json');

    // get contract
    contractAddr = EthereumAddress.fromHex(faucetContractAddress);
    contract = DeployedContract(ContractAbi.fromJson(abiCode, 'Faucet'), contractAddr);

    // set contract function
    withdrawFunction = contract.function('withdraw');

    // connect to contract
    final Web3Client ethClient = Web3Client(rpcUrl, Client());
    faucet = Faucet(address: contractAddr, client: ethClient);

    // listen for event
    // faucet.withdrawalEvents().take(1).listen((event) {
    //   log('Sent 1 ETH to ${event.to}');
    // });
  }

  Future<String> callFaucetWithdraw() async {
    try {
      String result = await faucet.withdraw(credentials: credentials);
      log('transaction result = $result');
      return result;
    } catch (e) {
      log('transaction result = $e');
      return '$e';
    }
  }
}
