import 'dart:convert';
import 'dart:math';
import 'package:downcer/common/GetCourseList.dart';
import 'package:downcer/common/Global.dart';
import 'package:downcer/main.dart';
import 'package:downcer/models/index.dart';
import 'package:downcer/routes/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/core.dart';
import 'MyPopupMenu.dart' as MyPopupMenu;

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  User? user = Global.profile.user;
  List<String> weekList = ['日', '一', '二', '三', '四', '五', '六'];
  List<String> dateList = ["0.0","0.0","0.0","0.0","0.0","0.0","0.0"];
  double gridWidth = 0;
  String goodtime = '早上好';
  String realname = '姓名';
  int nowMonth = 1;
  int nowYear = 2022;
  int nowDay = 1;
  int selMonth = 1;
  int selWeek = 1;
  int selYear = 2022;
  int selDay = 1;
  int maxWeek = 1;
  String term = '无课表';
  int selectid = -1;
  int selectindex = 1;
  List<num> selectList = [];
  List oriCourseList = [];
  Course nowCourse = const Course(term: "", countWeek: 1, startDay: "");

  void sync() {
    EasyLoading.show(status: '同步中...\n可能需要花费一段时间');
    CourseGetor.getCourseList().then((value) {
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        msg: value['msg'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 14.0
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
            (route) => route == null
      );
      if(value['code']==1){
        logout();
      }
    });
  }

  void logout() {
    User user = Global.profile.user!;
    List<User> userList = Global.profile.userList!;
    for(int i=0; i<userList.length; i++) {
      if(userList[i].id==user.id) {
        userList[i] = user;
        Global.profile = Global.profile.copyWith(user: null, password: null, isLogin: false, lastLoginId: Optional.of(user.id), userList: Optional.of(userList));
        Global.saveProfile();
      }
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => route == null
    );
  }

  List<MyPopupMenu.PopupMenuItem> weekSelectorList() {
    List<MyPopupMenu.PopupMenuItem> list = [];
    for (int i = 1; i <= maxWeek; i++) {
      list.add(MyPopupMenu.PopupMenuItem(
        itemheight: 36,
        value: i,
        child: Text("第$i周"),
      ));
    }
    return list;
  }

  
  List<MyPopupMenu.PopupMenuItem> termSelectorList() {
    List<MyPopupMenu.PopupMenuItem> list = [];
    List? termList = user!.courseList!.termList;
    if(termList!=null) {
      for (String i in termList) {
        String sterm = i.substring(0, 9);
        if(i.substring(10)=='1') {
          sterm += '秋季';
        } else if(i.substring(10)=='2') {
          sterm += '春季';
        } else if(i.substring(10)=='3') {
          sterm += '小学期';
        }
        list.add(MyPopupMenu.PopupMenuItem(
          itemheight: 36,
          value: sterm,
          child: Text(sterm),
        ));
      }
    } else {
      list.add(const MyPopupMenu.PopupMenuItem(
        itemheight: 36,
        value: '无课表',
        child: Text('无课表'),
      ));
    }
    return list;
  }

  _alertDialog() async {
    var alertDialogs = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("关于"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: const [
                    Icon(Icons.person),
                    Text(" 作者: Freell",style: TextStyle(height: 1.2),),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.mail_outline),
                    Text(" 邮箱: xfreell@163.com",style: TextStyle(height: 1.2),),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.help),
                    Text(" 版本: 1.0.0",style: TextStyle(height: 1.2),),
                  ],
                )
            ]),
            actions: <Widget>[
              MaterialButton(
                  child: const Text("确定"),
                  onPressed: () => Navigator.pop(context)),
            ],
          );
        });
    return alertDialogs;
  }

  @override
  void initState() {
    super.initState();
    //biaoji
    realname = user!.name;
    DateTime now = DateTime.now();
    selYear = now.year;
    selMonth = now.month;
    selDay = now.day;
    selWeek = now.weekday;
    DateTime dateStart = now.subtract(Duration(days: selWeek));
    List<String> newDateList = [];
    for(int i=0;i<7;i++) {
      newDateList.add('${dateStart.month}.${dateStart.day}');
      dateStart = dateStart.add(const Duration(days: 1));
    }
    dateList = newDateList;
    CourseList? courseList = user!.courseList;
    if (courseList != null) {
      int termNum = -1;
      for(int i=0;i<courseList.termList!.length;i++) {
        DateTime courseStartDay = DateTime.parse(courseList.courseList![i].startDay);
        if(courseStartDay.isAfter(now)) {
          continue;
        } else {
          termNum = i;
          break;
        }
      }
      nowCourse = courseList.courseList![termNum];
      term = nowCourse.term;
      String sterm = nowCourse.term.substring(0, 9);
      if(nowCourse.term.substring(10)=='1') {
        sterm += '秋季';
      } else if(nowCourse.term.substring(10)=='2') {
        sterm += '春季';
      } else if(nowCourse.term.substring(10)=='3') {
        sterm += '小学期';
      }
      term = sterm;
      maxWeek = nowCourse.countWeek;
      DateTime nowStartDay = DateTime.parse(nowCourse.startDay);
      int tempWeek = now.difference(nowStartDay).inDays ~/ 7 + 1;
      if(tempWeek>maxWeek) {
        tempWeek = maxWeek;
      }
      selWeek = tempWeek;
      oriCourseList = jsonDecode(nowCourse.course![selWeek - 1]);
    }
  }

  void selectNewPage() {

  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int hour = now.hour;
    nowYear = now.year;
    nowMonth = now.month;
    nowDay = now.day;
    if(hour>=0 && hour<6) {
      goodtime = '凌晨啦';
    } else if(hour>=6 && hour<9) {
      goodtime = '早上好';
    } else if(hour>=9 && hour<12) {
      goodtime = '上午好';
    } else if(hour>=12 && hour<14) {
      goodtime = '中午好';
    } else if(hour>=14 && hour<18) {
      goodtime = '下午好';
    } else if(hour>=18 && hour<24) {
      goodtime = '晚上好';
    }
    gridWidth = (MediaQuery.of(context).size.width - 24) / 8;
    var topPadding = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        SizedBox(
          height: topPadding + 8,
          width: double.maxFinite,
        ),
        title(),
        const SizedBox(height: 8),
        weekSchedule(),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 8)
      ],
    );
  }

  Widget title() {
    return Row(
      children: [
        const SizedBox(width: 16),
        Row(
          children: [
            Text(
              '$goodtime，',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              realname.length > 4 ? realname.substring(0, 4) : realname,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF3a86ff),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        MyPopupMenu.PopupMenuButton(
            itemBuilder: (BuildContext context) => termSelectorList(),
            offset: const Offset(0, 28),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            constraints: const BoxConstraints(
              maxHeight: 36 * 4,
            ),
            onSelected: (value) {
              // biaoji
              String sterm = value.substring(0, 9);
              if(value.substring(9,11)=='秋季') {
                sterm += '-1';
              } else if(value.substring(9,11)=='春季') {
                sterm += '-2';
              } else {
                sterm += '-3';
              }
              List<Course>? courseList = user!.courseList!.courseList;
              Course tmpCourse = const Course(term: "", countWeek: 1, startDay: "");
              for(int i=0;i<courseList!.length;i++) {
                if(courseList[i].term==sterm) {
                  tmpCourse = courseList[i];
                  break;
                }
              }
              DateTime dateStart = DateTime.parse(tmpCourse.startDay);
              List<String> newDateList = [];
              for(int i=0;i<7;i++) {
                newDateList.add('${dateStart.month}.${dateStart.day}');
                dateStart = dateStart.add(const Duration(days: 1));
              }
              setState(() {
                dateList = newDateList;
                selWeek = 1;
                selectindex = 1;
                selectid = -1;
                maxWeek = tmpCourse.countWeek;
                selYear = dateStart.year;
                selMonth = dateStart.month;
                selDay = dateStart.day;
                nowCourse = tmpCourse;
                term = value;
              });
              oriCourseList = jsonDecode(nowCourse.course![selWeek - 1]);
            },
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      term,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 24,
                    ),
                  ],
                ))),
        const SizedBox(width: 8),
        MyPopupMenu.PopupMenuButton(
            itemBuilder: (BuildContext context) => <MyPopupMenu.PopupMenuItem>[
                  MyPopupMenu.PopupMenuItem(
                    itemheight: 36,
                    value: "setting",
                    child: Row(children: const [
                      Icon(
                        Icons.settings_rounded,
                        size: 20,
                      ),
                      SizedBox(width: 4,),
                      Text("设置",style: TextStyle(height: 1.2)),]),
                  ),
                  MyPopupMenu.PopupMenuItem(
                    itemheight: 36,
                    value: "sync",
                    child: Row(
                      children: const [
                        Icon(
                          Icons.sync_rounded,
                          size: 20,
                        ),
                        SizedBox(width: 4,),
                        Text("同步课程表",style: TextStyle(height: 1.2)),
                      ],
                    ),
                  ),
                  MyPopupMenu.PopupMenuItem(
                    itemheight: 36,
                    value: "logout",
                    child: Row(children: const [
                      Icon(
                        Icons.logout_rounded,
                        size: 20,
                      ),
                      SizedBox(width: 4,),
                      Text("退出登录",style: TextStyle(height: 1.2),),]),
                  ),
                  MyPopupMenu.PopupMenuItem(
                    itemheight: 36,
                    value: "about",
                    child: Row(children: const [
                      Icon(
                        Icons.info_rounded,
                        size: 20,
                      ),
                      SizedBox(width: 4,),
                      Text("关于",style: TextStyle(height: 1.2),),]),
                  ),
                ],
            offset: const Offset(0, 28),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            constraints: const BoxConstraints(
              maxHeight: 36 * 6,
            ),
            onSelected: (value) {
              if (value == 'setting') {
                Fluttertoast.showToast(
                  msg: "暂时没有设置...",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 14.0
                );
              } else if (value == 'sync') {
                sync();
              } else if (value == 'logout') {
                logout();
              } else if (value == 'about') {
                _alertDialog();
              }
            },
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(2),
                child: const Icon(
                  Icons.menu_rounded,
                  size: 24,
                ),
              )),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget weekSchedule() {
    return Flexible(
        child: Container(
            margin: const EdgeInsets.only(left: 12, right: 12),
            height: gridWidth * 13 + 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 6),
                  child: weekSelector(),
                ),
                weekArea(),
                scheduleArea(),
              ],
            ))
            ));
  }

  Widget weekSelector() {
    return Row(children: [
      Container(
        height: 30,
        padding: const EdgeInsets.only(left: 16),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if(selWeek==1) {
              Fluttertoast.showToast(
                msg: "这是第一周",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 14.0
              );
            } else {
              DateTime dateStart = DateTime.parse(nowCourse.startDay);
              dateStart = dateStart.add(Duration(days: (selWeek-2)*7));
              List<String> newDateList = [];
              for(int i=0;i<7;i++) {
                newDateList.add('${dateStart.month}.${dateStart.day}');
                dateStart = dateStart.add(const Duration(days: 1));
              }
              setState(() {
                selWeek = selWeek - 1;
                dateList = newDateList;
                selectindex = 1;
                selectid = -1;
              });
              oriCourseList = jsonDecode(nowCourse.course![selWeek - 1]);
            }
          },
          child: Row(
            children: const [
              SizedBox(width: 8,),
              Icon(
                Icons.arrow_back_ios_rounded,
                size: 16,
              ),
              Text(
                '上一周',
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(width: 8,),
            ],
          ),
        ),
      ),
      const Spacer(),
      MyPopupMenu.PopupMenuButton(
          itemBuilder: (BuildContext context) => weekSelectorList(),
          offset: const Offset(0, 28),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          constraints: const BoxConstraints(
            maxHeight: 36 * 6,
          ),
          buttonColor: Colors.white,
          onSelected: (value) {
            DateTime dateStart = DateTime.parse(nowCourse.startDay);
            dateStart = dateStart.add(Duration(days: (value-1)*7));
            List<String> newDateList = [];
            for(int i=0;i<7;i++) {
              newDateList.add('${dateStart.month}.${dateStart.day}');
              dateStart = dateStart.add(const Duration(days: 1));
            }
            setState(() {
              selWeek = value;
              dateList = newDateList;
              selectindex = 1;
              selectid = -1;
            });
            oriCourseList = jsonDecode(nowCourse.course![selWeek - 1]);
          },
          child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  const SizedBox(
                    width: 6,
                  ),
                  Text(
                    '第$selWeek周',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 24,
                  ),
                ],
              ))),
      const Spacer(),
      Container(
        height: 30,
        padding: const EdgeInsets.only(right: 16),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if(selWeek==maxWeek) {
              Fluttertoast.showToast(
                msg: "这是最后一周",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 14.0
              );
            } else {
              DateTime dateStart = DateTime.parse(nowCourse.startDay);
              dateStart = dateStart.add(Duration(days: selWeek*7));
              List<String> newDateList = [];
              for(int i=0;i<7;i++) {
                newDateList.add('${dateStart.month}.${dateStart.day}');
                dateStart = dateStart.add(const Duration(days: 1));
              }
              setState(() {
                selWeek = selWeek + 1;
                dateList = newDateList;
                selectindex = 1;
                selectid = -1;
              });
              oriCourseList = jsonDecode(nowCourse.course![selWeek - 1]);
            }
          },
          child: Row(
            children: const [
              SizedBox(width: 8,),
              Text(
                '下一周',
                style: TextStyle(fontSize: 17),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              ),
              SizedBox(width: 8,),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget weekItem(String week, String date) {
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1, color: Colors.grey.withOpacity(0.4)),
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            week,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: (nowYear==selYear && nowMonth==int.parse(date.split('.')[0]) && nowDay==int.parse(date.split('.')[1])) ? Colors.blue : Colors.black87,
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: (nowYear==selYear && nowMonth==int.parse(date.split('.')[0]) && nowDay==int.parse(date.split('.')[1])) ? Colors.blue : Colors.grey,
            ),
          ),
        ]));
  }

  List<Widget> getWeekArea() {
    List<Widget> list = [
      Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1, color: Colors.grey.withOpacity(0.4)),
          ),
        ),
        child: Text(
          "$nowMonth月",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      )
    ];
    for (var i = 0; i < 7; i++) {
      list.add(weekItem(weekList[i], dateList[i]));
    }
    return list;
  }

  Widget weekArea() {
    return GridView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        childAspectRatio: 1,
      ),
      children: getWeekArea(),
    );
  }

  Widget scheduleItem(i) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 1, color: Colors.grey.withOpacity(0.4)),
          bottom: i >= 7 * 11
              ? BorderSide.none
              : BorderSide(width: 1, color: Colors.grey.withOpacity(0.4)),
        ),
      ),
    );
  }

  List<Widget> getScheduleArea() {
    List<Widget> list = [];
    for (var i = 0; i < 7 * 12; i++) {
      list.add(scheduleItem(i));
    }
    return list;
  }

  List<Widget> getScheduleAreaEmpty() {
    List<Widget> list = [];
    for (var i = 0; i < 7 * 12; i++) {
      list.add(Container());
    }
    return list;
  }

  List<Widget> getClassArea() {
    List<Widget> list = [];
    for (var i = 0; i < 12; i++) {
      list.add(Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: i != 11
                ? BorderSide(width: 1, color: Colors.grey.withOpacity(0.4))
                : BorderSide.none,
          ),
        ),
        child: Text(
          (i + 1).toString(),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ));
    }
    return list;
  }

  List<Widget> drawCourse(List<dynamic> courses) {
    List<Widget> list = [
      InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          setState(() {
            selectid = -1;
          });
        },
        child: GridView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          children: getScheduleArea(),
        ),
      )
    ];
    var colors = [
      const Color(0xFFFFBE0B),
      const Color(0xFFFB5607),
      const Color(0xFF8338EC),
      const Color(0xFF3A86FF),
      const Color(0xFFFF006E)
    ];
    Map<String, Color> course2color = {};
    int nowcolor = 0;
    int nowid = 0;
    Color color;
    var duration = const Duration(milliseconds: 250);
    for (var i in courses) {
      for (var j in i.values) {
        if (j.isEmpty) continue;
        if (course2color.keys.contains(j[0]['course_name'])) {
          color = course2color[j[0]['course_name']]!;
        } else {
          course2color[j[0]['course_name']] = colors[nowcolor];
          color = colors[nowcolor];
          nowcolor = (nowcolor + 1) % colors.length;
        }
        int thisid = nowid;
        list.add(AnimatedPositioned(
          duration: duration,
          top: (j[0]['lessArr'][0] - 1) * gridWidth,
          left: selectid == thisid
              ? 0
              : double.parse(j[0]['weekday']) * gridWidth,
          child: InkWell(
            onTap: () {
              if (selectid == -1) {
                setState(() {
                  selectid = thisid;
                  selectindex = thisid + 1;
                });
              } else {
                setState(() {
                  selectid = -1;
                });
              }
            },
            child: AnimatedContainer(
                duration: duration,
                margin:
                    const EdgeInsets.only(left: 2, top: 1, right: 1, bottom: 1),
                width: selectid == thisid ? 7 * gridWidth - 3 : gridWidth - 3,
                height: selectid == thisid
                    ? 3 * gridWidth - 3
                    : j[0]['lessArr'].length * gridWidth - 3,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: color,
                  boxShadow: selectid == thisid
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : [],
                ),
                child: Stack(
                  children: [
                    AnimatedOpacity(
                      duration: duration,
                      opacity: selectid == thisid ? 0 : 1,
                      child: Text(
                        j[0]['location'] + '\n—\n' + j[0]['course_name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                        duration: duration,
                        opacity: selectid == thisid ? 1 : 0,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Text(
                                      j[0]['course_name'],
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              AnimatedContainer(
                                duration: duration,
                                width:
                                    selectid == thisid ? 7 * gridWidth - 32 : 0,
                                height: 1,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "上课地点：${j[0]['location']}",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "上课时间：${j[0]['course_time']}",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "上课周次：${j[0]['week']}",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "上课节次：${j[0]['lessons']}",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "课程编号：${j[0]['course_id']}",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ))
                  ],
                )),
          ),
        ));
        nowid++;
      }
    }
    if(list.length==1) {
      list.add(
        GridView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          children: getScheduleAreaEmpty(),
        )
      );
    }
    return list;
  }

  Widget scheduleArea() {
    List<Widget> nowCourseList = drawCourse(oriCourseList);
    return Expanded(
        child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Row(children: [
              Expanded(
                flex: 1,
                child: GridView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 1,
                  ),
                  children: getClassArea(),
                ),
              ),
              Expanded(
                flex: 7,
                child: Stack(children: [
                  Stack(
                    children: nowCourseList,
                  ),
                  IndexedStack(
                    index: selectindex,
                    children: nowCourseList,
                  )
                ]),
              )
            ])));
  }
}
