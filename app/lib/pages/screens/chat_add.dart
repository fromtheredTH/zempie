import 'dart:convert';
import 'dart:math';

import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/pages/components/dialog.dart';
import 'package:app/pages/components/item/item_chat_msg.dart';
import 'package:app/pages/components/item/item_user.dart';
import 'package:app/pages/components/report_dialog.dart';
import 'package:app/pages/screens/chat_detail.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:app/global/app_colors.dart';
import 'package:app/global/global.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/helpers/transition.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:app/models/dto/user_dto.dart';
import 'package:app/pages/base/base_state.dart';
import 'package:app/pages/base/page_layout.dart';
import 'package:app/pages/components/item/item_chat_room.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatAddPage extends StatefulWidget {
  const ChatAddPage({Key? key}) : super(key: key);

  @override
  ChatAddPageState createState() => ChatAddPageState();
}

class ChatAddPageState extends BaseState<ChatAddPage> {
  List<UserDto> userList = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  ScrollController userController = ScrollController();
  ScrollController mainController = ScrollController();
  bool hasNextPage = false;

  List<UserDto> selectList = [];

  @override
  void initState() {
    super.initState();

    mainController = ScrollController()..addListener(onScroll);
    getFollowingList(gCurrentId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onScroll() {
    if (!isLoading) {
      if (mainController.position.pixels == mainController.position.maxScrollExtent) {
        if (!hasNextPage) {
          return;
        }
        if (searchController.text.isEmpty) {
          getFollowingList(gCurrentId);
        } else {
          getUserSearchList(searchController.text);
        }
      }
    }
  }

  Future<void> getFollowingList(int userId) async {
    apiC
        .userFollowingList(
            userId, "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", 10, userList.length)
        .then((value) {
      setState(() {
        hasNextPage = value.pageInfo?.hasNextPage ?? false;
        userList.addAll(value.result);
      });
    }).catchError((Object obj) {
      showToast("connection_failed".tr());
    });
  }

  Future<void> getUserSearchList(String keyword) async {
    apiC
        .userSearchList("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", "", keyword, 10,
            userList.length)
        .then((value) {
      if (keyword != searchController.text) return;

      setState(() {
        hasNextPage = value.pageInfo?.hasNextPage ?? false;
        userList.addAll(value.result);
      });
    }).catchError((Object obj) {
      showToast("connection_failed".tr());
    });
  }

  Future<bool> onBackPressed() async {
    Navigator.pop(context);
    return false;
  }

  Future<void> newChatRoom() async {
    if (selectList.isEmpty) {
      return;
    }
    String name = nameController.text;
    if (name.isEmpty && selectList.length > 1) {
      //그룹방이면서 채팅방 이름 설정하지 않을 시
      // List<String> list = selectList.map((e) => e.nickname ?? '').toList();
      // list.sort();
      // String str = list.join(",");
      // name = str.substring(0, min(14, str.length));
    }

    Map<String, dynamic> body = {"receiver_ids": selectList.map((e) => e.id).toList(), "name": name};
    showLoading();
    apiC
        .createChatRoom("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", jsonEncode(body))
        .then((value) {
      hideLoading();
      print("chat room id = ${value.id}");

      Navigator.pushReplacement(
          context, SlideRightTransRoute(builder: (context) => ChatDetailPage(roomDto: value)));
    }).catchError((Object obj) {
      hideLoading();
      showToast("connection_failed".tr());
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
        onBack: onBackPressed,
        isLoading: isLoading,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Container(
                height: 64,
                child: Row(
                  children: [
                    InkWell(
                      onTap: onBackPressed,
                      child: Container(
                          width: 44,
                          height: 64,
                          margin: const EdgeInsets.only(left: 10),
                          child: Center(
                            child: Image.asset("assets/image/ic_back.png", width: 11, height: 19),
                          )),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Visibility(
                            visible: selectList.length < 2,
                            child: const Text(
                              '새 메시지',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Visibility(
                            visible: selectList.length > 1,
                            child: Container(
                              height: 51,
                              child: Center(
                                child: TextField(
                                  controller: nameController,
                                  maxLength: 14,
                                  cursorColor: Colors.black,
                                  style: const TextStyle(
                                      color: appColorText1, fontSize: 20, fontWeight: FontWeight.w700),
                                  onEditingComplete: () {},
                                  keyboardType: TextInputType.text,
                                  textAlign: TextAlign.start,
                                  textAlignVertical: TextAlignVertical.center,
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                      counterText: "",
                                      contentPadding: EdgeInsets.zero,
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      hintText: 'group_name_input'.tr(),
                                      isDense: true,
                                      hintStyle: const TextStyle(
                                          color: appColorGrey3, fontSize: 20, fontWeight: FontWeight.w700),
                                      border: InputBorder.none),
                                  onChanged: (text) {},
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: Colors.black,
              ),
              Container(
                height: 75,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: appColorGrey),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/image/ic_search.png", height: 33, width: 33),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: userController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (selectList[index].selected) {
                                            selectList[index].selected = false;
                                            selectList.remove(selectList[index]);
                                          } else {
                                            selectList[index].selected = true;
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                        margin: const EdgeInsets.only(right: 15),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(9),
                                              color: selectList[index].selected
                                                  ? appColorRed2
                                                  : appColorOrange2),
                                          child: Row(
                                            children: [
                                              Text(
                                                selectList[index].nickname ?? '',
                                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                              Visibility(
                                                visible: selectList[index].selected,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 4),
                                                  child: Image.asset("assets/image/ic_remove.png",
                                                      height: 7, width: 7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: selectList.length),
                              SizedBox(
                                width: 80,
                                height: 51,
                                child: Center(
                                  child: TextField(
                                    autofocus: true,
                                    controller: searchController,
                                    cursorColor: Colors.black,
                                    style: const TextStyle(color: appColorText1, fontSize: 14),
                                    onEditingComplete: () {
                                      hideKeyboard();
                                    },
                                    keyboardType: TextInputType.text,
                                    textAlign: TextAlign.start,
                                    textAlignVertical: TextAlignVertical.center,
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                        counterText: "",
                                        contentPadding: EdgeInsets.zero,
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        hintText: 'user_search'.tr(),
                                        isDense: true,
                                        hintStyle: TextStyle(color: appColorHint, fontSize: 14),
                                        border: InputBorder.none),
                                    onChanged: (text) {
                                      userList.clear();
                                      if (searchController.text.isNotEmpty) {
                                        getUserSearchList(searchController.text);
                                      } else {
                                        getFollowingList(gCurrentId);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: searchController.text.isNotEmpty,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    searchController.text = "";
                                  });
                                },
                                child: Image.asset("assets/image/ic_clear.png", height: 24, width: 24))),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: mainController,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return ItemUser(
                                info: userList[index],
                                selected: selectList.contains(userList[index]),
                                onClick: () {
                                  setState(() {
                                    if (selectList.contains(userList[index])) {
                                      selectList.remove(userList[index]);
                                    } else {
                                      selectList.add(userList[index]);

                                      Future.delayed(const Duration(milliseconds: 100), () {
                                        userController.animateTo(userController.position.maxScrollExtent,
                                            duration: const Duration(milliseconds: 100),
                                            curve: Curves.easeIn);
                                      });
                                    }
                                  });
                                },
                              );
                            },
                            itemCount: userList.length),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () {
                            newChatRoom();
                          },
                          child: Container(
                            width: 200,
                            height: 47,
                            decoration:
                                BoxDecoration(borderRadius: BorderRadius.circular(5), color: appColorOrange2),
                            child: Center(
                              child: Text(
                                'new_chat'.tr(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                        visible: userList.isEmpty && searchController.text.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Center(
                              child: Text(
                            "empty_search_content".tr(args: ["'${searchController.text}'"]),
                            style: const TextStyle(color: appColorText1, fontSize: 16),
                          )),
                        ))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
