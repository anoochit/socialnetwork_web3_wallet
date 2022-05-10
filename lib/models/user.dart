// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel({
    this.displayName,
    this.uid,
    this.wallet,
  });

  String? displayName;
  String? uid;
  String? wallet;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        displayName: json["displayName"] == null ? null : json["displayName"],
        uid: json["uid"] == null ? null : json["uid"],
        wallet: json["wallet"] == null ? null : json["wallet"],
      );

  Map<String, dynamic> toJson() => {
        "displayName": displayName == null ? null : displayName,
        "uid": uid == null ? null : uid,
        "wallet": wallet == null ? null : wallet,
      };
}
