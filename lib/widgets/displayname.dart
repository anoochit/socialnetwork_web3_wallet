import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';

class UserDisplayName extends StatelessWidget {
  UserDisplayName({
    Key? key,
    required this.uid,
  }) : super(key: key);

  final AppController appController = Get.find<AppController>();
  final String uid;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: appController.getUserData(uid: uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(
            snapshot.data!['displayName'],
          );
        }
        return Container();
      },
    );
  }
}
