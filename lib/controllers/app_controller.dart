import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snwallet/models/post.dart';

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
}
