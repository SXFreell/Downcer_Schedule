import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class Setting {

  const Setting({
    this.setting,
  });

  final String? setting;

  factory Setting.fromJson(Map<String,dynamic> json) => Setting(
    setting: json['setting']?.toString()
  );
  
  Map<String, dynamic> toJson() => {
    'setting': setting
  };

  Setting clone() => Setting(
    setting: setting
  );


  Setting copyWith({
    Optional<String?>? setting
  }) => Setting(
    setting: checkOptional(setting, () => this.setting),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is Setting && setting == other.setting;

  @override
  int get hashCode => setting.hashCode;
}
