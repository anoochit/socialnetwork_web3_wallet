import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

PostModel postFromJson(String str) => PostModel.fromJson(json.decode(str));

String postToJson(PostModel data) => json.encode(data.toJson());

class PostModel {
  PostModel({
    this.uid,
    this.title,
    this.content,
    this.type,
    this.created,
    this.updated,
  });

  String? uid;
  String? title;
  String? content;
  String? type;
  Timestamp? created;
  Timestamp? updated;

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        uid: json["uid"] == null ? null : json["uid"],
        title: json["title"] == null ? null : json["title"],
        content: json["content"] == null ? null : json["content"],
        type: json["type"] == null ? null : json["type"],
        created: json["created"] == null ? null : json["created"],
        updated: json["updated"] == null ? null : json["updated"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid == null ? null : uid,
        "title": title == null ? null : title,
        "content": content == null ? null : content,
        "type": type == null ? null : type,
        "created": created == null ? null : created,
        "updated": updated == null ? null : updated,
      };
}
