import 'package:app/Constants/ColorConstants.dart';
import 'package:app/models/dto/user_dto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/global/app_colors.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../Constants/ImageConstants.dart';
import '../app_text.dart';

class ItemUser extends StatelessWidget {
  UserDto info;
  bool selected;
  bool isDisabled;
  final onClick;

  ItemUser({Key? key, required this.info, required this.selected, this.onClick, this.isDisabled=false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        if(!isDisabled){
          onClick();
        }
      },
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 10),
              ClipOval(
                  child: Opacity(
                    opacity: isDisabled ? 0.3 : 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: selected ? ColorConstants.colorMain : Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(45),
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
                    ),
                  )
              ),
              
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                  opacity: isDisabled ? 0.3 : 1,
                    child: AppText(
                    text: info.nickname ?? '',
                    overflow: TextOverflow.ellipsis,
                    fontSize: 13,
                    maxLine: 1,
                    color: selected ? ColorConstants.colorMain : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  ),
                  SizedBox(height: 3,),
                  Opacity(
                    opacity: isDisabled ? 0.3 : 1,
                    child: AppText(
                    text: info.name ?? '',
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12,
                    maxLine: 1,
                    color: ColorConstants.halfWhite,
                  ),
                  ),
                ],
              )),
              const SizedBox(width: 6),
              Opacity(
                opacity: isDisabled ? 0.3 : 1,
                child: Image.asset(isDisabled ? ImageConstants.chatRadioOnDisabled : selected ? ImageConstants.chatRadioOn : ImageConstants.chatRadioOff,
                  height: 24, width: 24),
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
