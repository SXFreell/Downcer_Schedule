import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class CourseList {

  const CourseList({
    this.termList,
    this.courseList,
  });

  final List<dynamic>? termList;
  final List<Course>? courseList;

  factory CourseList.fromJson(Map<String,dynamic> json) => CourseList(
    termList: json['termList'] != null ? (json['termList'] as List? ?? []).map((e) => e as dynamic).toList() : null,
    courseList: json['courseList'] != null ? (json['courseList'] as List? ?? []).map((e) => Course.fromJson(e as Map<String, dynamic>)).toList() : null
  );
  
  Map<String, dynamic> toJson() => {
    'termList': termList?.map((e) => e.toString()).toList(),
    'courseList': courseList?.map((e) => e.toJson()).toList()
  };

  CourseList clone() => CourseList(
    termList: termList?.toList(),
    courseList: courseList?.map((e) => e.clone()).toList()
  );


  CourseList copyWith({
    Optional<List<dynamic>?>? termList,
    Optional<List<Course>?>? courseList
  }) => CourseList(
    termList: checkOptional(termList, () => this.termList),
    courseList: checkOptional(courseList, () => this.courseList),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is CourseList && termList == other.termList && courseList == other.courseList;

  @override
  int get hashCode => termList.hashCode ^ courseList.hashCode;
}
