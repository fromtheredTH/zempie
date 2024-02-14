import 'dart:convert';
import 'dart:math';

import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/pages/components/dialog.dart';
import 'package:app/pages/components/item/item_chat_msg.dart';
import 'package:app/pages/components/item/item_joined_user.dart';
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

class ChatUserPage extends StatefulWidget {
  List<UserDto> userList;
  UserDto me;
  ChatUserPage({Key? key, required this.userList, required this.me}) : super(key: key);

  @override
  ChatUserPageState createState() => ChatUserPageState();
}

class ChatUserPageState extends BaseState<ChatUserPage> {
  List<UserDto> userList = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      userList.addAll(widget.userList);
      userList.add(widget.me);
      userList.sort((a, b) => a.nickname!.compareTo(b.nickname!));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> onBackPressed() async {
    Navigator.pop(context);
    return false;
  }

  String makeRoomName() {
    List<String> list = widget.userList.map((e) => e.nickname!).toList();
    list.sort();
    String str = list.join(",");
    String name = str.substring(0, min(14, str.length));

    int cnt1 = name.split(',').length;
    int cnt2 = widget.userList.length + 1 - cnt1;
    if (cnt2 > 0) {
      return "$name 외 $cnt2명";
    } else {
      return name;
    }
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
                    Text(
                      makeRoomName(),
                      style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer()
                  ],
                ),
              ),
              Container(
                height: 1,
                color: Colors.black,
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return ItemJoinedUser(
                                info: userList[index],
                              );
                            },
                            itemCount: userList.length),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
