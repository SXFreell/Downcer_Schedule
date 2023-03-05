// ignore_for_file: prefer_const_constructors
import 'package:downcer/routes/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'common/Global.dart';

void main() => Global.init().then((e) => runApp(MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark
    ));
    if(!Global.profile.isLogin) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
        title: "Downcer",
        theme: ThemeData(
          primaryColor: Color(0xFF2D52CC),
        ),
        builder: EasyLoading.init(),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Home(),
        title: "Downcer",
        theme: ThemeData(
          primaryColor: Color(0xFF2D52CC),
        ),
        builder: EasyLoading.init(),
      );
    }
  }
}


