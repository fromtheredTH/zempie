

import 'package:app/Constants/Constants.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/NotificationModel.dart';
import 'package:app/models/PostModel.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/components/BtnBottomSheetWidget.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:app/pages/screens/discover/DiscoverGameDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/ImageUtils.dart';
import '../../Constants/utils.dart';
import '../../models/res/btn_bottom_sheet_model.dart';
import '../base/base_state.dart';
import '../screens/discover/PostDetailScreen.dart';
import '../screens/profile/profile_screen.dart';
import 'item/TagCreator.dart';
import 'item/TagDev.dart';

class NotificationWidget extends StatefulWidget {
  NotificationWidget({Key? key, required this.notification, required this.deleteNotification, required this.userFollowing}) : super(key: key);
  NotificationModel notification;
  Function() deleteNotification;
  Function() userFollowing;

  @override
  State<NotificationWidget> createState() => _UserListItemWidget();
}

class _UserListItemWidget extends BaseState<NotificationWidget> {
  late UserModel user;

  @override
  void initState() {
    user = widget.notification.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if(widget.notification.type == 8){
                      Get.to(ProfileScreen(user: user));
                    }else if(widget.notification.type == 9 || widget.notification.type == 5){
                      // var response = await DioClient.getPostComment(widget.notification.targetId);
                      var response = await DioClient.getPost(widget.notification.targetId);
                      Get.to(PostDetailScreen(post: PostModel.fromJson(response.data)));
                      print(response);
                    }else if(widget.notification.type == 4 || widget.notification.type == 3){
                      var response = await DioClient.getPost(widget.notification.targetId);
                      Get.to(PostDetailScreen(post: PostModel.fromJson(response.data)));
                    }else if(widget.notification.type == 10){
                      var response = await DioClient.getChatRoomFromMessage(widget.notification.targetId);
                      print(response);
                    }else if(widget.notification.type == 20 || widget.notification.type == 22){
                      var response = await DioClient.getGameReply(widget.notification.targetId);
                      //게임 패스가 필요함
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 20,),

                      GestureDetector(
                        onTap: (){
                          Get.to(ProfileScreen(user: user));
                        },
                        child: ClipOval(
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle
                            ),
                            child: ImageUtils.ProfileImage(
                                user.picture,
                                45,
                                45
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 10,),

                      Expanded(
                        child: Text.rich(
                          maxLines: 2,
                          TextSpan(
                            text: user.nickname,
                            recognizer: TapGestureRecognizer()
                            ..onTapUp = (details) {
                              Get.to(ProfileScreen(user: user));
                            },
                            style: TextStyle(
                              color: ColorConstants.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              fontFamily: FontConstants.AppFont,
                              overflow: TextOverflow.ellipsis,
                            ),
                            children: <TextSpan>[
                              TextSpan(text: Constants.getNotificationStr(widget.notification.type),
                                  style: TextStyle(
                                    color: ColorConstants.white70Percent,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    fontFamily: FontConstants.AppFont,
                                    overflow: TextOverflow.ellipsis,
                                  )
                              ),

                              TextSpan(text: " ${Constants.getNotificationTime(widget.notification.createdAt)}",
                                  style: TextStyle(
                                    color: ColorConstants.halfWhite,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                    fontFamily: FontConstants.AppFont,
                                    overflow: TextOverflow.ellipsis,
                                  )
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
            ),


            Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              child: !user.isFollowing ?
              GestureDetector(
                onTap: () async {
                  setState(() {
                    user.isFollowing = true;
                  });
                  var response = await DioClient.postUserFollow(user.id);
                  setState(() {
                    widget.userFollowing();
                  });
                },
                child: ImageUtils.setImage(ImageConstants.followUser, 30, 30),
              ) : Container(),
            )

          ],
        ),

      ],
    );
  }
}
