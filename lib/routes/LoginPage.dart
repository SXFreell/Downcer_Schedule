// ignore_for_file: prefer_const_constructors
import 'dart:io';

import 'package:downcer/common/Global.dart';
import 'package:downcer/common/method.dart';
import 'package:downcer/main.dart';
import 'package:downcer/routes/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginWidget(),
    );
  }
}

class LoginWidget extends StatelessWidget {
  const LoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var top = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        SizedBox(height: top+60),
        Center(
          child: SvgPicture.asset(
            'assets/images/Downcer.svg',
            width: 280,
          ),
        ),
        SizedBox(height: 40),
        SizedBox(
          width: 300,
          height: 40,
          child: Text(
            '登陆账号',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        SizedBox(
          width: 300,
          child: LoginForm(),
        )
      ],
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController(text: Global.profile.lastLoginId ?? '');
  final TextEditingController _passwordController = TextEditingController();
  Color primaryColor = Color(0xFF2D52CC);
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    primaryColor = Theme.of(context).primaryColor;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _usernameController,
            cursorColor: primaryColor,
            decoration: InputDecoration(
              hintText: '数字石大账号',
              hintStyle: TextStyle(
                color: Color(0xFFCCCCCC),
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: primaryColor,
                  width: 2
                )
              ),
            ),
            style: TextStyle(
              fontSize: 20
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入账号';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            cursorColor: primaryColor,
            decoration: InputDecoration(
              hintText: '密码',
              hintStyle: TextStyle(
                color: Color(0xFFCCCCCC),
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: primaryColor,
                  width: 2
                )
              ),
            ),
            style: TextStyle(
              fontSize: 20
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入密码';
              }
              return null;
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Expanded(
                  child: loginButton()
                )
              ],
            ),
          )
        ],
      )
    );
  }

  Widget loginButton() {
    if(loading) {
      return ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue[300]),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          textStyle: MaterialStateProperty.all(TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )),
        ),
        onPressed: null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(Colors.blue[200]),
                strokeWidth : 2.0
              ),
            ),
            SizedBox(width: 8),
            Text('登 陆')
          ],
        ),
      );
    } else {
      return ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(primaryColor),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          textStyle: MaterialStateProperty.all(TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )),
        ),
        onPressed: () {
          if ((_formKey.currentState as FormState).validate()) {
            LoginFunction.runLogin(_usernameController.text, _passwordController.text).then((value) {
              if(value==0 || value==3) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                      (route) => route == null
                );
                if(value==3 || Global.profile.user!.courseList==null) {
                  Fluttertoast.showToast(
                    msg: "当前没有课程表，请点击右上角菜单同步课程表",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 3,
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    fontSize: 14.0
                  );
                }
              } else {
                String nowText;
                if(value==-1) {
                  nowText = '网络错误';
                } else if(value==1) {
                  nowText = '账号或密码错误';
                } else if(value==2) {
                  nowText = '错误次数已达最大上限,请稍后再试';
                } else {
                  nowText = '未知错误(请联系作者)';
                }
                var snackBar = SnackBar(
                  content: Text(nowText),
                  backgroundColor: Colors.red,
                  duration: Duration(milliseconds: 2000),
                  width: 300.0,
                  behavior: SnackBarBehavior.floating,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                setState(() {
                  loading = false;
                });
              }
            });
            setState(() {
              loading = true;
            });
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text('登 陆')],
        ),
      );
    }
  }
}