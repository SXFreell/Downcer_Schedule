import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class Profile {

  const Profile({
    this.user,
    this.password,
    this.lastLoginId,
    required this.isLogin,
    this.userList,
  });

  final User? user;
  final String? password;
  final String? lastLoginId;
  final bool isLogin;
  final List<User>? userList;

  factory Profile.fromJson(Map<String,dynamic> json) => Profile(
    user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    password: json['password']?.toString(),
    lastLoginId: json['lastLoginId']?.toString(),
    isLogin: json['isLogin'] as bool,
    userList: json['userList'] != null ? (json['userList'] as List? ?? []).map((e) => User.fromJson(e as Map<String, dynamic>)).toList() : null
  );
  
  Map<String, dynamic> toJson() => {
    'user': user?.toJson(),
    'password': password,
    'lastLoginId': lastLoginId,
    'isLogin': isLogin,
    'userList': userList?.map((e) => e.toJson()).toList()
  };

  Profile clone() => Profile(
    user: user?.clone(),
    password: password,
    lastLoginId: lastLoginId,
    isLogin: isLogin,
    userList: userList?.map((e) => e.clone()).toList()
  );


  Profile copyWith({
    Optional<User?>? user,
    Optional<String?>? password,
    Optional<String?>? lastLoginId,
    bool? isLogin,
    Optional<List<User>?>? userList
  }) => Profile(
    user: checkOptional(user, () => this.user),
    password: checkOptional(password, () => this.password),
    lastLoginId: checkOptional(lastLoginId, () => this.lastLoginId),
    isLogin: isLogin ?? this.isLogin,
    userList: checkOptional(userList, () => this.userList),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Profile && user == other.user && password == other.password && lastLoginId == other.lastLoginId && isLogin == other.isLogin && userList == other.userList;

  @override
  int get hashCode => user.hashCode ^ password.hashCode ^ lastLoginId.hashCode ^ isLogin.hashCode ^ userList.hashCode;
}
