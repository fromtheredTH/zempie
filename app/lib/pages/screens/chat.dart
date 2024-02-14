import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:app/global/app_event.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/pages/components/dialog.dart';
import 'package:app/pages/components/report_dialog.dart';
import 'package:app/pages/screens/chat_add.dart';
import 'package:app/pages/screens/chat_detail.dart';
import 'package:app/pages/screens/chat_name.dart';
import 'package:app/pages/screens/splash.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:app/global/app_colors.dart';
import 'package:app/global/global.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/helpers/transition.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:app/pages/base/base_state.dart';
import 'package:app/pages/base/page_layout.dart';
import 'package:app/pages/components/item/item_chat_room.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends BaseState<ChatPage> {
  List<ChatRoomDto> roomAllList = [];
  List<ChatRoomDto> roomFilterList = [];
  TextEditingController searchController = TextEditingController();

  ScrollController mainController = ScrollController();
  bool hasNextPage = false;

  @override
  void initState() {
    super.initState();

    mainController = ScrollController()..addListener(onScroll);
    getRoomList();
    initPush();

    ReceivePort _port = ReceivePort();
    IsolateNameServer.registerPortWithName(_port.sendPort, 'firbase_port1');
    _port.listen((dynamic data) {
      setState(() {
        ChatMsgDto msg = ChatMsgDto.fromJson(jsonDecode(data[0]));
        ChatRoomDto room = ChatRoomDto.fromJson(jsonDecode(data[1]));

        receiveMsg(room, msg);
      });
    });

    event.on<ChatProcEvent>().listen((event) {
      if (mounted) {
        openChatDetailPage(event.room);
      }
    });
    // event.on<ChatLeaveEvent>().listen((event) {
    //   if (mounted) {
    //     ChatRoomDto room = event.room;
    //     setState(() {
    //       roomAllList.removeWhere((element) => element.id == room.id);
    //       roomFilterList.removeWhere((element) => element.id == room.id);
    //     });
    //   }
    // });
    event.on<ChatReceivedEvent>().listen((event) {
      if (mounted) {
        ChatRoomDto room = event.room;
        ChatMsgDto msg = event.chat;

        receiveMsg(room, msg);
      }
    });

    event.on<ChatLeaveEvent2>().listen((event) {
      if (mounted) {
        if (gCurrentId == event.user_id) {
          setState(() {
            roomAllList.removeWhere((element) => element.id == event.room_id);
            roomFilterList.removeWhere((element) => element.id == event.room_id);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('firbase_port1');
    super.dispose();
  }

  void receiveMsg(ChatRoomDto room, ChatMsgDto msg) {
    List<ChatRoomDto> list = roomAllList.where((element) => element.id == room.id).toList();
    if (list.isNotEmpty) {
      int index = roomAllList.indexOf(list.first);
      setState(() {
        ChatRoomDto item = roomAllList[index];
        item.last_message = msg;
        roomAllList.removeAt(index);
        roomAllList.insert(0, item);
      });
    } else {
      room.last_message = msg;
      setState(() {
        roomAllList.insert(0, room);
      });
    }

    List<ChatRoomDto> list1 = roomFilterList.where((element) => element.id == room.id).toList();
    if (list1.isNotEmpty) {
      int index = roomFilterList.indexOf(list1.first);
      setState(() {
        ChatRoomDto item = roomFilterList[index];
        item.last_message = msg;
        roomFilterList.removeAt(index);
        roomFilterList.insert(0, item);
      });
    } else {
      room.last_message = msg;
      setState(() {
        roomFilterList.insert(0, room);
      });
    }

    //to get unread count
    getUpdateRoomList();
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', "");
    await prefs.setString('pwd', "");

    showLoading();
    apiC
        .delFcmToken("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", gPushKey)
        .then((value) {
      gCurrentId = 0;
      FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, SlideRightTransRoute(builder: (context) => const SplashPage()));
    }).catchError((Object obj) {});
  }

  Future<void> initPush() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Map<String, dynamic> data = initialMessage.data;
      final meta = jsonDecode(data['meta']);
      int fcmType = meta['fcmType'];
      if (fcmType == 10) {
        //dm
        int chatRoomId = meta['room']['id'];
        if (gChatRoomUid == chatRoomId) {
          //현재 입장한 채팅방의 채팅 푸시면 리턴
          return;
        }
        ChatRoomDto room = ChatRoomDto.fromJson(meta['room']);
        openChatDetailPage(room);
      }
    }
  }

  void openChatDetailPage(ChatRoomDto room) {
    Navigator.push(context, SlideRightTransRoute(builder: (context) => ChatDetailPage(roomDto: room)));
  }

  Future<bool> onBackPressed() async {
    return false;
  }

  void onScroll() {
    if (searchController.text.isNotEmpty) return;
    if (!isLoading) {
      if (mainController.position.pixels == mainController.position.maxScrollExtent) {
        if (!hasNextPage) {
          return;
        }

        getRoomList();
      }
    }
  }

  Future<void> refresh() async {
    setState(() {
      roomAllList.clear();
      roomFilterList.clear();
    });
    getRoomList();
  }

  Future<void> getUpdateRoomList() async {
    apiC
        .chatRoomList(
            "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", roomAllList.length, 0)
        .then((value) {
      if (value.updated_rooms != null) {
        if (value.updated_rooms!.isNotEmpty) {
          for (var e in value.updated_rooms!) {
            List<ChatRoomDto> list1 = roomAllList.where((element) => element.id == e.id).toList();
            List<ChatRoomDto> list2 = roomFilterList.where((element) => element.id == e.id).toList();
            setState(() {
              if (list1.isNotEmpty) {
                int index = roomAllList.indexOf(list1.first);
                roomAllList[index].last_chat_at = e.last_chat_at;
                roomAllList[index].unread_count = e.unread_count;
                roomAllList[index].unread_start_id = e.unread_start_id;
              }
              if (list2.isNotEmpty) {
                int index = roomFilterList.indexOf(list2.first);
                roomFilterList[index].last_chat_at = e.last_chat_at;
                roomFilterList[index].unread_count = e.unread_count;
                roomFilterList[index].unread_start_id = e.unread_start_id;
              }
            });
          }
        }
      }
    }).catchError((Object obj) {});
  }

  Future<void> getRoomList() async {
    // showLoading();
    apiC
        .chatRoomList(
            "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", 10, roomAllList.length)
        .then((value) {
      // hideLoading();
      setState(() {
        // roomAllList.clear();
        // roomFilterList.clear();
        hasNextPage = value.pageInfo?.hasNextPage ?? false;

        roomAllList.addAll(value.result);

        List<ChatRoomDto> list = value.result.where((element) => element.last_message != null).toList();
        roomFilterList.addAll(list);
      });
    }).catchError((Object obj) {
      // hideLoading();
      showToast("connection_failed".tr());
    });
  }

  void onSetting() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context2, setState) {
          return Wrap(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 70,
                      height: 6,
                      decoration: BoxDecoration(color: appColorGrey2, borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: 27),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context2);
                      logout();
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Center(
                        child: Text(
                          'logout'.tr(),
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  void onLeave(int index) {}

  void onDelete(int index) {}

  void onChat(int index) {
    Navigator.push(context,
            SlideRightTransRoute(builder: (context) => ChatDetailPage(roomDto: roomFilterList[index])))
        .then((value) {
      setState(() {
        roomFilterList[index].unread_count = 0;
        roomFilterList[index].unread_start_id = 0;
      });
    });
  }

  Future<void> chatRoomLeave(int index) async {
    ChatRoomDto roomDto = roomFilterList[index];

    showLoading();
    apiC
        .leaveChatRoom(roomDto.id, "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}")
        .then((value) {
      hideLoading();
      // event.fire(ChatLeaveEvent(roomDto));
    }).catchError((Object obj) {
      hideLoading();
      showToast("connection_failed".tr());
    });
  }

  Future<void> getChatRoomInfo(int index) async {
    ChatRoomDto roomDto = roomFilterList[index];

    showLoading();
    apiC
        .getChatRoomInfo(roomDto.id, "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}")
        .then((value) {
      hideLoading();
      print(value);

      setState(() {
        roomFilterList[index].has_name = true;
        roomFilterList[index].name = value.name;
      });
    }).catchError((Object obj) {
      hideLoading();
      showToast("connection_failed".tr());
    });
  }

  void onMenu(int index) {
    ChatRoomDto roomDto = roomFilterList[index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context2) {
        return StatefulBuilder(builder: (BuildContext context3, setState) {
          return Wrap(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 70,
                      height: 6,
                      decoration: BoxDecoration(color: appColorGrey2, borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: 27),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context2);
                      AppDialog.showConfirmDialog(context, "leave_title".tr(), "leave_content".tr(), () {
                        chatRoomLeave(index);
                      });
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Center(
                        child: Text(
                          'chat_leave'.tr(),
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context2);
                      AppDialog.showConfirmDialog(context, "block_title".tr(), "block_content".tr(), () {});
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Center(
                        child: Text(
                          'user_block'.tr(),
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context2);
                      showDialog(
                          context: context,
                          builder: (context4) {
                            return ReportDialog(
                              onConfirm: (reason, type) {
                                Navigator.pop(context4);
                                AppDialog.showAlertDialog(context, () {}, "report_success_title".tr(),
                                    "report_success_content".tr());
                              },
                            );
                          });
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Center(
                        child: Text(
                          'user_report'.tr(),
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: roomDto.is_group_room == 1,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context2);
                        Navigator.push(context,
                                SlideRightTransRoute(builder: (context) => ChatNamePage(roomDto: roomDto)))
                            .then((value) {
                          getChatRoomInfo(index);
                        });
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Center(
                          child: Text(
                            'change_room_name'.tr(),
                            style: const TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ],
          );
        });
      },
    );
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
                    Container(
                        width: 44,
                        height: 64,
                        margin: const EdgeInsets.only(left: 10),
                        child: Center(
                          child: Image.asset("assets/image/ic_back.png", width: 11, height: 19),
                        )),
                    Text(
                      'direct_message'.tr(),
                      style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context, SlideRightTransRoute(builder: (context) => const ChatAddPage()));
                      },
                      child: SizedBox(
                          width: 44,
                          height: 64,
                          child: Center(
                            child: Image.asset("assets/image/ic_plus.png", width: 17, height: 17),
                          )),
                    ),
                    GestureDetector(
                      onTap: onSetting,
                      child: Container(
                          width: 44,
                          height: 64,
                          margin: const EdgeInsets.only(right: 10),
                          child: Center(
                            child: Image.asset("assets/image/ic_setting.png", width: 32, height: 32),
                          )),
                    ),
                  ],
                ),
              ),
              Container(
                height: 75,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: appColorGrey),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/image/ic_search.png", height: 33, width: 33),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          cursorColor: Colors.black,
                          style: const TextStyle(color: appColorText1, fontSize: 14),
                          onEditingComplete: () => {},
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                              counterText: "",
                              contentPadding: EdgeInsets.zero,
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              hintText: 'search'.tr(),
                              isDense: true,
                              hintStyle: const TextStyle(color: appColorHint, fontSize: 14),
                              border: InputBorder.none),
                          onChanged: (text) {
                            setState(() {
                              roomFilterList.clear();
                              List<ChatRoomDto> list =
                                  roomAllList.where((element) => element.last_message != null).toList();
                              if (text.isEmpty) {
                                roomFilterList.addAll(list);
                              } else {
                                roomFilterList.addAll(list.where((element) {
                                  if (element.has_name ?? false) {
                                    return (element.name ?? '').toLowerCase().contains(text.toLowerCase());
                                  } else {
                                    List<String> list =
                                        element.joined_users!.map((e) => e.nickname!).toList();
                                    list.sort();
                                    String str = list.join(",");
                                    String name = str.substring(0, min(14, str.length));

                                    return name.toLowerCase().contains(text.toLowerCase());
                                  }
                                }).toList());
                              }
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: Stack(
                    children: [
                      Visibility(
                        visible: roomFilterList.isNotEmpty,
                        child: RefreshIndicator(
                          onRefresh: refresh,
                          child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: mainController,
                              itemBuilder: (BuildContext context, int index) {
                                return ItemChatRoom(
                                  info: roomFilterList[index],
                                  onClick: () {
                                    onChat(index);
                                  },
                                  onLongPress: () {
                                    onMenu(index);
                                  },
                                  onDelete: () {
                                    onDelete(index);
                                  },
                                );
                              },
                              itemCount: roomFilterList.length),
                        ),
                      ),
                      Visibility(
                          visible: roomFilterList.isEmpty,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Center(
                                child: Text(
                              "empty_content".tr(),
                              style: const TextStyle(color: appColorText1, fontSize: 16),
                            )),
                          ))
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
