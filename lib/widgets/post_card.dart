import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/controllers/wallet_controller.dart';
import 'package:snwallet/models/post.dart';
import 'package:snwallet/widgets/displayname.dart';

class PostCard extends StatelessWidget {
  PostCard({
    Key? key,
    required this.post,
  }) : super(key: key);

  final QueryDocumentSnapshot<PostModel> post;

  final AppController appController = Get.find<AppController>();
  final WalletController walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    // get created date
    final created = DateTime.fromMicrosecondsSinceEpoch(
      post["created"].microsecondsSinceEpoch,
    );
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top post box
          Row(
            children: [
              GestureDetector(
                // user avatar
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(),
                ),
                onTap: () {
                  // goto user profile
                },
              ),
              GestureDetector(
                onTap: () {
                  // goto user profile
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // display name
                    UserDisplayName(uid: post["uid"]),
                    // post timestamp
                    Text(DateFormat('dd MMM yyy HH:mm').format(created)),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // share to social media
                },
                icon: const Icon(
                  Icons.more_horiz,
                  size: 24,
                ),
              ),
            ],
          ),
          // post content
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(post["title"].trim()),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // donate post
              TextButton.icon(
                onPressed: () {
                  // donate post
                  appController.getUserData(uid: post['uid']).then((user) {
                    if (appController.uid != user['uid']) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Donate"),
                              content: Text(
                                'Do you want to donate 0.1 ETH to ${user['displayName']} ?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // donate 0.1 ETH
                                    walletController
                                        .sendCoin(to: user['wallet'], amount: '0.1')
                                        .then((value) => log('tx = $value'));
                                    Get.back();
                                  },
                                  child: const Text("Donate"),
                                ),
                              ],
                            );
                          });
                    }
                  });
                },
                icon: const Icon(
                  Icons.attach_money,
                ),
                label: const Text("Donate"),
              ),

              // send gift
              TextButton.icon(
                onPressed: () {
                  // send gift
                  log("send gift token");
                },
                icon: const Icon(
                  Icons.redeem,
                ),
                label: const Text("Send Gift"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
