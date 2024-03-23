import 'package:app/Constants/Constants.dart';
import 'package:app/models/dto/user_dto.dart';
import 'package:app/pages/components/item/item_user_name.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/global/app_colors.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../Constants/ColorConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../app_text.dart';

class ItemJoinedUser extends StatelessWidget {
  UserDto info;

  ItemJoinedUser({Key? key, required this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){

      },
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 10),
              ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(45)
                    ),
                    child: (info.profile_img ?? '').isEmpty ? Image.asset("assets/image/ic_default_user.png", height: 45, width: 45) :
                    CachedNetworkImage(
                      imageUrl: info.profile_img ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      width: 45,
                      height: 45,
                    ),
                  )
              ),

              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UserNameWidget(user: info),
                      SizedBox(height: 3,),
                      AppText(
                        text: info.nickname ?? '',
                        overflow: TextOverflow.ellipsis,
                        fontSize: 12,
                        maxLine: 1,
                        color: ColorConstants.halfWhite,
                      ),
                    ],
                  )),

              if(info.id != (Constants.user.id ?? 0))
                Row(
                  children: [
                    const SizedBox(width: 6),
                    Image.asset((info.is_following ?? false) ? ImageConstants.moreWhite : ImageConstants.userFollow,
                        height: 24, width: 24),
                  ],
                ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
