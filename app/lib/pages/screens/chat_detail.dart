import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:app/global/app_event.dart';
import 'package:app/main.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/models/dto/file_dto.dart';
import 'package:app/models/dto/unread_dto.dart';
import 'package:app/pages/components/MyAssetPicker.dart';
import 'package:app/pages/components/dialog.dart';
import 'package:app/pages/components/item/item_chat_msg.dart';
import 'package:app/pages/components/report_dialog.dart';
import 'package:app/pages/screens/chat_name.dart';
import 'package:app/pages/screens/chat_user.dart';
import 'package:audio_session/audio_session.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/flutter_sound.dart' as fs;
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:wav/wav_file.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:app/write_log.dart';

class ChatDetailPage extends StatefulWidget {
  ChatRoomDto roomDto;

  ChatDetailPage({Key? key, required this.roomDto}) : super(key: key);

  @override
  ChatDetailPageState createState() => ChatDetailPageState();
}

class ChatDetailPageState extends BaseState<ChatDetailPage> with WidgetsBindingObserver {
  List<ChatMsgDto> msgList = [];
  AutoScrollController mainController = AutoScrollController();
  String strChatText = '';
  TextEditingController msgController = TextEditingController();
  bool hasNextPage = false;

  late ChatRoomDto roomDto;
  UserDto? me;
  bool closeRoom = false;
  int replyIdx = -1;

  //unread timer
  List<UnreadDto> unreadList = [];
  Timer? unreadTimer;

  //audio
  String? audioFilePath;
  bool _isRecording = false;
  bool _isRecordingFinish = false;

  FlutterSoundPlayer playerModule = FlutterSoundPlayer();
  FlutterSoundRecorder recorderModule = FlutterSoundRecorder();
  fs.Codec _codec = fs.Codec.pcm16WAV;
  bool? _encoderSupported = true; // Optimist

  Function? sheetSetState;
  Timer? voiceTimer;
  Duration voiceDuration = const Duration();

  //bottom toast
  double initOffset = 0.0;
  bool bPreview = false;
  bool otherMsg = false;
  int unread_start_id = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    getMe();
    gChatRoomUid = widget.roomDto.id;

    ReceivePort _port = ReceivePort();
    IsolateNameServer.registerPortWithName(_port.sendPort, 'firbase_port2');
    _port.listen((dynamic data) {
      setState(() {
        ChatMsgDto msg = ChatMsgDto.fromJson(jsonDecode(data[0]));
        ChatRoomDto room = ChatRoomDto.fromJson(jsonDecode(data[1]));

        receiveMsg(room, msg);
      });
    });

    setState(() {
      roomDto = widget.roomDto;
      unread_start_id = roomDto.unread_start_id;

      if ((roomDto.joined_users ?? []).isEmpty) {
        closeRoom = true;
      }

      if (!closeRoom) {
        startUnreadTimer();
      }
    });
    mainController = AutoScrollController()..addListener(onScroll);
    getChatList(isFirst: true);

    event.on<ChatReceivedEvent>().listen((event) {
      if (mounted) {
        ChatRoomDto room = event.room;
        ChatMsgDto msg = event.chat;

        receiveMsg(room, msg);
      }
    });

    event.on<ChatLeaveEvent2>().listen((event) {
      if (mounted) {
        if (gCurrentId == event.user_id && gChatRoomUid == event.room_id) {
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    IsolateNameServer.removePortNameMapping('firbase_port2');

    playerModule.stopPlayer();
    playerModule.closePlayer();

    unreadTimer?.cancel();
    stopRecorder();
    gChatRoomUid = 0;

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (!closeRoom) {
        startUnreadTimer();
      }
    } else {
      unreadTimer?.cancel();
    }
  }

  void receiveMsg(ChatRoomDto room, ChatMsgDto msg) {
    if (gChatRoomUid == room.id) {
      //현재 입장한 채팅방의 채팅 푸시면 추가
      setState(() {
        List<ChatMsgDto> list = msgList
            .where((e) =>
                e.id == -2 &&
                e.contents == msg.contents &&
                e.type == msg.type &&
                e.parent_id == msg.parent_id)
            .toList();
        if (list.isNotEmpty) {
          int index = msgList.indexOf(list.first);
          msgList.removeAt(index);
        }

        msgList.insert(0, msg);

        if (msg.sender_id == me?.id) {
          //내가 보낸 메시지이면
          mainController.scrollToIndex(0);
        }
      });

      if (mainController.offset > 0 && msg.sender_id != me?.id) {
        setState(() {
          otherMsg = true;
          bPreview = true;
        });
      }
      WriteLog.write("receiveMsg code complete timetime ${DateTime.now()}\n ",fileName: "receiveMsg code complete.txt");
      return;
    }
  }

  Future<void> getMe() async {
    apiP.userInfo("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}").then((value) async {
      me = value.result.user;
    }).catchError((Object obj) {});
  }

  void startUnreadTimer() {
    //Not related to the answer but you should consider resetting the timer when it starts
    unreadTimer?.cancel();
    unreadTimer = Timer.periodic(const Duration(seconds: 1), (_) => addUnreadTime());
  }

  Future<void> addUnreadTime() async {
    apiC
        .getChatUnread(roomDto.id, "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}")
        .then((value) async {
      //재그리기 방지 - 값이 변경된 unread만 가져오기
      List<UnreadDto> result1 = value.result;
      bool isChanged = false;
      for (int i = 0; i < result1.length; i++) {
        List<UnreadDto> where = unreadList.where((element) => element.user_id == result1[i].user_id).toList();
        if (where.isNotEmpty) {
          int index = unreadList.indexOf(where[0]);
          if (unreadList[index].last_read_id != result1[i].last_read_id) {
            unreadList[index].last_read_id = result1[i].last_read_id;
            isChanged = true;
          }
        } else {
          isChanged = true;
          unreadList.add(result1[i]);
        }
      }
      if (isChanged) {
        setState(() {});
      }
    }).catchError((Object obj) {});
  }

  void onScroll() {
    if (!isLoading) {
      if (mainController.position.pixels == mainController.position.maxScrollExtent) {
        if (!hasNextPage) {
          return;
        }

        getChatList();
      }
    }

    if (mainController.position.pixels > 50 &&
        msgList.isNotEmpty &&
        ((unread_start_id > 0 && initOffset > 0) || otherMsg)) {
      //재그리기 방지
      if (!bPreview) {
        setState(() {
          bPreview = true;
        });
      }
    } else {
      if (bPreview) {
        setState(() {
          bPreview = false;
          otherMsg = false;
        });
      }
    }
  }

  Future<void> getChatList({isFirst = false}) async {
    // showLoading();
    apiC
        .chatList(roomDto.id, "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}",
            isFirst ? max(roomDto.unread_count + 2, 20) : 20, msgList.length, "desc")
        .then((value) async {
      // hideLoading();
      setState(() {
        hasNextPage = value.pageInfo?.hasNextPage ?? false;
        msgList.addAll(value.result);
      });

      if (unread_start_id > 0) {
        List<ChatMsgDto> list = msgList.where((element) => element.id == unread_start_id).toList();
        if (list.isEmpty) {
          getChatList();
        } else {
          int index = msgList.indexOf(list.first);
          mainController.scrollToIndex(index + 2).then((value) {
            initOffset = mainController.offset;
            if (mainController.offset > 0) {
              setState(() {
                bPreview = true;
              });
            }
          });
        }
      }
    }).catchError((Object obj) {
      // hideLoading();
      showToast("connection_failed".tr());
    });
  }

  Future<void> onFileSend(List<FileDto> files, type) async {
    if (files.isNotEmpty) {
      addChat(files.map((e) => e.url).toList().join(","), type, replyIdx != -1 ? msgList[replyIdx].id : 0);
    }
  }

  Future<void> onTextSend() async {
    // hideKeyboard();
    if (msgController.text.isEmpty) {
      return;
    }
    String content = msgController.text;
    addChat(content, 0, replyIdx != -1 ? msgList[replyIdx].id : 0);
  }

  Future<void> addChat(String content, int type, int parent_id) async {
    if (unread_start_id != 0) {
      setState(() {
        unread_start_id = 0;
      });
    }

    setState(() {
      replyIdx = -1;
      msgController.text = "";
    });
    addFailedChat(-2, content, type, parent_id);

    Map<String, dynamic> body = {
      "contents": content,
      "receiver_ids": roomDto.joined_users?.map((e) => e.id).toList(),
      "room_id": roomDto.id,
      "type": type,
      "parent_id": parent_id,
    };
     WriteLog.sendApiTime = DateTime.now();
     WriteLog.write("api before time :  ${DateTime.now()}\n ",fileName: "api_Before.txt");
     WriteLog.write("api before time :  ${DateTime.now()}\n ",fileName: "AllInOne.txt");

    apiC
        .addChat("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", jsonEncode(body))
        .then((value) {

     
     WriteLog.apiComeTIme = DateTime.now();     
     WriteLog.write("api after time : ${DateTime.now()}\n ",fileName: "api_After.txt");
     WriteLog.write("api after time : ${DateTime.now()}\n ",fileName: "AllInOne.txt");
     WriteLog.write("api span time : ${WriteLog.TimeDifferenceApi()}\n ",fileName: "api_span.txt"); 
     WriteLog.write("api span time : ${WriteLog.TimeDifferenceApi()}\n ",fileName: "AllInOne.txt"); 

      // setState(() {
      //   replyIdx = -1;
      //   msgController.text = "";
      // });

      //이 부분 수정필요
      // List<ChatMsgDto> list = msgList
      //     .where((e) => e.id == -2 && e.contents == content && e.type == type && e.parent_id == parent_id)
      //     .toList();
      // if (list.isNotEmpty) {
      //   int index = msgList.indexOf(list.first);
      //   msgList.removeAt(index);
      // }
      // event.fire(ChatReceivedEvent(value.message, roomDto));
    }).catchError((Object obj) {
      addFailedChat(-1, content, type, parent_id);
    });
  }

  void addFailedChat(int _id, String content, int type, int parent_id) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-ddThh:mm:ss.sssZ').format(now);

    ChatMsgDto msgDto = ChatMsgDto(
        id: _id, //-1 실패, -2 전송중
        contents: content,
        room_id: roomDto.id,
        sender_id: me?.id ?? 0,
        type: type,
        parent_id: parent_id,
        created_at: formattedDate,
        sender: me,
        chat_idx: 0);

    event.fire(ChatReceivedEvent(msgDto, roomDto));
  }

  void onMenu() {
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
                        chatRoomLeave();
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
                          getChatRoomInfo();
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

  void onChatMenu(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
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
                  Visibility(
                    visible: msgList[index].type == 0,
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await Clipboard.setData(ClipboardData(text: (msgList[index].contents ?? '')));
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Center(
                          child: Text(
                            'copy'.tr(),
                            style: const TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      this.setState(() {
                        replyIdx = index;
                      });
                      Navigator.pop(context);
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Center(
                        child: Text(
                          'reply'.tr(),
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: msgList[index].sender_id == gCurrentId,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        deleteChat(index);
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Center(
                          child: Text(
                            'delete'.tr(),
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

  Future<File?> cropImage(String imagePath) async {
    CroppedFile? croppedFile = (await ImageCropper().cropImage(sourcePath: imagePath, aspectRatioPresets: [
      CropAspectRatioPreset.square,
    ], uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'image_crop'.tr(),
          toolbarColor: Colors.white,
          toolbarWidgetColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      IOSUiSettings(title: 'image_crop'.tr(), doneButtonTitle: 'done'.tr(), cancelButtonTitle: 'cancel'.tr())
    ]));
    if (croppedFile != null) {
      return File(croppedFile.path);
    } else {
      return null;
    }
  }

  void onFailedChat(int index) {
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

                      this.setState(() {
                        ChatMsgDto dto = msgList[index];
                        msgList.removeAt(index);

                        addChat(dto.contents ?? '', dto.type, dto.parent_id);
                      });
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Center(
                        child: Text(
                          'resend'.tr(),
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context2);

                      this.setState(() {
                        msgList.removeAt(index);
                      });
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Center(
                        child: Text(
                          'send_cancel'.tr(),
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

  Future<void> _onStatusRequested(PermissionStatus status) async {
    if (status != PermissionStatus.granted) {
    } else {
      List<AssetEntity>? assets = await MyAssetPicker.pickAssets(context);
      procAssets(assets);
    }
  }

  Future<void> procAssets(List<AssetEntity>? assets) async {
    if (assets != null) {
      List<File> fileList = []; //image, audio
      List<File> videoList = []; //video
      List<File> thumbList = []; //video thumbnail
      await Future.forEach<AssetEntity>(assets, (file) async {
        File? f = await file.originFile;
        if (file.type == AssetType.video) {
          videoList.add(f!);
          //thumbnail
          final fileName = await VideoThumbnail.thumbnailFile(
            video: f.path,
            thumbnailPath: (await getTemporaryDirectory()).path,
            imageFormat: ImageFormat.PNG,
            quality: 100,
          );
          if (fileName != null) {
            thumbList.add(File(fileName));
          }
        } else {
          fileList.add(f!);
        }
      });

      if (fileList.isNotEmpty) {
        showLoading();
        apiP
            .uploadFile("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", fileList)
            .then((value) {
          hideLoading();

          List<FileDto> images = value.result.where((element) => element.type == "image").toList();
          List<FileDto> audios = value.result.where((element) => element.type == "sound").toList();
          onFileSend(images, eChatType.IMAGE.index);

          for (int i = 0; i < audios.length; i++) {
            //개별적 메시지로 발송
            List<FileDto> audio = [audios[i]];
            onFileSend(audio, eChatType.AUDIO.index);
          }

          if (videoList.isNotEmpty && videoList.length == thumbList.length) {
            uploadVideo(videoList, thumbList, 0);
          }
        }).catchError((Object obj) {
          hideLoading();
          showToast("connection_failed".tr());
        });
      } else {
        if (videoList.isNotEmpty && videoList.length == thumbList.length) {
          uploadVideo(videoList, thumbList, 0);
        }
      }
    }
  }

  Future<void> uploadVideo(List<File> videoList, List<File> thumbList, int index) async {
    if (index == videoList.length) return;

    List<File> fileList = [];
    fileList.add(videoList[index]);
    fileList.add(thumbList[index]);

    showLoading();
    apiP
        .uploadFile("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", fileList)
        .then((value) {
      hideLoading();

      List<FileDto> thumbs = value.result.where((element) => element.type == "image").toList();
      List<FileDto> videos = value.result.where((element) => element.type == "video").toList();

      List<FileDto> files = [];
      if (thumbs.isNotEmpty && videos.isNotEmpty) {
        files.add(videos[0]);
        files.add(thumbs[0]);
        onFileSend(files, eChatType.VIDEO.index);
      }

      uploadVideo(videoList, thumbList, index + 1);
    }).catchError((Object obj) {
      hideLoading();
      showToast("connection_failed".tr());
    });
  }

  void onAttach() {
    if (closeRoom) return;
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
                      AssetEntity? assets = await MyAssetPicker.pickCamera(context);
                      if (assets != null) {
                        procAssets([assets]);
                      }
                      /*final image = await ImagePicker().pickImage(source: ImageSource.camera);
                      if (image == null) return;
                      var croppedImage = await cropImage(image.path);
                      if (croppedImage == null) return;

                      List<File> fileList = [];
                      fileList.add(croppedImage);

                      showLoading();
                      apiP
                          .uploadFile(
                              "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", fileList)
                          .then((value) {
                        hideLoading();

                        List<FileDto> images =
                            value.result.where((element) => element.type == "image").toList();
                        onFileSend(images, eChatType.IMAGE.index);
                      }).catchError((Object obj) {
                        hideLoading();
                        showToast("connection_failed".tr());
                      });*/
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Center(
                        child: Text(
                          'camera'.tr(),
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context2);

                      if (Platform.isAndroid) {
                        final androidInfo = await DeviceInfoPlugin().androidInfo;
                        if (androidInfo.version.sdkInt <= 32) {
                          Permission.storage.request().then(_onStatusRequested);
                        } else {
                          Permission.photos.request().then(_onStatusRequested);
                        }
                      } else if (Platform.isIOS) {
                        Permission.photos.request().then(_onStatusRequested);
                      }
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Center(
                        child: Text(
                          'gallery'.tr(),
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context2);

                      onVoiceMsg();
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Center(
                        child: Text(
                          'voice_msg'.tr(),
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

  Future<bool> onBackPressed() async {
    Navigator.pop(context);
    return false;
  }

  Future<void> chatRoomLeave() async {
    showLoading();
    apiC
        .leaveChatRoom(roomDto.id, "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}")
        .then((value) {
      hideLoading();
      // event.fire(ChatLeaveEvent(roomDto));
      // Navigator.pop(context);
    }).catchError((Object obj) {
      hideLoading();
      showToast("connection_failed".tr());
    });
  }

  Future<void> getChatRoomInfo() async {
    showLoading();
    apiC
        .getChatRoomInfo(roomDto.id, "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}")
        .then((value) {
      hideLoading();
      print(value);

      setState(() {
        roomDto.has_name = true;
        roomDto.name = value.name;
      });
    }).catchError((Object obj) {
      hideLoading();
      showToast("connection_failed".tr());
    });
  }

  Future<void> deleteChat(int index) async {
    showLoading();
    apiC
        .deleteChat(msgList[index].id, "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}")
        .then((value) {
      hideLoading();
      print(value);

      setState(() {
        msgList[index].type = 0;
        msgList[index].chat_idx = -1;
      });
    }).catchError((Object obj) {
      hideLoading();
      showToast("connection_failed".tr());
    });
  }

  void startVoiceTimer() {
    //Not related to the answer but you should consider resetting the timer when it starts
    voiceTimer?.cancel();
    voiceDuration = const Duration();
    voiceTimer = Timer.periodic(const Duration(milliseconds: 500), (_) => addVoiceTime());
  }

  void addVoiceTime() {
    sheetSetState?.call(() {
      final ms = voiceDuration.inMilliseconds + 500;
      voiceDuration = Duration(milliseconds: ms);
    });
  }

  void onVoiceMsg() {
    voiceDuration = const Duration();
    _isRecording = false;
    _isRecordingFinish = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context2, StateSetter setState) {
          sheetSetState = setState;
          return PopScope(
            canPop: false,
            child: Wrap(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 70,
                        height: 6,
                        decoration:
                            BoxDecoration(color: appColorGrey2, borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'voice_msg'.tr(),
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25), border: Border.all(color: appColorOrange)),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 110,
                            child: DotsIndicator(
                              dotsCount: (MediaQuery.of(context).size.width - 350) / 40 < 0 ? 15 : 12,
                              position: (voiceDuration.inMilliseconds ~/ 500) %
                                  ((MediaQuery.of(context).size.width - 350) / 40 < 0 ? 15 : 12),
                              decorator: DotsDecorator(
                                size: const Size(12, 3),
                                activeSize: const Size(12, 3),
                                color: Colors.black,
                                activeColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                                activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                                spacing: (MediaQuery.of(context).size.width - 350) / 40 < 0
                                    ? EdgeInsets.all((MediaQuery.of(context).size.width - 290) / 30)
                                    : EdgeInsets.all((MediaQuery.of(context).size.width - 254) / 24),
                              ),
                            ),
                          ),
                          Container(
                            width: 50,
                            margin: const EdgeInsets.only(left: 8),
                            child: Text(
                              "${pad2(voiceDuration.inMinutes.remainder(60))}:${pad2((voiceDuration.inSeconds.remainder(60)))}",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: voiceDuration.inMilliseconds > 0 ? Colors.black : appColorGrey6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Stack(
                      children: [
                        Positioned(
                          left: 10,
                          child: GestureDetector(
                            onTap: () {
                              stopRecorder();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'cancel'.tr(),
                              style: const TextStyle(fontSize: 20, color: Colors.black),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_isRecordingFinish) {
                              //refresh
                              sheetSetState?.call(() {
                                voiceDuration = const Duration();
                                _isRecording = false;
                                _isRecordingFinish = false;
                                audioFilePath = null;
                              });
                            } else {
                              if (voiceDuration.inMilliseconds > 0) {
                                stopRecorder();
                              } else {
                                openTheRecorder();
                              }
                            }
                          },
                          child: Center(
                            child: Image.asset(
                                _isRecordingFinish
                                    ? 'assets/image/ic_refresh.png'
                                    : voiceDuration.inMilliseconds > 0
                                        ? 'assets/image/ic_record_stop.png'
                                        : 'assets/image/ic_record_start.png',
                                width: 30,
                                height: 30),
                          ),
                        ),
                        Visibility(
                          visible: _isRecordingFinish,
                          child: Positioned(
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                uploadAudio();
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 50,
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(19), color: appColorOrange4),
                                child: Center(
                                  child: Image.asset("assets/image/ic_send.png", width: 20, height: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // audio
  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await recorderModule.openRecorder();

    _encoderSupported = await recorderModule.isEncoderSupported(_codec);

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth | AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    if (!_encoderSupported!) return;
    startRecorder();
  }

  void startRecorder() async {
    try {
      // Request Microphone permission if needed
      if (!kIsWeb) {
        var status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          throw RecordingPermissionException('Microphone permission not granted');
        }
      }
      var path = '';
      if (!kIsWeb) {
        var tempDir = await getTemporaryDirectory();
        path = '${tempDir.path}/flutter_sound${ext[_codec.index]}';
      } else {
        path = '_flutter_sound${ext[_codec.index]}';
      }

      await recorderModule.startRecorder(
        toFile: path,
        codec: _codec,
        bitRate: 8000,
        numChannels: 1,
        sampleRate: 8000,
      );
      recorderModule.logger.d('startRecorder');
      recorderModule.logger.d('audioFilePath=$path');

      audioFilePath = path;

      sheetSetState?.call(() {
        _isRecording = true;
        _isRecordingFinish = false;
      });
      startVoiceTimer();
    } on Exception catch (err) {
      recorderModule.logger.e('startRecorder error: $err');
      setState(() {
        stopRecorder();
      });
    }
  }

  void stopRecorder() async {
    try {
      await recorderModule.stopRecorder();
      recorderModule.logger.d('stopRecorder');
    } on Exception catch (err) {
      recorderModule.logger.d('stopRecorder error: $err');
    }

    voiceTimer?.cancel();
    sheetSetState?.call(() {
      _isRecording = false;
      _isRecordingFinish = true;
    });

    // change audio file type : stream -> wav
    if (audioFilePath == null) return;
    final wav = await Wav.readFile(audioFilePath!);
    print(wav.format);
    print(wav.samplesPerSecond);

    var path = '';
    if (!kIsWeb) {
      var tempDir = await getTemporaryDirectory();
      path = '${tempDir.path}/tmp${ext[_codec.index]}';
    } else {
      path = '_tmp${ext[_codec.index]}';
    }
    await wav.writeFile(path);
    audioFilePath = path;

    // play audio
    // if (audioFilePath != null) {
    //   await playerModule.openPlayer();
    //   await playerModule.startPlayer(
    //       fromURI: audioFilePath, codec: _codec, sampleRate: 44000, whenFinished: () {});
    // }
  }

  Future<void> uploadAudio() async {
    if (audioFilePath == null) return;

    List<File> fileList = [];
    fileList.add(File(audioFilePath!));

    showLoading();
    apiP
        .uploadFile("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", fileList)
        .then((value) {
      hideLoading();

      List<FileDto> audios = value.result.where((element) => element.type == "sound").toList();
      onFileSend(audios, eChatType.AUDIO.index);
    }).catchError((Object obj) {
      hideLoading();
      showToast("connection_failed".tr());
    });
  }

  Future<bool> onHide() async {
    hideKeyboard();
    return false;
  }

  String makeRoomName() {
    List<String> list = roomDto.joined_users!.map((e) => e.nickname!).toList();
    list.sort();
    String str = list.join(",");
    String name = str.substring(0, min(14, str.length));

    int cnt1 = name.split(',').length;
    int cnt2 = roomDto.joined_users!.length + 1 - cnt1;
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
        onTap: onHide,
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
                    GestureDetector(
                      onTap: () {
                        if (closeRoom) return;
                        Navigator.push(
                            context,
                            SlideRightTransRoute(
                                builder: (context) =>
                                    ChatUserPage(userList: roomDto.joined_users!, me: me!)));
                      },
                      child: Text(
                        closeRoom
                            ? 'unknown'.tr()
                            : (roomDto.has_name ?? false)
                                ? (roomDto.name ?? '')
                                : makeRoomName(),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: onMenu,
                      child: Container(
                          width: 44,
                          height: 64,
                          margin: EdgeInsets.only(right: 10),
                          child: Center(
                            child: Image.asset("assets/image/ic_menu.png", width: 27, height: 6),
                          )),
                    ),
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
                    ListView.builder(
                      padding: const EdgeInsets.all(20),
                      controller: mainController,
                      itemCount: msgList.length,
                      reverse: true,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        print('testtest itemchatmsg index : ${index}');
                              WriteLog.write("itemchatmsg index ${index} t : ${DateTime.now()}",fileName: "itemchatmsg.txt");

                        return AutoScrollTag(
                          key: ValueKey(index),
                          controller: mainController,
                          index: index,
                          child: ItemChatMsg(
                              users: roomDto.joined_users!,
                              info: msgList[index],
                              unread: unreadList,
                              before: index == msgList.length - 1 ? null : msgList[index + 1],
                              next: index == 0 ? null : msgList[index - 1],
                              parentNick: parentChatNick(
                                  roomDto.joined_users!, me, msgList, msgList[index].parent_chat?.id ?? 0),
                              bNewMsg: msgList[index].id == unread_start_id,
                              playerModule:
                                  msgList[index].type != eChatType.AUDIO.index ? null : playerModule,
                              setState: () {
                                setState(() {});
                              },
                              onProfile: () {},
                              onDelete: () {
                                if (msgList[index].id == -1) return;
                                deleteChat(index);
                              },
                              onTap: () {
                                if (msgList[index].id == -1) {
                                  onFailedChat(index);
                                  return;
                                }
                                if (msgList[index].parent_id > 0) {
                                  List<ChatMsgDto> list = msgList
                                      .where((element) => element.id == msgList[index].parent_id)
                                      .toList();
                                  if (list.isNotEmpty) {
                                    mainController.scrollToIndex(msgList.indexOf(list.first));
                                  }
                                }
                              },
                              onReply: () {
                                if (msgList[index].id == -1) return;
                                setState(() {
                                  replyIdx = index;
                                });
                              },
                              onLongPress: () {
                                if (msgList[index].id == -1) return;
                                onChatMenu(index);
                              }),
                        );
                      },
                    ),
                    if (bPreview)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: () {
                              mainController.scrollToIndex(0);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: appColorGrey4)),
                              child: Row(
                                children: [
                                  (msgList.first.sender?.picture ?? '').isEmpty
                                      ? Image.asset("assets/image/ic_default_user.png", height: 42, width: 42)
                                      : ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: msgList.first.sender?.picture ?? '',
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => CircularProgressIndicator(),
                                            errorWidget: (context, url, error) => Image.asset(
                                                "assets/image/ic_default_user.png",
                                                height: 42,
                                                width: 42),
                                            width: 42,
                                            height: 42,
                                          ),
                                        ),
                                  const SizedBox(width: 10),
                                  Text(
                                    msgList.first.sender?.nickname ?? '',
                                    style: const TextStyle(color: appColorText4, fontSize: 12),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      chatContent(msgList.first.contents ?? '', msgList.first.type ?? 0),
                                      style: const TextStyle(color: Colors.black, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (replyIdx != -1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${msgList[replyIdx].sender?.nickname}님에게 답장 보내는중',
                                style: const TextStyle(fontSize: 14, color: Colors.black)),
                            Text(chatContent(msgList[replyIdx].contents ?? '', msgList[replyIdx].type),
                                style: const TextStyle(fontSize: 14, color: appColorText6)),
                          ],
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              replyIdx = -1;
                            });
                          },
                          child: Image.asset('assets/image/ic_close.png', width: 24, height: 24))
                    ],
                  ),
                ),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: closeRoom ? appColorGrey6 : appColorOrange),
                    ),
                    width: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(width: 7),
                        InkWell(
                          onTap: onAttach,
                          child: Container(
                            width: 35,
                            height: 35,
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Center(
                              child: Image.asset(
                                closeRoom ? "assets/image/ic_add_disable.png" : "assets/image/ic_add.png",
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            maxLines: 5,
                            minLines: 1,
                            enabled: !closeRoom,
                            style: const TextStyle(color: appColorText4, fontSize: 14),
                            controller: msgController,
                            decoration: InputDecoration(
                                counterText: "",
                                hintText: closeRoom ? "disable_chat".tr() : "input_msg".tr(),
                                hintStyle: const TextStyle(color: appColorHint, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12)),
                            onChanged: (text) {
                              setState(() {
                                strChatText = text;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Visibility(
                          visible: msgController.text.isNotEmpty,
                          child: InkWell(
                            onTap: onTextSend,
                            child: Container(
                              width: 50,
                              height: 30,
                              margin: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(19), color: appColorOrange1),
                              child: Center(
                                child: Image.asset("assets/image/ic_send.png", width: 20, height: 20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        ));
  }
}
