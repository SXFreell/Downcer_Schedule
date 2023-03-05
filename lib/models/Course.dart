import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class Course {

  const Course({
    required this.term,
    required this.countWeek,
    required this.startDay,
    this.course,
  });

  final String term;
  final int countWeek;
  final String startDay;
  final List<dynamic>? course;

  factory Course.fromJson(Map<String,dynamic> json) => Course(
    term: json['term'].toString(),
    countWeek: json['countWeek'] as int,
    startDay: json['startDay'].toString(),
    course: json['course'] != null ? (json['course'] as List? ?? []).map((e) => e as dynamic).toList() : null
  );
  
  Map<String, dynamic> toJson() => {
    'term': term,
    'countWeek': countWeek,
    'startDay': startDay,
    'course': course?.map((e) => e.toString()).toList()
  };

  Course clone() => Course(
    term: term,
    countWeek: countWeek,
    startDay: startDay,
    course: course?.toList()
  );


  Course copyWith({
    String? term,
    int? countWeek,
    String? startDay,
    Optional<List<dynamic>?>? course
  }) => Course(
    term: term ?? this.term,
    countWeek: countWeek ?? this.countWeek,
    startDay: startDay ?? this.startDay,
    course: checkOptional(course, () => this.course),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Course && term == other.term && countWeek == other.countWeek && startDay == other.startDay && course == other.course;

  @override
  int get hashCode => term.hashCode ^ countWeek.hashCode ^ startDay.hashCode ^ course.hashCode;
}
