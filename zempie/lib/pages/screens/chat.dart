import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:app/Constants/ColorConstants.dart';
import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/FontConstants.dart';
import 'package:app/global/app_event.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/models/res/btn_bottom_sheet_model.dart';
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
import 'package:get/get.dart' hide Trans;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants/ImageConstants.dart';
import '../../utils/ChatRoomUtils.dart';
import '../components/BtnBottomSheetWidget.dart';
import '../components/EditRoomNameBottomSheet.dart';
import '../components/app_text.dart';

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
  int nextPage = 0;

  bool isInit = false;

  @override
  void initState() {
    super.initState();

    mainController = ScrollController()..addListener(onScroll);

    setState(() {
      roomAllList = Constants.localChatRooms;
      if(roomAllList.isNotEmpty){
        isInit = true;
      }
      roomFilterList = roomAllList;
    });
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
            ChatRoomUtils.deleteChatRoomFromId(event.room_id);
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
        ChatRoomUtils.saveChatRoom(item);
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
    Navigator.push(context, SlideRightTransRoute(builder: (context) => ChatDetailPage(roomDto: room,
      roomRefresh: (room){
      for(int i=0;i<roomFilterList.length;i++){
        if(roomFilterList[i].id == room.id){
          getChatRoomInfo(i);
        }
      }
    },)));
  }

  Future<bool> onBackPressed() async {
    Get.back();
    return true;
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
    nextPage = 0;
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
                ChatRoomUtils.saveChatRoom(roomAllList[index]);
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
            "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", 10, nextPage)
        .then((value) async {
      // hideLoading();
      await ChatRoomUtils.saveMultiChatRoom(value.result);
      List<ChatRoomDto> localDto = await ChatRoomUtils.getChatRooms();
      setState(() {
        // roomAllList.clear();
        // roomFilterList.clear();

        hasNextPage = value.pageInfo?.hasNextPage ?? false;
        nextPage += 1;
        roomAllList = localDto;
        isInit = true;
        setFilteringList();
      });
    }).catchError((Object obj) {
      // hideLoading();
      showToast("connection_failed".tr());
    });
  }

  void onLeave(int index) {}

  void onDelete(int index) {}

  void onChat(int index) {
    Navigator.push(context,
            SlideRightTransRoute(builder: (context) => ChatDetailPage(roomDto: roomFilterList[index],
            roomRefresh: (room){
              getChatRoomInfo(index);
            },)))
        .then((value) {
      setState(() {
        roomFilterList[index].unread_count = 0;
        roomFilterList[index].unread_start_id = 0;
      });
    });
  }

  void setFilteringList() {
    roomFilterList.clear();
    if (searchController.text.isEmpty) {
      roomFilterList.addAll(roomAllList);
    } else {
      List<ChatRoomDto> list = roomAllList.where((element) =>
      element.last_message != null).toList();
      roomFilterList.addAll(list.where((element) {
        if (element.has_name ?? false) {
          return (element.name ?? '').toLowerCase().contains(
              searchController.text.toLowerCase());
        } else {
          List<String> list =
          element.joined_users!.map((e) => e.nickname ?? "").toList();
          list.sort();
          String str = list.join(",");
          String name = str.substring(0, min(14, str.length));

          return name.toLowerCase().contains(
              searchController.text.toLowerCase());
        }
      }).toList());
    }
  }

  Future<void> chatRoomLeave(ChatRoomDto roomDto) async {

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
        roomFilterList[index] = value;
        for(int i=0;i<(roomFilterList[index].joined_users?.length ?? 0);i++){
          if(roomFilterList[index].joined_users![i].id == Constants.user.id){
            roomFilterList[index].joined_users!.removeAt(i);
            break;
          }
        }
        for(int i=0;i<roomAllList.length;i++){
          if(roomFilterList[index].id == roomAllList[i].id){
            roomAllList[i] = roomFilterList[index];
            break;
          }
        }
        ChatRoomUtils.saveChatRoom(roomFilterList[index]);
      });
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 64,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        onBackPressed();
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
                      text: 'direct_message'.tr(),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context, SlideRightTransRoute(builder: (context) => ChatAddPage()));
                      },
                      child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Center(
                            child: Image.asset(ImageConstants.chatPlusWhite, width: 24, height: 24),
                          )),
                    ),
                    SizedBox(width: 15,),

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
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
                      color: ColorConstants.white10Percent
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(ImageConstants.chatSearchWhite, height: 24, width: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          cursorColor: Colors.black,
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
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              hintText: 'search'.tr(),
                              isDense: true,
                              hintStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: FontConstants.AppFont,
                                  color: ColorConstants.halfWhite,
                                  fontSize: 14
                              ),
                              border: InputBorder.none),
                          onChanged: (text) {
                            setState(() {
                              setFilteringList();
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              isInit ?
              Expanded(
                child: Container(
                  color: ColorConstants.colorBg1,
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
                                    ChatRoomDto roomDto = roomFilterList[index];
                                    List<BtnBottomSheetModel> items = [];
                                    if((roomDto.joined_users?.length ?? 0) >= 1)
                                      items.add(BtnBottomSheetModel(ImageConstants.addChatUserIcon, "add_room_member".tr(), 0));
                                    if((roomDto.joined_users?.length ?? 0) >= 1)
                                      items.add(BtnBottomSheetModel(ImageConstants.editRoomIcon, "change_room_name".tr(), 1));
                                    if((roomDto.joined_users?.length ?? 0) == 1)
                                      items.add(BtnBottomSheetModel(ImageConstants.banUserIcon, "user_block".tr(), 2));
                                    if((roomDto.joined_users?.length ?? 0) == 1)
                                      items.add(BtnBottomSheetModel(ImageConstants.reportUserIcon, "report_title".tr(), 3));
                                    items.add(BtnBottomSheetModel(ImageConstants.exitRoomIcon, "chat_leave".tr(), 4));
                                    Get.bottomSheet(BtnBottomSheetWidget(
                                      btnItems: items,
                                      onTapItem: (menuIndex){
                                        if(menuIndex == 0){
                                          Navigator.push(context, SlideRightTransRoute(builder: (context) => ChatAddPage(existUsers: roomDto.joined_users ?? [], roomIdx: roomDto.id,
                                          refresh: (){
                                            getChatRoomInfo(index);
                                          },)));
                                        }else if(menuIndex == 1){
                                          Get.bottomSheet(EditRoomNameBottomSheet(
                                            roomDto: roomDto,
                                            inputName: (name) async {
                                              if (name.isEmpty) {
                                                return;
                                              }
                                              Map<String, dynamic> body = {
                                                "name": name,
                                                "room_id": roomDto.id,
                                              };
                                              showLoading();
                                              apiC
                                                  .changeRoomName("Bearer ${await FirebaseAuth
                                                  .instance.currentUser?.getIdToken()}",
                                              jsonEncode(body))
                                                  .then((value) {
                                                hideLoading();
                                                setState(() {
                                                  List<ChatRoomDto> list = roomAllList.where((element) => element.id == roomDto.id).toList();
                                                  if (list.isNotEmpty) {
                                                    int index = roomAllList.indexOf(list.first);
                                                    ChatRoomDto item = roomAllList[index];
                                                    item.name = name;
                                                    item.has_name = true;
                                                    roomAllList.removeAt(index);
                                                    roomAllList.insert(index, item);
                                                    ChatRoomUtils.saveChatRoom(item);
                                                  }

                                                  List<ChatRoomDto> list1 = roomFilterList.where((element) => element.id == roomDto.id).toList();
                                                  if (list1.isNotEmpty) {
                                                    int index = roomFilterList.indexOf(list1.first);
                                                    ChatRoomDto item = roomFilterList[index];
                                                    item.name = name;
                                                    item.has_name = true;
                                                    roomFilterList.removeAt(index);
                                                    roomFilterList.insert(index, item);
                                                  }
                                                });
                                              }).catchError((Object obj) {
                                                hideLoading();
                                                showToast("connection_failed".tr());
                                              });
                                            },
                                          ));
                                        }else if(menuIndex == 2){
                                          AppDialog.showConfirmDialog(context, "block_title".tr(), "block_content".tr(), () {});
                                        }else if(menuIndex == 3){
                                          AppDialog.showAlertDialog(context, () {}, "report_success_title".tr(),
                                              "report_success_content".tr());
                                        }else {
                                          AppDialog.showConfirmDialog(context, "leave_title".tr(), "leave_content".tr(), () {
                                            chatRoomLeave(roomDto);
                                          });
                                        }
                                      },
                                    ));
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
            ],
          ),
        )
    );
  }
}
