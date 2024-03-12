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

class ChatNamePage extends StatefulWidget {
  ChatRoomDto roomDto;
  ChatNamePage({Key? key, required this.roomDto}) : super(key: key);

  @override
  ChatNamePageState createState() => ChatNamePageState();
}

class ChatNamePageState extends BaseState<ChatNamePage> {
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    setState(() {
      nameController.text = (widget.roomDto.has_name ?? false) ? (widget.roomDto.name ?? '') : '';
    });
  }

  String makeRoomName() {
    List<String> list = widget.roomDto.joined_users!.map((e) => e.nickname ?? "").toList();
    list.sort();
    String str = list.join(",");
    String name = str.substring(0, min(14, str.length));

    int cnt1 = name.split(',').length;
    int cnt2 = widget.roomDto.joined_users!.length + 1 - cnt1;
    if (cnt2 > 1) {
      return "$name 외 $cnt2명";
    } else {
      return name;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> onBackPressed() async {
    Navigator.pop(context);
    return false;
  }

  Future<void> changeName() async {
    if (nameController.text.isEmpty) {
      return;
    }
    Map<String, dynamic> body = {
      "name": nameController.text,
      "room_id": widget.roomDto.id,
    };
    showLoading();
    apiC
        .changeRoomName("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", jsonEncode(body))
        .then((value) {
      hideLoading();
      print(value);

      Navigator.pop(context);
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
                    Text(
                      (widget.roomDto.has_name ?? false) ? (widget.roomDto.name ?? '') : makeRoomName(),
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
              Container(
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), border: Border.all(color: appColorText2)),
                padding: const EdgeInsets.only(left: 20, top: 12, bottom: 12, right: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        cursorColor: Colors.black,
                        style:
                            const TextStyle(color: appColorText1, fontSize: 12, fontWeight: FontWeight.w700),
                        onEditingComplete: () {},
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.done,
                        maxLength: 50,
                        decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.zero,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintText: 'group_name_input'.tr(),
                            isDense: true,
                            hintStyle: const TextStyle(
                                color: appColorGrey3, fontSize: 12, fontWeight: FontWeight.w700),
                            border: InputBorder.none),
                        onChanged: (text) {
                          setState(() {});
                        },
                      ),
                    ),
                    Visibility(
                      visible: nameController.text.isNotEmpty,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  nameController.text = "";
                                });
                              },
                              child: Image.asset("assets/image/ic_clear.png", height: 24, width: 24))),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        '${nameController.text.length}/50',
                        style:
                            const TextStyle(color: appColorText5, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    )
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  changeName();
                },
                child: Container(
                  width: 200,
                  height: 47,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: appColorOrange2),
                  child: Center(
                    child: Text(
                      'change_name'.tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
