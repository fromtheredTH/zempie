import 'dart:async';
import 'dart:convert' hide Codec;
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui' hide Codec;

import 'package:app/pages/screens/profile/profile_screen.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:app/Constants/ColorConstants.dart';
import 'package:app/Constants/FontConstants.dart';
import 'package:app/Constants/ImageConstants.dart';
import 'package:app/global/app_event.dart';
import 'package:app/main.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:app/models/dto/file_dto.dart';
import 'package:app/models/dto/unread_dto.dart';
import 'package:app/pages/components/MyAssetPicker.dart';
import 'package:app/pages/components/dialog.dart';
import 'package:app/pages/components/item/TagCreator.dart';
import 'package:app/pages/components/item/TagDev.dart';
import 'package:app/pages/components/item/item_chat_msg.dart';
import 'package:app/pages/components/item/item_user_name.dart';
import 'package:app/pages/components/report_dialog.dart';
import 'package:app/pages/screens/chat_add.dart';
import 'package:app/pages/screens/chat_name.dart';
import 'package:app/pages/screens/chat_user.dart';
import 'package:app/utils/ChatRoomUtils.dart';
import 'package:app/utils/ChatUtils.dart';
import 'package:audio_session/audio_session.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:app/global/app_colors.dart';
import 'package:app/global/global.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/helpers/transition.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:app/models/dto/user_dto.dart';
import 'package:app/pages/base/base_state.dart';
import 'package:app/pages/base/page_layout.dart';
import 'package:app/pages/components/item/item_chat_room.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/flutter_sound.dart' as fs;
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart' hide Trans;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:swipe/swipe.dart';
import 'package:swipe_plus/swipe_plus.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:wav/wav_file.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:app/write_log.dart';

import '../../Constants/Constants.dart';
import '../../Constants/ImageUtils.dart';
import '../../Constants/utils.dart';
import '../../global/DioClient.dart';
import '../../models/User.dart';
import '../../models/res/btn_bottom_sheet_model.dart';
import '../components/BtnBottomSheetWidget.dart';
import '../components/EditRoomNameBottomSheet.dart';
import '../components/GalleryBottomSheet.dart';
import '../components/app_text.dart';
import '../components/item/PositionRetainedScrollPhysics.dart';
import '../components/report_user_dialog.dart';

class ChatDetailPage extends StatefulWidget {
  ChatRoomDto roomDto;

  ChatDetailPage({Key? key, required this.roomDto, required this.roomRefresh, required this.changeRoom, required this.onDeleteRoom}) : super(key: key);
  Function(ChatRoomDto) roomRefresh;
  Function(ChatRoomDto) changeRoom;
  Function(ChatRoomDto) onDeleteRoom;

  @override
  ChatDetailPageState createState() => ChatDetailPageState();
}

class ChatDetailPageState extends BaseState<ChatDetailPage> with WidgetsBindingObserver {
  List<ChatMsgDto> msgList = [];
  AutoScrollController mainController = AutoScrollController();
  // String strChatText = '';
  TextEditingController msgController = TextEditingController();
  RxString sendString = "".obs;
  String tempString = "";
  bool hasNextPage = false;

  late ChatRoomDto roomDto;
  UserDto? me;
  bool closeRoom = false;
  int replyIdx = -1;

  bool isInit = false;

  //unread timer
  List<UnreadDto> unreadList = [];
  Timer? unreadTimer;

  //audio
  String? audioFilePath;
  RxBool _isRecording = false.obs;
  RxBool _isRecordLock = false.obs;
  bool _isRecordCancel = false;
  Offset? micFirstX;
  RxDouble? changedX;
  RxDouble? changedY;
  RxDouble? lockX;
  RxDouble? lockY;
  bool _isRecordingFinish = false;

  FlutterSoundPlayer playerModule = FlutterSoundPlayer();
  FlutterSoundRecorder recorderModule = FlutterSoundRecorder();
  fs.Codec _codec = fs.Codec.pcm16WAV;
  bool? _encoderSupported = true; // Optimist
  bool shouldRemain = false;

  Function? sheetSetState;
  Timer? voiceTimer;
  Duration voiceDuration = const Duration();
  RxString durationString = "00:00:00".obs;

  //bottom toast
  double initOffset = 0.0;
  bool bPreview = false;
  bool otherMsg = false;
  int unread_start_id = 0;

  FocusNode myFocusNode = FocusNode();
  bool isMicPermission = false;

  PositionRetainedScrollPhysics physics = PositionRetainedScrollPhysics();

  Future<void> initChatMsgs() async {
    List<ChatMsgDto> result = await ChatUtils.getChats(widget.roomDto.id);
    setState(() {
      msgList = result;
      if(result.length != 0){
        isInit = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    me = UserDto.fromJson(Constants.user.toJson());
    Permission.microphone.status.then((value) {
      isMicPermission = value.isGranted;
    });

    // getMe();
    initChatMsgs();
    gChatRoomUid = widget.roomDto.id;

    ReceivePort _port = ReceivePort();
    IsolateNameServer.registerPortWithName(_port.sendPort, 'firbase_port2');
    _port.listen((dynamic data) async {
      print("몬가 들어오나? ${data}");
      ChatMsgDto msg = ChatMsgDto.fromJson(jsonDecode(data[0]));
      ChatRoomDto room = ChatRoomDto.fromJson(jsonDecode(data[1]));

      try {
        if (msg.type == eChatType.AUDIO.index) {
          await playerModule?.closePlayer();
          await playerModule?.openPlayer();

          Duration duration = await playerModule?.startPlayer(
              fromURI: msg.contents ?? '',
              codec: Codec.pcm16WAV,
              sampleRate: 44000,
              whenFinished: () {}) ??
              const Duration();
          int audioTime = duration.inSeconds;
          await playerModule?.stopPlayer();
          await playerModule?.closePlayer();
          msg.audioTime = audioTime;
        }
      }catch(e){
        print("에러 발생");
        print(e);
      }
      setState(() {

        print("어디 1");
        receiveMsg(room, msg);
        if(room.id != -2) {
          ChatUtils.saveChat(room.id, msg);
          ChatRoomUtils.saveChatRoom(room);
        }
      });
    });

    roomDto = widget.roomDto;
    unread_start_id = roomDto.unread_start_id;

    if ((roomDto.joined_users ?? []).isEmpty) {
      closeRoom = true;
    }

    if (!closeRoom) {
      startUnreadTimer();
    }
    mainController = AutoScrollController()..addListener(onScroll);
    getChatList(isFirst: true);

    event.on<ChatReceivedEvent>().listen((event) async {
      print("챗 리시브");
      if (mounted) {
        ChatRoomDto room = event.room;
        ChatMsgDto msg = event.chat;

        print("받은 메세지 ${event}");
        try {
          if (msg.type == eChatType.AUDIO.index) {
            print("서버 푸쉬로 부터 받은 값 ${msg.contents}");
            // return;
            await playerModule?.closePlayer();
            await playerModule?.openPlayer();

            Duration duration = await playerModule?.startPlayer(
                fromURI: msg.contents ?? '',
                codec: Codec.pcm16WAV,
                sampleRate: 44000,
                whenFinished: () {}) ??
                const Duration();
            int audioTime = duration.inSeconds;
            await playerModule?.stopPlayer();
            await playerModule?.closePlayer();
            msg.audioTime = audioTime;
            print("오디오 완료 ${audioTime}");
          }
        }catch(e){
          print("에러 발생");
          print(e);
        }
        print("스크롤");
        double max = mainController.position.maxScrollExtent;
        if(mainController.offset != 0 && msg.sender_id != me!.id)
          PositionRetainedScrollPhysics.shouldRetain = true;
        receiveMsg(room, msg);

        if(room.id != -1 && msg.id != -2){
          ChatUtils.saveChat(room.id, msg);
          ChatRoomUtils.saveChatRoom(room);
        }
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
    // stopRecorder();
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
      print("콘텐츠 추가22 ${msg.id} ${msg.contents}");
      setState(() {
        List<ChatMsgDto> list = msgList
            .where((e) =>
        (e.id == -2 || e.id == msg.id) &&
                e.contents == msg.contents &&
                e.type == msg.type &&
                e.parent_id == msg.parent_id)
            .toList();
        if (list.isNotEmpty) {
          int index = msgList.indexOf(list.first);
          msgList.removeAt(index);
          msgList.insert(index, msg);
        }else{
          msgList.insert(0, msg);
        }

        print("채팅 오브젝트에 추가 ${DateTime.now()}");

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
      return;
    }
  }

  Future<void> getMe() async {
    apiP.userInfo("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}").then((value) async {
      me = value.data["result"]["user"];
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
        // setState(() {
          // bPreview = true;
        // });
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
      hasNextPage = value.pageInfo?.hasNextPage ?? false;
      print(value.result.length);
      await ChatUtils.saveMultiChats(roomDto.id, value.result);
      List<ChatMsgDto> lists = await ChatUtils.getChats(roomDto.id);
      setState(() {

        msgList = lists;
        isInit = true;
        // for(int i=0;i<value.result.length;i++) {
        //   if(value.result[i].type == eChatType.AUDIO.index){
        //
        //   }else {
        //     msgList.add(value.result[i]);
        //   }
        // }
      });

      print("메세지 리스트");
      print(msgList.map((e) => e.toJson()));

      if (unread_start_id > 0) {
        List<ChatMsgDto> list = msgList.where((element) => element.id == unread_start_id).toList();
        if (list.isEmpty) {
          getChatList();
        } else {
          int index = msgList.indexOf(list.first);
          mainController.scrollToIndex(index + 2).then((value) {
            initOffset = mainController.offset;
            setState(() {
              bPreview = false;
            });
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
    if (msgController.text.replaceAll(" ", "").isEmpty) {
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
      sendString.value = "";
    });

    addFailedChat(-2, content, type, parent_id);
    print("콘텐츠 추가 ${content}");
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

     print("채팅 보낸 시간 ${DateTime.now()}");

    apiC
        .addChat("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", jsonEncode(body))
        .then((value) async {

          if(value.message.type == eChatType.AUDIO.index) {
            print("서버 api로 부터 받은 값 ${value.message.contents}");
            await playerModule?.closePlayer();
            await playerModule?.openPlayer();

            Duration duration = await playerModule?.startPlayer(
                fromURI: value.message.contents ?? '',
                codec: Codec.pcm16WAV,
                sampleRate: 44000,
                whenFinished: () {}) ??
                const Duration();
            int audioTime = duration.inSeconds;
            await playerModule?.stopPlayer();
            await playerModule?.closePlayer();
            value.message.audioTime = audioTime;
            print("오디오 완료 ${audioTime}");
          }

      print("콘텐츠 추가 ${value.message.id} ${value.message.contents}");
          if(value.room_id == roomDto.id){
            receiveMsg(roomDto, value.message);
            ChatUtils.saveChat(roomDto.id, value.message);
            ChatRoomUtils.saveChatRoom(roomDto);
          }

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

  Future<void> _onStatusRequested(PermissionStatus status) async {
    if (status != PermissionStatus.granted) {
    } else {
      List<AssetEntity>? assets = await MyAssetPicker.pickAssets(context);
      procAssets(assets);
    }
  }

  Future<void> procAssetsWithGallery(List<Medium> assets) async {
    List<File> fileList = []; //image, audio
    List<File> videoList = []; //video
    List<File> thumbList = []; //video thumbnail
    await Future.forEach<Medium>(assets, (file) async {
      File? f = await file.getFile();
      if (file.mediumType == MediumType.video) {
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
      Navigator.pop(context);
      widget.onDeleteRoom(roomDto);
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
      setState(() {
        roomDto = value;
        for(int i=0;i<(roomDto.joined_users?.length ?? 0);i++){
          if(roomDto.joined_users![i].id == me!.id){
            roomDto.joined_users!.removeAt(i);
            break;
          }
        }
        ChatRoomUtils.saveChatRoom(roomDto);
        widget.roomRefresh(roomDto);
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
        .then((value) async {
      hideLoading();
      print(value);
      print(value);
      ChatUtils.deleteChat(roomDto.id, msgList[index]);
      setState(() {
        msgList[index].type = 0;
        msgList[index].chat_idx = -1;
      });
      widget.roomRefresh(roomDto);
    }).catchError((Object obj) {
      hideLoading();
      showToast("connection_failed".tr());
    });
  }

  void startVoiceTimer() {
    //Not related to the answer but you should consider resetting the timer when it starts
    voiceTimer?.cancel();
    voiceDuration = const Duration();
    durationString.value = "00:00:0";
    voiceTimer = Timer.periodic(const Duration(milliseconds: 10), (_) => addVoiceTime());
  }

  void addVoiceTime() {
    final ms = voiceDuration.inMilliseconds + 10;
    voiceDuration = Duration(milliseconds: ms);
    printDuration(voiceDuration);
  }

  void printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoRightDigits(int n) => n.toString().padRight(2, "0");
    String oneDigits(int n) => n.toString().padLeft(1, "0");
    String digitMinutes = oneDigits((duration.inMinutes.remainder(60)).toInt().abs());
    String digitSeconds = twoDigits((duration.inSeconds.remainder(60)).toInt().abs());
    String digitMiliSeconds = twoDigits((duration.inMilliseconds.remainder(1000)/10).toInt());
    print(duration.inMinutes);
    print(duration.inSeconds);
    print(duration.inMilliseconds);
    print(duration.inMilliseconds/100);
    durationString.value = "$digitMinutes:$digitSeconds:$digitMiliSeconds";
    print("시간 ${durationString.value}");
  }

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

  void cancelRecorder() async {
    try {
      await recorderModule.stopRecorder();
      recorderModule.logger.d('stopRecorder');
    } on Exception catch (err) {
      recorderModule.logger.d('stopRecorder error: $err');
    }

    voiceTimer?.cancel();

    return;
  }

  void stopRecorder() async {
    print("스탑");
    try {
      await recorderModule.stopRecorder();
      recorderModule.logger.d('stopRecorder');
    } on Exception catch (err) {
      recorderModule.logger.d('stopRecorder error: $err');
    }

    voiceTimer?.cancel();

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
    uploadAudio();
  }

  Future<void> uploadAudio() async {
    if (audioFilePath == null) return;

    List<File> fileList = [];
    fileList.add(File(audioFilePath!));

    showLoading();
    apiP
        .uploadFile("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", fileList)
        .then((value) async {
      hideLoading();

      List<FileDto> audios = value.result.where((element) => element.type == "sound").toList();

      onFileSend(audios, eChatType.AUDIO.index);
    }).catchError((Object obj) {
      hideLoading();
      showToast("connection_failed".tr());
    });
  }

  Future<void> download(List<String> files, int idx) async {
    if (idx == files.length) return;

    String file_path = files[idx];
    String original_file_name = files[idx].split(Platform.pathSeparator).last;
    print("$file_path,$original_file_name");

    PermissionStatus? photos;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        photos = await Permission.storage.request();
      } else {
        photos = await Permission.photos.request();
      }
    } else if (Platform.isIOS) {
      photos = await Permission.photos.request();
    }
    debugPrint(photos?.toString());

    //file download
    String? dir;
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      dir = directory?.path;
    } else {
      dir = (await getApplicationDocumentsDirectory()).absolute.path; //path provider로 저장할 경로 가져오기
    }
    debugPrint(dir);
    if (dir == null) return;

    try {
      await FlutterDownloader.enqueue(
        url: file_path, // file url
        savedDir: dir, // 저장할 dir
        fileName: original_file_name, // 파일명
        showNotification: true, // show download progress in status bar (for Android)
        openFileFromNotification: true, // click on notification to open downloaded file (for Android)
        saveInPublicStorage: true, // 동일한 파일 있을 경우 덮어쓰기 없으면 오류발생함!
      );

      debugPrint("파일 다운로드 완료");
    } catch (e) {
      debugPrint("eerror :::: $e");
    }
    download(files, idx + 1);
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted || await Permission.storage.request().isGranted) {
        return true;
      }
    }
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted ||
          await Permission.photos.request().isGranted &&
              await Permission.videos.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  Future<bool> onHide() async {
    hideKeyboard();
    return false;
  }

  String makeRoomName() {
    List<String> list = roomDto.joined_users!.map((e) => e.nickname ?? "").toList();
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

  bool isGroupRoom() {
    return roomDto.joined_users!.length == 1;
  }

  UserDto getOnlyOneUser() {
    return roomDto.joined_users![0];
  }

  final GlobalKey _recorderKey = GlobalKey();
  Offset? _getRecorderOffset() {
    if (_recorderKey.currentContext != null) {
      final RenderBox renderBox =
      _recorderKey.currentContext!.findRenderObject() as RenderBox;
      Offset offset = renderBox.localToGlobal(Offset.zero);
      return offset;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("재구성되나?");
    return PageLayout(
        onBack: onBackPressed,
        onTap: onHide,
        isKeyboardHide: false,
        isAvoidResize: false,
        isLoading: isLoading,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
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
                                child: Image.asset(ImageConstants.backWhite, width: 24, height: 24),
                              )
                          ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: GestureDetector(
                              onTap: () {
                                if (closeRoom) return;
                                Navigator.push(
                                    context,
                                    SlideRightTransRoute(
                                        builder: (context) =>
                                            ChatUserPage(
                                              userList: roomDto.joined_users!,
                                              me: me!,
                                              roomDto: roomDto,
                                            changeRoom: (room){
                                                widget.changeRoom(room);
                                            },)));
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  closeRoom ? AppText(
                                    text: 'unknown'.tr(),
                                    fontSize: 16,
                                    maxLength: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.w700,
                                  ) : (roomDto.has_name ?? false) ? AppText(
                                    text: (roomDto.name ?? ''),
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                    maxLength: 1,
                                    fontWeight: FontWeight.w700,
                                  ) : (roomDto.joined_users?.length ?? 0) > 1 ? AppText(
                                    text: makeRoomName(),
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                    maxLength: 1,
                                    fontWeight: FontWeight.w700,
                                  ) : UserNameWidget(user: getOnlyOneUser()),

                                  SizedBox(height: 5,),

                                  AppText(
                                    text: "On-line",
                                    color: ColorConstants.halfWhite,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  )
                                ],
                              )
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: (){
                            List<BtnBottomSheetModel> items = [];
                            if((roomDto.joined_users?.length ?? 0) >= 1)
                              items.add(BtnBottomSheetModel(ImageConstants.addChatUserIcon, "add_room_member".tr(), 0));
                            if((roomDto.joined_users?.length ?? 0) >= 1 && !closeRoom)
                              items.add(BtnBottomSheetModel(ImageConstants.editRoomIcon, "change_room_name".tr(), 1));
                            if((roomDto.joined_users?.length ?? 0) == 1 && !closeRoom)
                              items.add(BtnBottomSheetModel(ImageConstants.banUserIcon, "user_block".tr(), 2));
                            if((roomDto.joined_users?.length ?? 0) == 1 && !closeRoom)
                              items.add(BtnBottomSheetModel(ImageConstants.reportUserIcon, "report_title".tr(), 3));
                            items.add(BtnBottomSheetModel(ImageConstants.exitRoomIcon, "chat_leave".tr(), 4));
                            Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BtnBottomSheetWidget(
                              btnItems: items,
                              onTapItem: (menuIndex) async {
                                if(menuIndex == 0){
                                  Navigator.push(context, SlideRightTransRoute(builder: (context) => ChatAddPage(existUsers: roomDto.joined_users ?? [], roomIdx: roomDto.id,
                                  refresh: (){
                                    getChatRoomInfo();
                                  },changeRoom: (room){
                                      widget.changeRoom(room);
                                    },)));
                                }else if(menuIndex == 1){
                                  Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),EditRoomNameBottomSheet(
                                    roomDto: roomDto,
                                    inputName: (name) async {
                                      if (name.isEmpty) {
                                        return;
                                      }
                                      showLoading();
                                      Map<String, dynamic> body = {
                                        "name": name,
                                        "room_id": roomDto.id,
                                      };
                                      apiC
                                          .changeRoomName("Bearer ${await FirebaseAuth
                                          .instance.currentUser?.getIdToken()}",
                                          jsonEncode(body))
                                          .then((value) {
                                        hideLoading();
                                        setState(() {
                                          roomDto.has_name = true;
                                          roomDto.name = name;
                                        });
                                      }).catchError((Object obj) {
                                        hideLoading();
                                        showToast("connection_failed".tr());
                                      });
                                    },
                                  ));
                                }else if(menuIndex == 2){
                                  List<UserDto> users = roomDto.joined_users ?? [];
                                  for(int i=0;i<users.length;i++){
                                    if(users[i].id != Constants.user.id){
                                      var response = await DioClient.postUserBlock(users[i].id);
                                      Utils.showToast("ban_complete".tr());
                                      break;
                                    }
                                  }
                                }else if(menuIndex == 3){
                                  List<UserDto> users = roomDto.joined_users ?? [];
                                  for(int i=0;i<users.length;i++){
                                    if(users[i].id != Constants.user.id){
                                      showModalBottomSheet<dynamic>(
                                          isScrollControlled: true,
                                          context: context,
                                          useRootNavigator: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (BuildContext bc) {
                                            return ReportUserDialog(onConfirm: (reportList, reason) async {
                                              var response = await DioClient.reportUser(users[i].id, reportList, reason);
                                              Utils.showToast("report_complete".tr());
                                            },);
                                          }
                                      );
                                      break;
                                    }
                                  }
                                }else {
                                  AppDialog.showConfirmDialog(context, "leave_title".tr(), "leave_content".tr(), () {
                                    chatRoomLeave();
                                  });
                                }
                              },
                            ));
                          },
                          child: Container(
                              width: 24,
                              height: 24,
                              margin: EdgeInsets.only(right: 10),
                              child: Center(
                                child: Image.asset(ImageConstants.moreWhite, width: 24, height: 24),
                              )),
                        ),
                      ],
                    ),
                  ),

                  isInit ?
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            cacheExtent: double.infinity,
                            padding: const EdgeInsets.all(10),
                            controller: mainController,
                            itemCount: msgList.length,
                            reverse: true,
                            // physics: const ClampingScrollPhysics(),
                            physics: physics,
                            itemBuilder: (BuildContext context, int index) {
                              // print('testtest itemchatmsg index : ${index}');
                              // WriteLog.write("itemchatmsg index ${index} t : ${DateTime.now()}",fileName: "itemchatmsg.txt");
                              if(msgList[index].type >= 5){
                                return Container();
                              }
                              Key key = Key(msgList[index].id.toString());
                              return SwipeTo(
                                key: key,
                                  onLeftSwipe: (details){
                                    print("스와이프 인덱스 ${index}번째 ${msgList[index].contents}");
                                    if (msgList[index].id == -1) return;
                                    setState(() {
                                      replyIdx = index;
                                    });
                                    myFocusNode.requestFocus();
                                  },
                                  swipeSensitivity: 5,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: msgList.length-1 > index && msgList[index+1].sender_id != msgList[index].sender_id ? 15 : 0),
                                    child: AutoScrollTag(
                                      key: ValueKey(index),
                                      controller: mainController,
                                      index: index,
                                      child: ItemChatMsg(
                                          users: roomDto.joined_users!,
                                          info: msgList[index],
                                          unread: unreadList,
                                          me: me!,
                                          before: index == msgList.length - 1 ? null : msgList[index + 1],
                                          next: index == 0 ? null : msgList[index - 1],
                                          parentNick: parentChatNick(
                                              roomDto.joined_users!, me, msgList, msgList[index].parent_chat?.id ?? 0),
                                          bNewMsg: msgList[index].id == unread_start_id,
                                          playerModule:
                                          msgList[index].type != eChatType.AUDIO.index ? null : playerModule,
                                          setState: () {
                                            setState(() {

                                            });
                                          },
                                          onProfile: () async {
                                            Utils.showDialogWidget(context);
                                            try {
                                              var response = await DioClient
                                                  .getUser(msgList[index].sender
                                                  ?.nickname ?? "");
                                              UserModel user = UserModel
                                                  .fromJson(response
                                                  .data["result"]["target"]);
                                              Get.back();
                                              Get.to(ProfileScreen(user: user));
                                            }catch(e){
                                              Get.back();
                                            }
                                          },
                                          onDelete: () {
                                            if (msgList[index].id == -1) return;
                                            deleteChat(index);
                                          },
                                          onTap: () {
                                            if (msgList[index].id == -1) {
                                              List<BtnBottomSheetModel> items = [];
                                              items.add(BtnBottomSheetModel(ImageConstants.resendIcon, "resend".tr(), 0));
                                              items.add(BtnBottomSheetModel(ImageConstants.cancelSendIcon, "send_cancel".tr(), 1));

                                              Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BtnBottomSheetWidget(
                                                btnItems: items,
                                                onTapItem: (menuIndex) async {
                                                  if(menuIndex == 0){
                                                    this.setState(() {
                                                      ChatMsgDto dto = msgList[index];
                                                      msgList.removeAt(index);

                                                      addChat(dto.contents ?? '', dto.type, dto.parent_id);
                                                    });
                                                  }else {
                                                    this.setState(() {
                                                      msgList.removeAt(index);
                                                    });
                                                  }
                                                },
                                              ));
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
                                            List<BtnBottomSheetModel> items = [];
                                            if(msgList[index].type == eChatType.IMAGE.index) {
                                              items.add(BtnBottomSheetModel(
                                                  ImageConstants.copyIcon,
                                                  "save".tr(), 0));
                                            }else{
                                              items.add(BtnBottomSheetModel(
                                                  ImageConstants.copyIcon,
                                                  "copy".tr(), 0));
                                            }
                                            items.add(BtnBottomSheetModel(ImageConstants.replyIcon, "reply".tr(), 1));
                                            if(msgList[index].sender_id == me!.id)
                                              items.add(BtnBottomSheetModel(ImageConstants.deleteIcon, "delete".tr(), 2));

                                            Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BtnBottomSheetWidget(
                                              btnItems: items,
                                              onTapItem: (sheetIdx) async {
                                                if(sheetIdx == 0){
                                                  if(msgList[index].type == eChatType.IMAGE.index) {
                                                    List<String> images = (msgList[index].contents ?? '').split(",");
                                                    download(images, 0);
                                                  }else{
                                                    await Clipboard.setData(
                                                        ClipboardData(text: (msgList[index].contents ?? '')));
                                                  }
                                                }else if(sheetIdx == 1){
                                                  this.setState(() {
                                                    replyIdx = index;
                                                  });
                                                }else{
                                                  deleteChat(index);
                                                }
                                              },
                                            ));
                                          }),
                                    ),
                                  )
                              );
                            },
                          ),
                        ),
                        if (bPreview)
                          GestureDetector(
                            onTap: () {
                              mainController.scrollToIndex(0);
                            },
                            child: Container(
                              width: double.maxFinite,
                              margin: EdgeInsets.only(left: 10,right: 10),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: ColorConstants.white5Percent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  ImageUtils.ProfileImage(msgList.first.sender?.picture ?? "", 42, 42),
                                  const SizedBox(width: 10),
                                  AppText(
                                    text: msgList.first.sender?.nickname ?? '',
                                    fontSize: 13,
                                    color: ColorConstants.halfWhite,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: AppText(
                                      text: chatContent(msgList.first.contents ?? '', msgList.first.type ?? 0),
                                      fontSize: 14,
                                      maxLine: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Image.asset(
                                      ImageConstants.chatUnderWhite,
                                      height: 24,
                                      width: 24),
                                ],
                              ),
                            ),
                          ),
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

                  if (replyIdx != -1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: "replied_top_message".tr(args: ["${msgList[replyIdx].sender?.nickname ?? ""}"]),
                                  fontSize: 10,
                                  color: ColorConstants.halfWhite,
                                ),
                                AppText(
                                  text: msgList[replyIdx]?.unsended_at != null ? "deleted_msg".tr() : chatContent(msgList[replyIdx].contents ?? '', msgList[replyIdx].type),
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  replyIdx = -1;
                                });
                              },
                              child: Image.asset(ImageConstants.chatX, width: 24, height: 24)),
                          SizedBox(width: 30,)
                        ],
                      ),
                    ),
                  Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Container(
                                    constraints: BoxConstraints(
                                        minHeight: 50),
                                    margin: const EdgeInsets.only(left: 10, top: 15, bottom: 15, right: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: ColorConstants.white10Percent
                                    ),
                                    width: double.infinity,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [

                                        Container(
                                          width: double.maxFinite,
                                          margin: EdgeInsets.only(right: 30),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [

                                            Obx(() => _isRecording.value || _isRecordLock.value ?
                                                Row(
                                                  children:[
                                                    SizedBox(width: 10),
                                                    Container(
                                                      width: 6,
                                                      height: 6,
                                                      decoration: BoxDecoration(
                                                          color: Color(0xffeb5757),
                                                          borderRadius: BorderRadius.circular(3)
                                                      ),
                                                    ),

                                                    SizedBox(width: 5,),
                                                    Obx(() => AppText(
                                                      text: durationString.value,
                                                      color: ColorConstants.halfWhite,
                                                      fontSize: 14,
                                                    ))
                                                  ]
                                                ) : Row(
                                              children: [
                                                const SizedBox(width: 7),
                                                InkWell(
                                                  onTap: (){
                                                    if (closeRoom) return;

                                                    List<BtnBottomSheetModel> items = [];
                                                    items.add(BtnBottomSheetModel(ImageConstants.cameraIcon, "camera".tr(), 0));
                                                    items.add(BtnBottomSheetModel(ImageConstants.albumIcon, "gallery".tr(), 1));

                                                    Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BtnBottomSheetWidget(
                                                      btnItems: items,
                                                      onTapItem: (sheetIdx) async {
                                                        if(sheetIdx == 0){
                                                          AssetEntity? assets = await MyAssetPicker.pickCamera(context);
                                                          if (assets != null) {
                                                            procAssets([assets]);
                                                          }
                                                        }else {
                                                          if (await _promptPermissionSetting()) {
                                                            showModalBottomSheet(
                                                                context: context,
                                                                isScrollControlled: true,
                                                                isDismissible: true,
                                                                backgroundColor: Colors.transparent,
                                                                constraints: BoxConstraints(
                                                                  minHeight: 0.4,
                                                                  maxHeight: Get.height*0.95,
                                                                ),
                                                                builder: (BuildContext context) {
                                                                  return DraggableScrollableSheet(
                                                                      initialChildSize: 0.5,
                                                                      minChildSize: 0.4,
                                                                      maxChildSize: 0.9,
                                                                      expand: false,
                                                                      builder: (_, controller) => GalleryBottomSheet(
                                                                        controller: controller,
                                                                        onTapSend: (results){
                                                                          procAssetsWithGallery(results);
                                                                        },
                                                                      )
                                                                  );
                                                                }
                                                            );
                                                          }
                                                        }
                                                      },
                                                    ));
                                                  },
                                                  child: Container(
                                                    width: 35,
                                                    height: 35,
                                                    child: Center(
                                                      child: Image.asset(
                                                        closeRoom ? "assets/image/ic_add_disable.png" : ImageConstants.chatPlus,
                                                        width: 20,
                                                        height: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                              ],
                                            )
                                            ),

                                              Expanded(
                                                child:
                                                Obx(() => TextField(
                                                  focusNode: myFocusNode,
                                                  maxLines: 4,
                                                  minLines: 1,
                                                  maxLength: 5000,
                                                  enabled: !closeRoom,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: FontConstants.AppFont,
                                                      fontSize: 14
                                                  ),
                                                  showCursor: !_isRecording.value,
                                                  controller: msgController,
                                                  decoration: InputDecoration(
                                                      counterText: "",
                                                      hintText: closeRoom ? "disable_chat".tr() : "input_msg".tr(),
                                                      hintStyle: TextStyle(
                                                          color: ColorConstants.halfWhite,
                                                          fontSize: 14,
                                                          fontFamily: FontConstants.AppFont,
                                                          fontWeight: FontWeight.w400
                                                      ),
                                                      border: InputBorder.none,
                                                      contentPadding: const EdgeInsets.only(bottom: 5)
                                                  ),
                                                  onChanged: (text) {
                                                    sendString.value = text;
                                                  },
                                                ))
                                              ),
                                              const SizedBox(width: 10),
                                            ],
                                          ),
                                        ),

                                        Container(
                                          width: double.maxFinite,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children:[
                                              Container(),

                                              Obx(() => GestureDetector(
                                                child: Container(
                                                    width: 200,
                                                    height: 30,
                                                    child: Stack(
                                                      children: [
                                                        if(_isRecording.value)
                                                          Positioned(
                                                            top:0,
                                                            bottom: 0,
                                                            left: 0,
                                                            child: Image.asset(ImageConstants.micSlideGuide, fit: BoxFit.cover,
                                                              height: 45,),
                                                          ),

                                                        if(!_isRecording.value || _isRecordLock.value)
                                                          Positioned(
                                                              top: 0,
                                                              bottom:0,
                                                              right: 10,
                                                              child: Container(
                                                                width: 30,
                                                                height: 30,
                                                                key: _recorderKey,
                                                                child: Image.asset(closeRoom ? ImageConstants.chatMicDisable : !_isRecording.value ? ImageConstants.chatMic : ImageConstants.micPressed, width: 30, height: 30),
                                                              )
                                                          )
                                                      ],
                                                    )
                                                ),
                                                onLongPressMoveUpdate: (detail) {
                                                  if(closeRoom)
                                                    return;
                                                  if (micFirstX != null) {
                                                    // 왼쪽 취소부터 체크
                                                    if (micFirstX!.dx -
                                                        detail.globalPosition.dx >= 10) {
                                                      if (micFirstX!.dx -
                                                          detail.globalPosition.dx <=
                                                          80) {
                                                        print("이동");
                                                        changedX!.value = detail.globalPosition.dx;
                                                        changedY!.value = micFirstX!.dy;
                                                      }
                                                      print("${micFirstX!.dx -
                                                          detail.globalPosition
                                                              .dx}만큼 왼쪽으로 움직임");
                                                      // 취소
                                                      if (micFirstX!.dx -
                                                          detail.globalPosition.dx >=
                                                          80) {
                                                        _isRecording.value = false;
                                                        _isRecordLock.value = false;
                                                        _isRecordCancel = true;
                                                        changedX = null;
                                                        changedY = null;
                                                        micFirstX = null;
                                                        cancelRecorder();
                                                        msgController.text = tempString;
                                                      }
                                                    } else if (micFirstX!.dy -
                                                        detail.globalPosition.dy >= 10) {
                                                      print("${micFirstX!.dy -
                                                          detail.globalPosition
                                                              .dy}만큼 위쪽으로 움직임");
                                                      if(micFirstX!.dy -
                                                          detail.globalPosition
                                                              .dy <= 100) {
                                                        print("이동");
                                                        changedX!.value = micFirstX!.dx;
                                                        changedY!.value = detail.globalPosition.dy;
                                                      }else {
                                                        _isRecordLock.value = true;
                                                        changedX = null;
                                                        changedY = null;
                                                        print("녹음 락");
                                                      }
                                                    }
                                                  }
                                                },
                                                onTap: (){
                                                  if(closeRoom)
                                                    return;
                                                  if(!_isRecordLock.value && !_isRecordCancel) {
                                                    showToast("audio_tap_toast".tr());
                                                  }else{

                                                  }
                                                },
                                                onLongPressStart: (detail) async {
                                                  if(closeRoom)
                                                    return;
                                                  if(_isRecordCancel) {
                                                    return;
                                                  }
                                                  if(!isMicPermission){
                                                    isMicPermission = (await Permission.microphone.request()).isGranted;
                                                    return;
                                                  }
                                                  if(!_isRecording.value){
                                                    voiceDuration = const Duration();
                                                    durationString.value = "00:00:0";
                                                    openTheRecorder();
                                                    _isRecording.value = true;
                                                    _isRecordLock.value = false;
                                                    print("글로벌 포지션 ${micFirstX}");
                                                    Offset? recorderOffset = _getRecorderOffset();
                                                    if(recorderOffset != null){
                                                      changedX = recorderOffset!.dx.obs;
                                                      changedY = recorderOffset!.dy.obs;
                                                      lockX = recorderOffset!.dx.obs;
                                                      lockY = recorderOffset!.dy.obs;
                                                      micFirstX = recorderOffset!;
                                                    }else {
                                                      changedX =
                                                          detail.globalPosition.dx
                                                              .obs;
                                                      changedY =
                                                          detail.globalPosition.dy
                                                              .obs;
                                                      lockX = detail.globalPosition.dx
                                                          .obs;
                                                      lockY = detail.globalPosition.dy
                                                          .obs;
                                                      micFirstX = detail.globalPosition;
                                                    }
                                                  }
                                                  tempString = msgController.text;
                                                  msgController.text = " ";
                                                },
                                                onLongPressEnd: (detail){
                                                  if(closeRoom)
                                                    return;
                                                  if(_isRecordCancel) {
                                                    _isRecordCancel = false;
                                                    return;
                                                  }
                                                  if(!_isRecordLock.value) {
                                                    _isRecording.value = false;
                                                    stopRecorder();
                                                    msgController.text = tempString;
                                                  }
                                                },
                                                onTapDown: (detail){
                                                  if(closeRoom)
                                                    return;
                                                  if(_isRecordLock.value){
                                                    _isRecording.value = false;
                                                    _isRecordLock.value = false;
                                                    micFirstX = null;
                                                    changedX = null;
                                                    changedY = null;
                                                    _isRecordCancel = true;
                                                    stopRecorder();
                                                    msgController.text = tempString;
                                                  }
                                                },
                                              )
                                              )


                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                )
                            ),

                            GestureDetector(
                              onTap: onTextSend,
                              child: Obx(() => Container(
                                width: 40,
                                height: 40,
                                child: Center(
                                    child: sendString.value.replaceAll(" ", "").isNotEmpty ? Image.asset(ImageConstants.sendChatBnt, width: 30, height: 30) : Image.asset(ImageConstants.sendChatDisableBnt, width: 30, height: 30)
                                ),
                              ),)
                            ),

                            SizedBox(width: 5,)
                          ],
                        );
                      },
                    )
                  )
                ],
              ),

              Obx(() => (_isRecording.value && changedY != null && changedX != null && !_isRecordLock.value) ?
              Transform.translate(
                  offset: Offset(
                    changedX!.value,
                    changedY!.value - MediaQuery.of(context).padding.top,
                  ),
                  child: Container(
                    width: 30,
                    height: 30,
                    child: Image.asset(ImageConstants.micPressed, width: 30, height: 30),
                  )
              ) : Container()),

              Obx(() => (_isRecording.value && lockX != null && lockY != null && !_isRecordLock.value) ?
              Transform.translate(
                  offset: Offset(
                    lockX!.value,
                    lockY!.value - MediaQuery.of(context).padding.top - 80,
                  ),
                  child: Container(
                    width: 30,
                    height: 60,
                    child: Image.asset(ImageConstants.audioLock, width: 30, height: 60),
                  )
              ) : Container())
            ],
          )
        )
    );
  }
}
