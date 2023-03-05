// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:downcer/common/Global.dart';
import 'package:downcer/common/Method.dart';
import 'package:downcer/common/NetRequest.dart';
import 'package:flutter/material.dart';
import 'package:downcer/models/index.dart';
import 'package:quiver/core.dart';

class CourseGetor {
  static Future<Map<String,dynamic>> getCourseList() async {
    NetRequest.upcRequest.interceptors.add(CookieManager(NetRequest.cookieJar));
    try {
      String username = Global.profile.user!.id;
      String password = Global.profile.password!;
      Response response = await LoginFunction.login(username, password);
      if (response.data['e'] == 0) {
        Map<String,dynamic> indexInfo = await getIndex();
        List<String> termList = [];
        List<Course> courses = [];
        for(Map<String,dynamic> termItem in indexInfo['d']['termInfo']) {
          String term = termItem['year']+"-"+termItem['term'];
          Course course = Course(
            term: term,
            countWeek: int.parse(termItem['countweek']),
            startDay: termItem['startday']
          );
          termList.add(term);
          courses.add(course);
        }
        for(int k=0;k<courses.length;k++) {
          String year = courses[k].term.substring(0,9);
          String term = courses[k].term.substring(10);
          List<String> classes = List.filled(courses[k].countWeek, "");
          List<Future> futureList = [];
          for(int i=1;i<=courses[k].countWeek;i++) {
            futureList.add(
              getDatatmp(year, term, i.toString()).then((datatmp) {
                if(datatmp['e'] == 0) {
                  String courseClasses = jsonEncode(datatmp['d']['classes']);
                  return {"index": i-1, "courseClasses": courseClasses};
                }
              })
            );
          }
          List results = await Future.wait(futureList);
          for(var result in results) {
            classes[result['index']] = result['courseClasses'];
          }
          courses[k] = courses[k].copyWith(course: Optional.of(classes));
        }
        CourseList courseList = CourseList(termList: termList, courseList: courses);
        User user = Global.profile.user!;
        user = user.copyWith(courseList: Optional.of(courseList));
        Global.profile = Global.profile.copyWith(user: Optional.of(user));
        Global.saveProfile();
        return {"code":0, "msg":"同步完成"};
      } else {
        return {"code":1, "msg":"登录失效，请重新登录"};
      }
    } catch (e) {
      print(e);
      return {"code":-1, "msg":"网络错误，请检查是否连接校园网或VPN，或稍后再试"};
    }
  }
  
  static Future<Map<String,dynamic>> getIndex() async {
    Response response = await NetRequest.upcRequest.get("http://app.upc.edu.cn/timetable/wap/default/get-index");
    return response.data;
  }

  static Future<Map<String,dynamic>> getDatatmp(String year, String term, String week) async {
    FormData formData = FormData.fromMap({
      'year': year,
      'term': term,
      'week': week,
      'type': '2'
    });
    Response response = await NetRequest.upcRequest.post("http://app.upc.edu.cn/timetable/wap/default/get-datatmp", data: formData);
    if(response.data.runtimeType.toString() == "String") {
      return jsonDecode(response.data);
    } else {
      return response.data;
    }
  }

  static Future<Response> getInfo() async {
    // String data = "xnxq01id=2022-2023-1&sfFD=1";
    Map<String, dynamic> data = {
      "xnxq01id": "2022-2023-1",
      "sfFD": "1"
    };
    return await NetRequest.httpRequest.request("http://jwxt.upc.edu.cn/jsxsd/xskb/xskb_list.do", data: data, options: Options(
      contentType: Headers.formUrlEncodedContentType,
    ));
  }

  // static void login() async {
  //   RegExp regExp;
  //   Iterable<Match> matches;
  //   String username = Global.profile.user!.id;
  //   String password = Global.profile.password!;
  //   Response response = await NetRequest.httpRequest.get("http://cas.upc.edu.cn/cas/login");
  //   Document document = parse(response.data);
  //   String? lt = document.getElementById("lt")!.attributes["value"];
  //   // String lt = "jiami";
  //   // regExp = RegExp(r'name="execution" value="(.*)" />');
  //   // matches = regExp.allMatches(response.data.toString());
  //   // String execution = matches.elementAt(0).group(1)!;
  //   // regExp = RegExp(r'name="_eventId" value="(.*)" />');
  //   // matches = regExp.allMatches(response.data.toString());
  //   // String eventId = matches.elementAt(0).group(1)!;
  //   // String execution = "e1s1";
  //   // String eventId = "submit";
  //   int ul = username.length;
  //   int pl = password.length;
  //   String content = '$username$password$lt';
  //   String rsa = DES.strEnc(content, "1", "2", "3");
  //   String data = "rsa=$rsa&ul=$ul&pl=$pl&lt=$lt&execution=e1s1&_eventId=submit";
  //   Map<String, dynamic> datas = {
  //     "rsa": rsa,
  //     "ul": ul.toString(),
  //     "pl": pl.toString(),
  //     "lt": lt,
  //     "execution": "e1s1",
  //     "_eventId": "submit"
  //   };

  //   var url = Uri.http('cas.upc.edu.cn', '/cas/login');
  //   var responses = await http.post(url, body: datas);
  //   log(responses.headers.toString());
  //   regExp = RegExp(r'JSESSIONID=(.*?);');
  //   matches = regExp.allMatches(response.headers.toString());
  //   String JSESSIONID = matches.elementAt(0).group(1)!;
  //   url = Uri.http('jwxt.upc.edu.cn', 'jsxsd/framework/xsMain.jsp');
  //   var header = {
  //     "Cookie": "JSESSIONID=$JSESSIONID"
  //   };
  //   responses = await http.get(url,headers: header);
  //   log(responses.body);


  //   response = await NetRequest.httpRequest.request("http://cas.upc.edu.cn/cas/login", data: data, options: Options(
  //     contentType: Headers.formUrlEncodedContentType,
  //     method: "POST",
  //     followRedirects: true,
  //     validateStatus: (status) {
  //       return status! < 500;
  //     },
  //   ));
  //   regExp = RegExp(r'<a href="(.*?)">');
  //   matches = regExp.allMatches(response.data.toString());
  //   String ticketurl = matches.elementAt(0).group(1)!;
  //   response = await NetRequest.httpRequest.get(ticketurl);
  //   response = await NetRequest.httpRequest.get("http://jwxt.upc.edu.cn/jsxsd/framework/xsMain.jsp");
  //   log(response.data);
  // //   response = await getInfo();
  // //   print(response.data);
  // }
}