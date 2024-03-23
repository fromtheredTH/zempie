import 'dart:math';

import 'package:app/Constants/ColorConstants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/global/app_colors.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../Constants/ImageConstants.dart';
import '../../../models/dto/user_dto.dart';
import '../app_text.dart';

class ItemChatRoom extends StatelessWidget {
  ChatRoomDto info;
  final onDelete;
  final onClick;
  final onLongPress;

  ItemChatRoom({Key? key, required this.info, this.onDelete, this.onClick, this.onLongPress})
      : super(key: key);

  String makeRoomName() {
    List<String> list = info.joined_users!.map((e) => e.nickname ?? "").toList();
    list.sort();
    String str = list.join(",");
    String name = str.substring(0, min(14, str.length));

    int cnt1 = name.split(',').length;
    int cnt2 = info.joined_users!.length + 1 - cnt1;
    if (cnt2> 1) {
      return "$name 외 $cnt2명";
    } else {
      return name;
    }
  }

  Widget makeRoomProfile(List<UserDto> users, double size) {
    if(users.length == 0){
      return ImageUtils.ProfileImage("", size, size);
    }else if(users.length == 1){
      return ImageUtils.ProfileImage(users[0].picture ?? "", size, size);
    }else {
      users.sort((a, b) => (a.nickname ?? "").compareTo(b.nickname ?? ""));
      List<UserDto> profileUsers = [users[0], users[1]];
      return Container(
        width: size,
        height: size/2 + 4,
        child: Stack(
          children: [
            Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: makeRoomProfile([profileUsers[0]], size/2 + 4)
            ),

            Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: makeRoomProfile([profileUsers[1]], size/2 + 4)
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      onLongPress: onLongPress,
      child: Container(
        color: ColorConstants.colorBg1,
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 10),
                makeRoomProfile(info.joined_users ?? [], 45),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          text: (info.joined_users?.isEmpty ?? false)
                              ? 'unknown'.tr()
                              : ((info.has_name ?? false) ? (info.name ?? '') : makeRoomName()),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),

                        SizedBox(height: 5,),

                        AppText(
                          text: chatTime(info.last_chat_at ?? ''),
                          fontSize: 11,
                          color: ColorConstants.halfWhite,
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: AppText(
                              text: chatContent(info.last_message?.contents ?? 'new_room_msg'.tr(), info.last_message?.type ?? 0),
                              fontSize: 12,
                              color: ColorConstants.halfWhite,
                              maxLine: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ),

                        SizedBox(height: 5,),

                        if(info.unread_count > 0)
                          Container(
                            padding: EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
                            decoration: BoxDecoration(color: Color(0xffeb5757), borderRadius: BorderRadius.circular(50)),
                            child: Center(
                              child: AppText(
                                text: info.unread_count > 99 ? "+${info.unread_count}" : "${info.unread_count}",
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),

                  ],
                )
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
