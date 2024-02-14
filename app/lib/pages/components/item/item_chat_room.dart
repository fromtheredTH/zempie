import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/global/app_colors.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemChatRoom extends StatelessWidget {
  ChatRoomDto info;
  final onDelete;
  final onClick;
  final onLongPress;

  ItemChatRoom({Key? key, required this.info, this.onDelete, this.onClick, this.onLongPress})
      : super(key: key);

  String makeRoomName() {
    List<String> list = info.joined_users!.map((e) => e.nickname!).toList();
    list.sort();
    String str = list.join(",");
    String name = str.substring(0, min(14, str.length));
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      onLongPress: onLongPress,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 10),
                (info.joined_users?.isEmpty ?? false) || (info.joined_users?[0].picture ?? '').isEmpty
                    ? Image.asset("assets/image/ic_default_user.png", height: 54, width: 54)
                    : ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: info.joined_users?[0].picture ?? '',
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          (info.joined_users?.isEmpty ?? false)
                              ? 'unknown'.tr()
                              : ((info.has_name ?? false) ? (info.name ?? '') : makeRoomName()),
                          style: const TextStyle(
                              color: appColorText1, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        // const SizedBox(width: 10),
                        // Visibility(
                        //   visible: info.joined_users?[0].is_developer == 1,
                        //   child: Container(
                        //     decoration:
                        //         BoxDecoration(color: appColorBlue, borderRadius: BorderRadius.circular(4)),
                        //     padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        //     child: const Text(
                        //       'DEV',
                        //       style: TextStyle(color: Colors.white, fontSize: 10),
                        //     ),
                        //   ),
                        // )
                        // InkWell(onTap: onDelete, child: Image.asset("assets/image/ic_close_c.png", width: 25))
                      ],
                    ),
                    Text(
                      chatContent(info.last_message?.contents ?? '', info.last_message?.type ?? 0),
                      style: const TextStyle(color: appColorText2, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      chatTime(info.last_chat_at ?? ''),
                      style: const TextStyle(color: appColorText3, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Visibility(
                      visible: info.unread_count > 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            info.unread_count.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              height: 1,
              color: appColorLightGrey,
            ),
          ],
        ),
      ),
    );
  }
}
