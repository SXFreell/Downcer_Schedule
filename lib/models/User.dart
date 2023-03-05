import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class User {

  const User({
    required this.id,
    required this.name,
    this.courseList,
    required this.setting,
  });

  final String id;
  final String name;
  final CourseList? courseList;
  final Setting setting;

  factory User.fromJson(Map<String,dynamic> json) => User(
    id: json['id'].toString(),
    name: json['name'].toString(),
    courseList: json['courseList'] != null ? CourseList.fromJson(json['courseList'] as Map<String, dynamic>) : null,
    setting: Setting.fromJson(json['setting'] as Map<String, dynamic>)
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'courseList': courseList?.toJson(),
    'setting': setting.toJson()
  };

  User clone() => User(
    id: id,
    name: name,
    courseList: courseList?.clone(),
    setting: setting.clone()
  );


  User copyWith({
    String? id,
    String? name,
    Optional<CourseList?>? courseList,
    Setting? setting
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    courseList: checkOptional(courseList, () => this.courseList),
    setting: setting ?? this.setting,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is User && id == other.id && name == other.name && courseList == other.courseList && setting == other.setting;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ courseList.hashCode ^ setting.hashCode;
}
