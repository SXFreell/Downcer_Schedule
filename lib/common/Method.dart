// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:downcer/common/Global.dart';
import 'package:downcer/models/index.dart';
import 'package:downcer/common/NetRequest.dart';
import 'package:downcer/routes/index.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:quiver/core.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class LoginFunction {

  static Future<int> runLogin(String username, String password) async {
    NetRequest.upcRequest.interceptors.add(CookieManager(NetRequest.cookieJar));
    try {
      Response response = await login(username, password);
      User user;
      List<User> userList = [];
      if(response.data['e']==0) {
        if(Global.profile.userList!=null) {
          userList = Global.profile.userList!;
          for(int i=0; i<userList.length; i++) {
            if(userList[i].id==username) {
              User user = userList[i];
              Global.profile = Global.profile.copyWith(user: Optional.of(user), password: Optional.of(password), isLogin: true, lastLoginId: Optional.of(username));
              Global.saveProfile();
              return 0;
            }
          }
          Response response = await getInfo();
          String realname = response.data['d']['base']['realname'];
          user = User(
            id: username,
            name: realname,
            setting: const Setting()
          );
          userList.add(user);
        } else {
          Response response = await getInfo();
          String realname = response.data['d']['base']['realname'];
          user = User(
            id: username,
            name: realname,
            setting: const Setting()
          );
          userList = [user];
        }
        Global.profile = Global.profile.copyWith(user: Optional.of(user), password: Optional.of(password), isLogin: true, lastLoginId: Optional.of(username), userList: Optional.of(userList));
        Global.saveProfile();
        return 3;
      } else if (response.data['e']==10011) {
        return 1;
      } else if (response.data['e']==10016) {
        return 2;
      } else {
        return 4;
      }
    } catch (e) {
      print(e);
      return -1;
    }
  }

  static Future<int> getStatus(BuildContext context) async {
    String username = Global.profile.user!.id;
    String password = Global.profile.password!;
    NetRequest.upcRequest.interceptors.add(CookieManager(NetRequest.cookieJar));
    try {
      Response response = await login(username, password);
      if(response.data['e']==0) {
        Response response = await getInfo();
        // print(response.data.toString());
        RegExp regExp = RegExp(r"hasFlag: '(.*)',");
        Iterable<Match> matches = regExp.allMatches(response.data.toString());
        String hasFlag = matches.elementAt(0).group(1)!;
        if(hasFlag=="1") {
          return 1;
        } else {
          return 0;
        }
      } else {
        Global.profile = Global.profile.copyWith(isLogin: false, user: null);
        Global.saveProfile();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => route == null
        );
        return -2;
      }
    } catch (e) {
      return -1;
    }
  }

  static Future<Response> login(String username, String password) async {
    FormData formData = FormData.fromMap({
      'username': username,
      'password': password
    });
    return await NetRequest.upcRequest.post(NetRequest.loginUrl, data: formData);
  }

  static Future<Response> getInfo() async {
    return await NetRequest.upcRequest.get(NetRequest.infoUrl);
  }
}

class DailyRem {
  static Future<Map<String, dynamic>> runRem() async {
    NetRequest.upcRequest.interceptors.add(CookieManager(NetRequest.cookieJar));
    try {
      Location location = Location();
      bool serviceEnabled;
      PermissionStatus permissionGranted;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return {"code": -1, "msg": "位置服务不可用"};
        }
      }
      permissionGranted = await location.hasPermission();
      if(permissionGranted==PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if(permissionGranted != PermissionStatus.granted) {
          return {"code": -1, "msg": "位置权限被拒绝"};
        }
      }
      LocationData locationData = await location.getLocation();
      print("开始打卡");
      double latitude = locationData.latitude!;
      double longitude = locationData.longitude!;
      print("latitude: $latitude, longitude: $longitude");
      List<double> result = await tranGPS(latitude, longitude);
      return {"code": 0, "msg": "获取信息成功"};
    } catch (e) {
      return {"code": -1, "msg": "获取信息错误"};
    }
  }

  static Future<List<double>> tranGPS(double lat, double lng) async {
    Response response = await NetRequest.geoRequest.get(NetRequest.tranGPSUrl, queryParameters: {
      "output": "json",
      "coordsys": "gps",
      "locations": "$lng,$lat",
      "key": "c4b230ef479bb14f4becfe48f8365161"
    });
    print(response.data.toString());
    List<double> result = [];
    // result.add(response.data['locations'][0]['lat']);
    // result.add(response.data['locations'][0]['lng']);
    return result;
  }

  static Future<Map<String, String>> getDetailInfo() async {
    Response response = await getInfo();
    RegExp regExp1 = RegExp(r"oldInfo: (.*),\n            tipMsg");
    RegExp regExp2 = RegExp("\"id\":(\\w+)");
    RegExp regExp3 = RegExp("\"created\":(\\w+)");
    Iterable<Match> matches1 = regExp1.allMatches(response.data.toString());
    Iterable<Match> matches2 = regExp2.allMatches(response.data.toString());
    Iterable<Match> matches3 = regExp3.allMatches(response.data.toString());
    String oldInfo = matches1.elementAt(0).group(1)!;
    String id = matches2.elementAt(0).group(1)!;
    String created = matches3.elementAt(0).group(1)!;
    return {"oldInfo": oldInfo, "id": id, "created": created};
  }

  static Future<Response> getInfo() async {
    return await NetRequest.upcRequest.get(NetRequest.infoUrl);
  }
}