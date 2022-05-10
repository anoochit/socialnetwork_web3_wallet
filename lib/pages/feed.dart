import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/controllers/post_controller.dart';
import 'package:snwallet/models/post.dart';
import 'package:snwallet/widgets/displayname.dart';
import 'package:snwallet/widgets/post_card.dart';

class FeedPage extends StatelessWidget {
  FeedPage({Key? key}) : super(key: key);

  final AppController appController = Get.find<AppController>();
  final PostController postController = Get.find<PostController>();

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder<PostModel>(
        query: postController.getPostStream(),
        builder: (context, snapshot, _) {
          // is loading
          if (snapshot.isFetching) {
            return const CircularProgressIndicator();
          }
          // has error
          if (snapshot.hasError) {
            return Text('error ${snapshot.error}');
          }

          return ListView.builder(
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              // if nit finish fetch more
              if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                // fetch more
                snapshot.fetchMore();
              }

              // is empty
              if (snapshot.docs.isEmpty) {
                return const Text('No posts');
              }

              // has data
              if (snapshot.hasData) {
                // get post item
                final post = snapshot.docs[index];
                // get created date
                final created = DateTime.fromMicrosecondsSinceEpoch(
                  post["created"].microsecondsSinceEpoch,
                );
                return PostCard(created: created, post: post);
              }

              return const CircularProgressIndicator();
            },
          );
        });
  }
}
