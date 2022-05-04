import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:snwallet/models/post.dart';

import 'package:bip39/bip39.dart' as bip39;
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
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
  createWallet() {
    // generate mnemonic
    String mnemonic = bip39.generateMnemonic(); // seed word
    String seed = bip39.mnemonicToSeedHex(mnemonic);

    Chain chain = Chain.seed(seed);
    ExtendedKey privateKey = chain.forPath("m/44'/60'/0'/0/0");
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey.privateKeyHex());

    // save to encrypted share preference
    encryptedSharedPreferences = EncryptedSharedPreferences();

    // get wallet address
    credentials.extractAddress().then((address) {
      log('seed = ${mnemonic}');
      encryptedSharedPreferences.setString("seed", mnemonic);

      log('address = ${address.hex}');
      encryptedSharedPreferences.setString("wallet", address.hex);

      this.seed.value = mnemonic;
      this.wallet.value = address.hex;
      update();
    });
  }

  late String _seedHex;
  late Chain _chain;
  late ExtendedKey _privateKey;
  late EthPrivateKey _credentials;
  late Web3Client _ethClient;

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

      _seedHex = bip39.mnemonicToSeedHex(this.seed.value);
      _chain = Chain.seed(_seedHex);
      _privateKey = _chain.forPath("m/44'/60'/0'/0/0");
      _credentials = EthPrivateKey.fromHex(_privateKey.privateKeyHex());

      update();
    });
  }

  // get coin balance
  Stream<EtherAmount> getCoinBalance() {
    _ethClient = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });
    return _ethClient.getBalance(_credentials.address).asStream();
  }

  // send coin
  sendCoin({required String to, required double amount}) {}
}
