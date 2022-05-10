import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/models/post.dart';
import 'package:snwallet/widgets/displayname.dart';

class PostCard extends StatelessWidget {
  PostCard({
    Key? key,
    required this.created,
    required this.post,
  }) : super(key: key);

  final DateTime created;
  final QueryDocumentSnapshot<PostModel> post;

  final AppController appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
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
                },
                icon: const Icon(
                  Icons.attach_money,
                ),
                label: const Text("Donate"),
              ),

              // donate post
              TextButton.icon(
                onPressed: () {
                  // donate post
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
