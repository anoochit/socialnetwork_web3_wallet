import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snwallet/models/post.dart';

import 'package:bip39/bip39.dart' as bip39;
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';

class AppController extends GetxController {
  RxString uid = "".obs;
  RxString displayName = "".obs;

  final FirebaseFirestore firebase = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

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
      this.uid.value = auth.currentUser!.uid;
      this.displayName.value = displayName;
      update();
    });
  }

  // Get user data in FireStore
  getUser({required String uid}) {
    firebase.collection('users').doc(uid).get().then((user) {
      log('user docId =' + user.id);
      // set user data
      this.uid.value = user['uid'];
      this.displayName.value = user['displayName'];
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

  // check wallet exist
  Future<bool> walletExist() async {
    final EncryptedSharedPreferences encryptedSharedPreferences = EncryptedSharedPreferences();
    final result = await encryptedSharedPreferences.getString("wallet");
    if (result.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  // create wallet
  walletCreate() {
    final mnemonic = bip39.generateMnemonic();
    log('mnemonic = $mnemonic');
  }
}
