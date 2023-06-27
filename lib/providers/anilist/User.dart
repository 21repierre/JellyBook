import 'package:flutter/material.dart';

class User {
  int id;
  String name;
  String about;
  String bannerImage;
  String avatar;
  Color profileColor;

  User(this.id, this.name, this.about, this.bannerImage, this.avatar, this.profileColor);

  @override
  String toString() {
    return 'User{id: $id, name: $name, about: $about, bannerImage: $bannerImage, avatar: $avatar, profileColor: $profileColor}';
  }
}
