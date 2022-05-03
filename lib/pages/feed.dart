import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/models/post.dart';

class FeedPage extends StatelessWidget {
  FeedPage({Key? key}) : super(key: key);

  final AppController appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder<Post>(
        query: appController.getPostStream(),
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

              final post = snapshot.docs[index].data();
              return Text('${post.title}');
            },
          );
        });
  }
}
