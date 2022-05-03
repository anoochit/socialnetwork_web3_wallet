import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

Post postFromJson(String str) => Post.fromJson(json.decode(str));

String postToJson(Post data) => json.encode(data.toJson());

class Post {
  Post({
    this.uid,
    this.title,
    this.content,
    this.type,
    this.update,
  });

  String? uid;
  String? title;
  String? content;
  String? type;
  Timestamp? update;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        uid: json["uid"] == null ? null : json["uid"],
        title: json["title"] == null ? null : json["title"],
        content: json["content"] == null ? null : json["content"],
        type: json["type"] == null ? null : json["type"],
        update: json["update"] == null ? null : json["update"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid == null ? null : uid,
        "title": title == null ? null : title,
        "content": content == null ? null : content,
        "type": type == null ? null : type,
        "update": update == null ? null : update,
      };
}
