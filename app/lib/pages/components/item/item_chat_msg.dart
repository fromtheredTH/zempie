import 'dart:typed_data';

import 'package:app/models/dto/user_dto.dart';
import 'package:image/image.dart' as img;
import 'package:app/global/global.dart';
import 'package:app/models/dto/unread_dto.dart';
import 'package:app/pages/components/fucus_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app/global/app_colors.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/helpers/transition.dart';
import 'package:app/models/dto/chat_msg_dto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:app/write_log.dart';

import '../image_viewer.dart';

class ItemChatMsg extends StatelessWidget {
  List<UserDto> users;
  ChatMsgDto info;
  List<UnreadDto> unread;
  ChatMsgDto? before;
  ChatMsgDto? next;
  String? parentNick;
  bool? bNewMsg;
  FlutterSoundPlayer? playerModule;
  final setState;
  final onProfile;
  final onDelete;
  final onTap;
  final onReply;
  final onLongPress;

  bool mine = true;
  bool paragraphStart = false;
  bool paragraphEnd = false;
  double profileHeight = 42.0;
  double profileWidth = 42.0;

  ItemChatMsg(
      {Key? key,
      required this.users,
      required this.info,
      required this.unread,
      this.before,
      this.next,
      this.parentNick,
      this.bNewMsg,
      required this.setState,
      required this.playerModule,
      required this.onProfile,
      required this.onDelete,
      required this.onTap,
      required this.onReply,
      required this.onLongPress})
      : super(key: key) {
    //info.id: -1 실패, -2 전송중,

    bNewMsg ??= false;
    mine = info.sender_id == gCurrentId;
    paragraphStart = chatTime2(info.created_at ?? '') != chatTime2(before?.created_at ?? '') ||
        info.sender_id != before?.sender_id;
    paragraphEnd = chatTime2(info.created_at ?? '') != chatTime2(next?.created_at ?? '') ||
        info.sender_id != next?.sender_id;
    profileHeight = paragraphStart ? 42.0 : 20.0;

    getUnreadCount(info);
    if (info.type == eChatType.VIDEO.index) {}
    if (info.type == eChatType.AUDIO.index) {
      if ((info.audioTime ?? 0) == 0) {
        loadAudio();
      }
    }
  }

  void getUnreadCount(dynamic info) 
  {
   // print("chat id : ${info.id}, timetime : ${DateTime.now()}");
    if (unread.isEmpty) return;
    int count = 0;
    for (var e in unread) {
      if (e.last_read_id != null) {
        if (e.last_read_id! < info.id) {
          count++;
        }
      }
    }
    info.unread_count = count;
    WriteLog.renderingEndTime = DateTime.now();     
    WriteLog.write("unread chat id : ${info.id}, timetime : ${DateTime.now()}\n ",fileName: 'getUnreadCountFunc.txt');
    WriteLog.write("unread chat id : ${info.id}, timetime : ${DateTime.now()}\n ",fileName: 'AllInOne.txt');
    WriteLog.write(' clientRenderingTime chat id : ${info.id} : ${WriteLog.TimeDifferenceClientRendering()} \n',fileName: 'clitent_Rendering_Span.txt');
    WriteLog.write(' clientRenderingTime chat id : ${info.id} : ${WriteLog.TimeDifferenceClientRendering()} \n',fileName: 'AllInOne.txt');
    WriteLog.write(' overall_Span time: ${WriteLog.TimeDifferenceOverall()} \n',fileName: 'overall_Span.txt');
    WriteLog.write(' overall_Span time: ${WriteLog.TimeDifferenceOverall()} \n',fileName: 'AllInOne.txt');
  }

  Future<void> loadAudio() async {
    await playerModule?.closePlayer();
    await playerModule?.openPlayer();

    Duration duration = await playerModule?.startPlayer(
            fromURI: info.contents ?? '', codec: Codec.pcm16WAV, sampleRate: 44000, whenFinished: () {}) ??
        const Duration();
    info.audioTime = duration.inSeconds;
    await playerModule?.stopPlayer();
    await playerModule?.closePlayer();
    setState();
  }

  String getNick() {
    List<UserDto> list = users.where((element) => element.id == info.sender_id).toList();
    if (list.isEmpty) {
      return 'unknown'.tr();
    }
    return info.sender?.nickname ?? '';
  }

  void fullView(BuildContext context, int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImageViewer(
                  images: (info.contents ?? '').split(","),
                  selected: index,
                  isVideo: false,
                  title: getNick(),
                ))).then((value) {
      if (value == "delete") {
        onDelete();
      }
    });
  }

  Widget textTile() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      decoration: BoxDecoration(
          color: (info.chat_idx == -1 || !mine) ? Colors.white : appColorGrey4,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: (info.chat_idx == -1 || !mine) ? appColorGrey4 : Colors.transparent)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        info.chat_idx == -1 ? 'deleted_msg'.tr() : (info.contents ?? ''),
        style: TextStyle(color: info.chat_idx == -1 ? appColorText4 : Colors.black, fontSize: 14),
      ),
    );
  }

  double getImageSize(int cnt, index) {
    if (cnt <= 2 || cnt == 4) {
      return 120;
    } else if (cnt == 3 || cnt == 6 || cnt == 9) {
      return 80;
    } else if (cnt == 5 || cnt == 7) {
      return index <= 2 ? 80 : 120;
    } else if (cnt == 8 || cnt == 10) {
      return index <= 5 ? 80 : 120;
    }
    return 0;
  }

  Widget imageTile(BuildContext context) {
    List<String> arr = (info.contents ?? '').split(",");
    int cnt = arr.length;

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Wrap(
        alignment: mine ? WrapAlignment.end : WrapAlignment.start,
        runSpacing: 0,
        spacing: 0,
        children: [
          ...List.generate(cnt, (index) {
            return GestureDetector(
              onTap: () {
                fullView(context, index);
              },
              child: CachedNetworkImage(
                imageUrl: arr[index],
                fit: BoxFit.fill,
                width: getImageSize(cnt, index),
                height: getImageSize(cnt, index),
              ),
            );
          })
        ],
      ),
    );
  }

  Widget videoTile(BuildContext context) {
    double aspect = 2;

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageViewer(
                      images: (info.contents ?? '').split(","),
                      selected: 0,
                      isVideo: true,
                      title: getNick(),
                    ))).then((value) {
          if (value == "delete") {
            onDelete();
          }
        });
      },
      child: SizedBox(
          width: 240,
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: aspect,
                child: (info.contents ?? '').split(",").length != 2
                    ? Container(color: Colors.black)
                    : CachedNetworkImage(
                        imageUrl: (info.contents ?? '').split(",")[1],
                        fit: BoxFit.fill,
                      ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset('assets/image/ic_video.png', width: 40, height: 40),
                ),
              )
            ],
          )),
    );
  }

  Widget audioTile() {
    return GestureDetector(
      onTap: () async {
        if (playerModule?.isPlaying ?? false) {
          await playerModule?.stopPlayer();
          info.isPlayAudio = false;
          setState();
        } else {
          await playerModule?.closePlayer();
          await playerModule?.openPlayer();

          await playerModule?.startPlayer(
                  fromURI: info.contents ?? '',
                  codec: Codec.pcm16WAV,
                  sampleRate: 44000,
                  whenFinished: () {
                    info.isPlayAudio = false;
                    setState();
                  }) ??
              const Duration();
          info.isPlayAudio = true;
          setState();
        }
      },
      child: Container(
        width: 120,
        height: 36,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: appColorGrey4)),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
                (info.isPlayAudio ?? false) ? 'assets/image/ic_pause.png' : 'assets/image/ic_play.png',
                width: 20,
                height: 20),
            Text(
              "${pad2(Duration(seconds: info.audioTime ?? 0).inMinutes.remainder(60))}:${pad2((Duration(seconds: info.audioTime ?? 0).inSeconds.remainder(60)))}",
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 20) {
          onReply();
        }
      },
      child: Column(
        children: [
          Visibility(
            visible: bNewMsg!,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Container(height: 1, color: appColorOrange4)),
                  const SizedBox(width: 20),
                  Text('new_msg'.tr(), style: const TextStyle(fontSize: 8, color: appColorOrange4)),
                  const SizedBox(width: 20),
                  Expanded(child: Container(height: 1, color: appColorOrange4)),
                ],
              ),
            ),
          ),
          Stack(
            children: [
              Visibility(
                visible: mine,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 4),
                        Visibility(
                          visible: info.parent_id > 0 && info.chat_idx != -1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "reply_from_me".tr(args: [parentNick ?? '']),
                                style: const TextStyle(color: appColorText4, fontSize: 12),
                              ),
                              Container(
                                constraints: const BoxConstraints(maxWidth: 200),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: appColorGrey4)),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: Text(
                                  chatContent(info.parent_chat?.contents ?? '', info.parent_chat?.type ?? 0),
                                  style: const TextStyle(color: appColorText4, fontSize: 14),
                                ),
                              )
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Visibility(
                                  visible: (info.unread_count ?? 0) > 0,
                                  child: Text(
                                    '${info.unread_count}',
                                    style: const TextStyle(color: appColorOrange4, fontSize: 10),
                                  ),
                                ),
                                Opacity(
                                  opacity: paragraphEnd ? 1 : 0,
                                  child: info.id == -2
                                      ? const SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Text(
                                          chatTime2(info.created_at ?? ''),
                                          style: const TextStyle(color: Colors.black, fontSize: 8),
                                        ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            if (info.type == eChatType.TEXT.index)
                              textTile()
                            else if (info.type == eChatType.IMAGE.index)
                              imageTile(context)
                            else if (info.type == eChatType.VIDEO.index)
                              videoTile(context)
                            else if (info.type == eChatType.AUDIO.index)
                              audioTile()
                          ],
                        ),
                      ],
                    ),
                    Visibility(
                      visible: info.id == -1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Image.asset(
                          'assets/image/ic_fail.png',
                          width: 25,
                          height: 25,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Visibility(
                  visible: !mine,
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Opacity(
                            opacity: paragraphStart ? 1 : 0,
                            child: InkWell(
                              onTap: onProfile,
                              child: (info.sender?.picture ?? '').isEmpty
                                  ? Image.asset("assets/image/ic_default_user.png",
                                      height: profileHeight, width: profileWidth)
                                  : ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: info.sender?.picture ?? '',
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => CircularProgressIndicator(),
                                        errorWidget: (context, url, error) => Image.asset(
                                            "assets/image/ic_default_user.png",
                                            height: profileHeight,
                                            width: profileWidth),
                                        height: profileHeight,
                                        width: profileWidth,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              info.parent_id > 0 && info.chat_idx != -1
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 6),
                                          child: Text(
                                            "reply_from_other".tr(args: [getNick(), parentNick ?? '']),
                                            style: TextStyle(
                                                color: info.parent_id > 0 ? appColorText4 : Colors.black,
                                                fontSize: 12),
                                          ),
                                        ),
                                        Container(
                                          constraints: const BoxConstraints(maxWidth: 200),
                                          margin: const EdgeInsets.only(bottom: 4),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: appColorGrey4)),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          child: Text(
                                            chatContent(info.parent_chat?.contents ?? '',
                                                info.parent_chat?.type ?? 0),
                                            style: const TextStyle(color: appColorText4, fontSize: 14),
                                          ),
                                        )
                                      ],
                                    )
                                  : Visibility(
                                      visible: paragraphStart,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Text(
                                          getNick(),
                                          style: TextStyle(
                                              color: info.parent_id > 0 ? appColorText4 : Colors.black,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (info.type == eChatType.TEXT.index)
                                        textTile()
                                      else if (info.type == eChatType.IMAGE.index)
                                        imageTile(context)
                                      else if (info.type == eChatType.VIDEO.index)
                                        videoTile(context)
                                      else if (info.type == eChatType.AUDIO.index)
                                        audioTile()
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible: (info.unread_count ?? 0) > 0,
                                        child: Text(
                                          '${info.unread_count}',
                                          style: const TextStyle(color: appColorOrange4, fontSize: 10),
                                        ),
                                      ),
                                      Opacity(
                                        opacity: paragraphEnd ? 1 : 0,
                                        child: Text(
                                          chatTime2(info.created_at ?? ''),
                                          style: const TextStyle(color: Colors.black, fontSize: 8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
