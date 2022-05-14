import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/controllers/post_controller.dart';
import 'package:snwallet/models/post.dart';
import 'package:snwallet/widgets/post_card.dart';

class FeedPage extends StatelessWidget {
  FeedPage({Key? key}) : super(key: key);

  final AppController appController = Get.find<AppController>();
  final PostController postController = Get.find<PostController>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<PostModel>>(
      stream: postController.getPostStream().orderBy('updated', descending: true).snapshots(),
      builder: (context, snapshot) {
        // has error
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        // wait for the stream to be ready
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final post = snapshot.data!.docs[index];
              return PostCard(post: post);
            },
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
