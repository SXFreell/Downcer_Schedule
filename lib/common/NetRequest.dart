import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class NetRequest {
  static const String loginUrl = "uc/wap/login/check";
  static const String infoUrl = "uc/wap/user/get-info";
  static const String saveUrl = "ncov/wap/default/save";
  static const String geoUrl = "geocode/regeo";
  static const String tranGPSUrl = "assistant/coordinate/convert";

  static final CookieJar cookieJar = CookieJar();

  static Dio upcRequest = Dio(BaseOptions(
    baseUrl: 'https://app.upc.edu.cn/',
    connectTimeout: 8000,
    receiveTimeout: 8000,
    headers: {
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.54",
      "Connection": "keep-alive"
    }
  ));

  static Dio httpRequest = Dio(BaseOptions(
    connectTimeout: 5000,
    receiveTimeout: 3000,
    headers: {
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.54",
      "Connection": "keep-alive",
      "Accept": "*/*",
    }
  ));

  static Dio geoRequest = Dio(BaseOptions(
    baseUrl: 'https://restapi.amap.com/v3/',
    connectTimeout: 5000,
    receiveTimeout: 3000
  ));
}