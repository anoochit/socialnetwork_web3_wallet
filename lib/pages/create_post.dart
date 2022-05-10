import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snwallet/controllers/app_controller.dart';
import 'package:snwallet/controllers/post_controller.dart';

class CreatePostPage extends StatelessWidget {
  CreatePostPage({Key? key}) : super(key: key);

  final TextEditingController textEditingController = TextEditingController();
  final AppController appController = Get.find<AppController>();
  final PostController postController = Get.find<PostController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create post"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              maxLines: null,
              controller: textEditingController,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                hintText: "What's on your mind?",
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: const Text("Post"),
            onPressed: () {
              // post
              postController.createPost(
                type: "text",
                title: textEditingController.text.trim(),
              );
              Get.back();
            },
          ),
        ),
      ),
    );
  }
}
