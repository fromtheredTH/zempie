import 'dart:convert';
import 'dart:math';

import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/pages/components/dialog.dart';
import 'package:app/pages/components/item/item_chat_msg.dart';
import 'package:app/pages/components/item/item_joined_user.dart';
import 'package:app/pages/components/item/item_user.dart';
import 'package:app/pages/components/report_dialog.dart';
import 'package:app/pages/screens/chat_add.dart';
import 'package:app/pages/screens/chat_detail.dart';
import 'package:app/pages/screens/profile/profile_screen.dart';
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
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Trans;

import '../../Constants/ImageConstants.dart';
import '../../Constants/utils.dart';
import '../../global/DioClient.dart';
import '../../models/User.dart';
import '../components/app_text.dart';

class ChatUserPage extends StatefulWidget {
  List<UserDto> userList;
  UserDto me;
  ChatRoomDto roomDto;
  Function(ChatRoomDto) changeRoom;
  ChatUserPage({Key? key, required this.userList, required this.me, required this.roomDto, required this.changeRoom}) : super(key: key);

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
      bool isExistMe = false;
      for(int i=0;i<widget.userList.length;i++){
        if(widget.userList[i].id == widget.me.id){
          isExistMe = true;
          break;
        }
      }
      if(!isExistMe)
        userList.add(widget.me);
      userList.sort((a, b) => (a.nickname ?? "").compareTo(b.nickname ?? ""));
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
    List<String> list = widget.userList.map((e) => e.nickname ?? "").toList();
    list.sort();
    String str = list.join(",");
    String name = str.substring(0, min(14, str.length));

    int cnt1 = name.split(',').length;
    int cnt2 = widget.userList.length + 1 - cnt1;
    if (cnt2 > 1) {
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
              SizedBox(
                height: 64,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Get.back();
                      },
                      child: Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(left: 10),
                          child: Center(
                            child: Image.asset(ImageConstants.backWhite, width: 24, height: 24),
                          )
                      ),
                    ),
                    SizedBox(width: 10,),
                    AppText(
                      text: "${"chat_users_title".tr()} ${widget.userList.length + 1}",
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context, SlideRightTransRoute(builder: (context) =>
                            ChatAddPage(
                              existUsers: widget.userList,
                              roomIdx: widget.roomDto.id,
                              changeRoom: (room){
                                Get.back();
                                widget.changeRoom(room);
                              },)));
                      },
                      child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Center(
                            child: Image.asset(ImageConstants.chatPlusWhite, width: 24, height: 24),
                          )),
                    ),
                    SizedBox(width: 10,)
                  ],
                ),
              ),

              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom+20),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                  onTap: () async {
                                    Utils.showDialogWidget(context);
                                    try {
                                      var response = await DioClient
                                          .getUser(userList[index].nickname ?? "");
                                      UserModel user = UserModel
                                          .fromJson(response
                                          .data["result"]["target"]);
                                      Get.back();
                                      Get.to(ProfileScreen(user: user));
                                    }catch(e){
                                      Get.back();
                                    }
                                  },
                                  child: ItemJoinedUser(
                                    info: userList[index],
                                  )
                              );
                            },
                            itemCount: userList.length
                        ),
                      )
                      ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
