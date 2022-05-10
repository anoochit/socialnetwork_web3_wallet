import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  RxString uid = "".obs;
  RxString displayName = "".obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Create user data in FireStore
  createUser({required String uid, required String displayName}) {
    firestore.collection('users').doc(uid).set({
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
    firestore.collection('users').doc(auth.currentUser!.uid).update({
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
    firestore.collection('users').doc(auth.currentUser!.uid).update({
      'wallet': wallet,
    });
  }

  // Get user data in FireStore
  getCurrentUserData({required String uid}) {
    firestore.collection('users').doc(uid).get().then((user) {
      log('user uid = ' + user.id);
      // set user data
      this.uid.value = user['uid'];
      displayName.value = user['displayName'];
      update();
    });
  }

  Future<DocumentSnapshot> getUserData({required String uid}) async {
    return await firestore.collection("users").doc(uid).get();
  }
}
