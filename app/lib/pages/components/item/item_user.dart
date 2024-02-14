import 'package:app/models/dto/user_dto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/global/app_colors.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemUser extends StatelessWidget {
  UserDto info;
  bool selected;
  final onClick;

  ItemUser({Key? key, required this.info, required this.selected, this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 10),
              (info.profile_img ?? '').isEmpty
                  ? Image.asset("assets/image/ic_default_user.png", height: 54, width: 54)
                  : ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: info.profile_img ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        width: 54,
                        height: 54,
                      ),
                    ),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          info.nickname ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: appColorText1, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Visibility(
                        visible: info.is_developer == 1,
                        child: Container(
                          decoration:
                              BoxDecoration(color: appColorBlue, borderRadius: BorderRadius.circular(4)),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          child: const Text(
                            'DEV',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      )
                      // InkWell(onTap: onDelete, child: Image.asset("assets/image/ic_close_c.png", width: 25))
                    ],
                  ),
                  Text(
                    info.name ?? '',
                    style: const TextStyle(color: appColorText2, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )),
              const SizedBox(width: 6),
              Image.asset(selected ? "assets/image/ic_radio_on.png" : "assets/image/ic_radio_off.png",
                  height: 20, width: 20),
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
    );
  }
}
