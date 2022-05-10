import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snwallet/models/post.dart';

class PostController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Post stream
  CollectionReference<PostModel> getPostStream() {
    return firestore.collection('posts').withConverter<PostModel>(
          fromFirestore: (snapshot, _) => PostModel.fromJson(snapshot.data()!),
          toFirestore: (post, _) => post.toJson(),
        );
  }

  createPost({required String type, required String title, String? content}) {
    String timeStamp = DateTime.now().microsecondsSinceEpoch.toString();
    firestore.collection("posts").doc(timeStamp).set({
      'type': type,
      'title': title,
      'content': content,
      'uid': auth.currentUser!.uid,
      'created': DateTime.now(),
      'updated': DateTime.now(),
    });
    log('create post = $title');
  }
}
