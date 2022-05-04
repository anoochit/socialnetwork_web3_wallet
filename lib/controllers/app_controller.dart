import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
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

  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late EncryptedSharedPreferences encryptedSharedPreferences;

  // rpc server
  final String _rpcUrl = "http://10.0.2.2:7545";
  final String _wsUrl = 'ws://10.0.2.2:8545';
  final String _blockExplorer = 'http://10.0.2.2:4000';

  // Create user data in FireStore
  createUser({required String uid, required String displayName}) {
    _firebase.collection('users').doc(uid).set({
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
    _firebase.collection('users').doc(_auth.currentUser!.uid).update({
      'displayName': displayName,
      'updated': DateTime.now(),
    }).then((value) {
      // set user data
      this.uid.value = _auth.currentUser!.uid;
      this.displayName.value = displayName;
      update();
    });
  }

  updateUserWallet({required String wallet}) {
    _firebase.collection('users').doc(_auth.currentUser!.uid).update({
      'wallet': wallet,
    });
  }

  // Get user data in FireStore
  getUser({required String uid}) {
    _firebase.collection('users').doc(uid).get().then((user) {
      log('user docId =' + user.id);
      // set user data
      this.uid.value = user['uid'];
      this.displayName.value = user['displayName'];
      update();
    });
  }

  // Post stream
  CollectionReference<Post> getPostStream() {
    return _firebase.collection('posts').withConverter<Post>(
          fromFirestore: (snapshot, _) => Post.fromJson(snapshot.data()!),
          toFirestore: (post, _) => post.toJson(),
        );
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

  // create wallet
  createWallet({String? mnemonic}) {
    if (mnemonic == null) {
      // generate mnemonic
      mnemonic = bip39.generateMnemonic(); // seed word
    }
    String seedHex = bip39.mnemonicToSeedHex(mnemonic);
    Chain chain = Chain.seed(seedHex);
    ExtendedKey privateKey = chain.forPath("m/44'/60'/0'/0/0");
    web3.EthPrivateKey credentials = web3.EthPrivateKey.fromHex(privateKey.privateKeyHex());

    // save to encrypted share preference
    encryptedSharedPreferences = EncryptedSharedPreferences();

    // get wallet address
    credentials.extractAddress().then((address) {
      log('seed = ${mnemonic}');
      encryptedSharedPreferences.setString("seed", mnemonic!);

      log('address = ${address.hex}');
      encryptedSharedPreferences.setString("wallet", address.hex);

      this.seed.value = mnemonic;
      this.wallet.value = address.hex;

      getWalletData();

      update();
    });
  }

  late String seedHex;
  late Chain chain;
  late ExtendedKey privateKey;
  late web3.EthPrivateKey credentials;

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
  // Stream<web3.EtherAmount> getCoinBalance() {
  //   web3.Web3Client ethClient = web3.Web3Client(_rpcUrl, Client());
  //   return Stream.fromFuture(ethClient.getBalance(credentials.address));
  // }

  Future<EtherAmount> getCoinBalance() async {
    web3.Web3Client ethClient = web3.Web3Client(_rpcUrl, Client());
    return await ethClient.getBalance(credentials.address);
  }

  // send coin
  sendCoin({required String to, required double amount}) async {
    web3.Web3Client ethClient = web3.Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });
    var result = await ethClient.sendTransaction(
      credentials,
      web3.Transaction(
        to: web3.EthereumAddress.fromHex(to),
        gasPrice: web3.EtherAmount.inWei(BigInt.one),
        maxGas: 100000,
        value: web3.EtherAmount.fromUnitAndValue(web3.EtherUnit.ether, BigInt.from(amount)),
      ),
    );

    log('transaction result = $result');

    return result;
  }
}
