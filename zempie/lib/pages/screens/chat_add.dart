import 'dart:convert';
import 'dart:math';

import 'package:app/Constants/Constants.dart';
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
import 'package:get/get.dart' hide Trans;

import '../../Constants/ColorConstants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../components/app_text.dart';

class ChatAddPage extends StatefulWidget {
  ChatAddPage({Key? key, this.existUsers, this.roomIdx, this.refresh}) : super(key: key);
  List<UserDto>? existUsers;
  int? roomIdx;
  Function()? refresh;

  @override
  ChatAddPageState createState() => ChatAddPageState();
}

class ChatAddPageState extends BaseState<ChatAddPage> {
  List<UserDto> userList = [];

  List<UserDto> recommanUserList = [];
  List<UserDto> followUserList = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  ScrollController userController = ScrollController();
  ScrollController mainController = ScrollController();
  bool hasNextPage = false;

  List<UserDto> selectList = [];
  late FocusNode _focusNode;
  bool isInit = false;
  bool isSearchingLoading = false;

  @override
  void initState() {
    super.initState();

    mainController = ScrollController()..addListener(onScroll);
    searchController.addListener(searchUser);

    getRecommandList();
    getFollowingList(gCurrentId);
    _focusNode = FocusNode();

    Future.delayed(Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void searchUser(){
    setState(() {
      userList.clear();
      if (searchController.text.isNotEmpty) {
        isSearchingLoading = true;
        getUserSearchList(searchController.text);
      } else {
        getFollowingList(gCurrentId);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();

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

  Future<void> getRecommandList() async {
    apiC
        .userRecommandList(
        "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", "", 4, 0)
        .then((value) {
      setState(() {
        print(value.result);
        recommanUserList.addAll(value.result);
      });
    }).catchError((Object obj) {
      showToast("connection_failed".tr());
    });
  }

  Future<void> getFollowingList(int userId) async {
    apiC
        .userFollowingList(
            userId, "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", 20, followUserList.length)
        .then((value) {
      setState(() {
        hasNextPage = value.pageInfo?.hasNextPage ?? false;
        followUserList.clear();
        followUserList.addAll(value.result);
        isInit = true;
      });
    }).catchError((Object obj) {
      showToast("connection_failed".tr());
    });
  }

  Future<void> getUserSearchList(String keyword) async {
    apiC.userSearchList("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", "", keyword, 10,
            userList.length).then((value) {

      if (keyword != searchController.text) return;

      setState(() {
        isSearchingLoading = false;
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

  Future<void> inviteUser() async {
    showLoading();
    Map<String, dynamic> body = {
      "room_id": widget.roomIdx,
      "user_ids": selectList.map((e) => e.id).toList()
    };

    apiC
        .userInvite("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", jsonEncode(body))
        .then((value) {
          print("${"invite".tr()} ${value.data}");
          hideLoading();
          showToast("invite_complete".tr());
          Get.back();
          if(widget.refresh != null){
            widget.refresh!();
          }
    }).catchError((Object obj) {
    });
  }

  // Future<void> getFollowingList() async {
  //
  //   apiC
  //       .getFollowingList(Constants.me?.id ?? 0,"Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}")
  //       .then((value) {
  //     print(value);
  //   }).catchError((Object obj) {
  //   });
  // }

  Future<void> newChatRoom() async {
    if (selectList.isEmpty) {
      return;
    }
    if(widget.existUsers != null){
      await inviteUser();
      return;
    }
    String name = nameController.text;

    Map<String, dynamic> body = {"receiver_ids": selectList.map((e) => e.id).toList(), "name": name};
    showLoading();
    apiC
        .createChatRoom("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", jsonEncode(body))
        .then((value) {
      hideLoading();
      print("chat room id = ${value.id}");

      Navigator.pushReplacement(
          context, SlideRightTransRoute(builder: (context) => ChatDetailPage(roomDto: value,
      roomRefresh: (room){

      },)));
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
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(left: 10),
                          child: Center(
                            child: Image.asset(
                                ImageConstants.backWhite, width: 24,
                                height: 24),
                          )
                      ),
                    ),
                    SizedBox(width: 10,),

                    Expanded(
                        child: TextField(
                          controller: nameController,
                          cursorColor: Colors.white,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: FontConstants.AppFont,
                            fontSize: 16,
                          ),
                          onEditingComplete: () => {},
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.search,
                          enabled: widget.existUsers != null || selectList.length < 2 ? false : true,
                          decoration: InputDecoration(
                              counterText: "",
                              contentPadding: EdgeInsets.zero,
                              floatingLabelBehavior: FloatingLabelBehavior
                                  .never,
                              hintText: widget.existUsers != null ? "add_room_member".tr() : selectList.length < 2 ? 'new_msg'.tr() : "new_group_msg".tr(),
                              isDense: true,
                              hintStyle: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: FontConstants.AppFont,
                                  color: widget.existUsers != null ? Colors.white : selectList.length < 2 ? Colors.white : ColorConstants.halfWhite,
                                  fontSize: 16
                              ),
                              border: InputBorder.none),
                        ),
                    )
                  ],
                ),
              ),

              Container(
                height: 65,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4)
                ),
                padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: ColorConstants.white10Percent
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(ImageConstants.chatSearchWhite, height: 24,
                          width: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          cursorColor: Colors.black,
                          focusNode: _focusNode,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontFamily: FontConstants.AppFont,
                            fontSize: 14,
                          ),
                          onEditingComplete: () => {},
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                              counterText: "",
                              contentPadding: EdgeInsets.zero,
                              floatingLabelBehavior: FloatingLabelBehavior
                                  .never,
                              hintText: 'search'.tr(),
                              isDense: true,
                              hintStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: FontConstants.AppFont,
                                  color: ColorConstants.halfWhite,
                                  fontSize: 14
                              ),
                              border: InputBorder.none),
                        ),
                      ),
                      if(searchController.text.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    searchController.text = "";
                                  });
                                },
                                child: Image.asset(
                                    ImageConstants.circleBlackX, height: 20,
                                    width: 20))
                        )
                    ],
                  ),
                ),
              ),

              selectList.length >= 1 ?
                Container(
                  height: 25,
                  margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: userController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (BuildContext context,
                                      int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if(!selectList[index].selected){
                                            selectList[index].selected = true;
                                          }else{
                                            selectList[index].selected = false;
                                            selectList.remove(selectList[index]);
                                          }
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                30),
                                            color: selectList[index].selected
                                                ? Colors.black
                                                : Color(0xffb15b00)),
                                        child: Row(
                                          children: [
                                            AppText(
                                              text: selectList[index]
                                                  .nickname ?? '샘플 닉네임',
                                              fontSize: 12,
                                            ),
                                            if(selectList[index].selected)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 4),
                                                child: Image.asset(
                                                    ImageConstants
                                                        .circleWhiteBlackX,
                                                    height: 16, width: 16),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: selectList.length),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ) : Container(),

            searchController.text.isEmpty ? Expanded(
                  child: isInit ?
                  SingleChildScrollView(
                    controller: mainController,
                    child:
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: Container(height: 0.5, color: ColorConstants.colorMain)),
                              const SizedBox(width: 20),
                              AppText(
                                text: 'add_chat_recommand'.tr(),
                                fontSize: 10,
                                color: ColorConstants.colorMain,
                              ),
                              const SizedBox(width: 20),
                              Expanded(child: Container(height:0.51, color: ColorConstants.colorMain)),
                            ],
                          ),
                        ),

                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return ItemUser(
                                info: recommanUserList[index],
                                selected: selectList.map((item) => item.id).contains(recommanUserList[index].id),
                                isDisabled: widget.existUsers?.map((item) => item.id).contains(recommanUserList[index].id) ?? false,
                                onClick: () {
                                  setState(() {
                                    if (selectList.map((user) => user.id).contains(recommanUserList[index].id)) {
                                      for(int i=0;i<selectList.length;i++){
                                        if(selectList[i].id == recommanUserList[index].id){
                                          selectList.removeAt(i);
                                          break;
                                        }
                                      }
                                    } else {
                                      selectList.add(recommanUserList[index]);
                                    }
                                  });
                                },
                              );
                            },
                            itemCount: recommanUserList.length),

                        if(followUserList.isNotEmpty)
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(child: Container(height: 0.5, color: ColorConstants.colorMain)),
                                  const SizedBox(width: 20),
                                  AppText(
                                    text: searchController.text.isEmpty ? 'add_chat_following'.tr() : "add_chat_search".tr(),
                                    fontSize: 10,
                                    color: ColorConstants.colorMain,
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(child: Container(height:0.51, color: ColorConstants.colorMain)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        followUserList.isEmpty ? Container(
                          width: double.maxFinite,
                          height: 100,
                          child: Center(
                            child: AppText(
                              text: "add_chat_following_empty".tr(),
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ) : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return ItemUser(
                                info: followUserList[index],
                                selected: selectList.map((item) => item.id).contains(followUserList[index].id),
                                isDisabled: widget.existUsers?.map((item) => item.id).contains(followUserList[index].id) ?? false,
                                onClick: () {
                                  setState(() {
                                    if (selectList.map((user) => user.id).contains(followUserList[index].id)) {
                                      for(int i=0;i<selectList.length;i++){
                                        if(selectList[i].id == followUserList[index].id){
                                          selectList.removeAt(i);
                                          break;
                                        }
                                      }
                                    } else {
                                      selectList.add(followUserList[index]);
                                    }
                                  });
                                },
                              );
                            },
                            itemCount: followUserList.length)
                      ],
                    ),
                  ) : Expanded(
                    child: Center(
                      child: SizedBox(
                        child: Center(
                            child: CircularProgressIndicator(
                                color: ColorConstants.colorMain)
                        ),
                        height: 20.0,
                        width: 20.0,
                      ),
                    ),
                  ),
              ) : Expanded(
              child: isSearchingLoading ? Center(
                child: SizedBox(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: ColorConstants.colorMain)
                  ),
                  height: 20.0,
                  width: 20.0,
                ),
              ) : userList.isNotEmpty ? ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return ItemUser(
                      info: userList[index],
                      selected: selectList.map((item) => item.id).contains(userList[index].id),
                      isDisabled: widget.existUsers?.map((item) => item.id).contains(userList[index].id) ?? false,
                      onClick: () {
                        setState(() {
                          if (selectList.map((user) => user.id).contains(userList[index].id)) {
                            for(int i=0;i<selectList.length;i++){
                              if(selectList[i].id == userList[index].id){
                                selectList.removeAt(i);
                                break;
                              }
                            }
                          } else {
                            selectList.add(userList[index]);
                          }
                        });
                      },
                    );
                  },
                  itemCount: userList.length) : Container(
                width: double.maxFinite,
                height: 100,
                child: Center(
                  child: AppText(
                    text: "add_chat_search_empty".tr(),
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

              if(selectList.length > 0)
                GestureDetector(
                  onTap: () {
                    newChatRoom();
                  },
                  child: Container(
                    width: double.maxFinite,
                    height: 47,
                    margin: EdgeInsets.all(10),
                    decoration:
                    BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: ColorConstants.colorMain
                    ),
                    child: Center(
                      child: AppText(
                        text: widget.existUsers != null ? "add_chat_user".tr(args: ["${selectList.length}"])
                            : selectList.length == 1
                            ? 'new_chat'.tr(args: ["${selectList[0].nickname}"])
                            : 'new_group_chat'.tr(
                            args: ["${selectList.length}"]),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ));
  }
}
