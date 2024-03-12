


import 'dart:convert';
import 'dart:io';

import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/models/ReplyModel.dart';
import 'package:app/models/SettingModel.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/components/BottomProfileWidget.dart';
import 'package:app/pages/components/GameSimpleItemWidget.dart';
import 'package:app/pages/components/GameUserPageWidget.dart';
import 'package:app/pages/components/ReplyWidget.dart';
import 'package:app/pages/components/item/TagCreator.dart';
import 'package:app/pages/screens/discover/GameDetailReplyScreen.dart';
import 'package:app/pages/screens/discover/GameFollowerScreen.dart';
import 'package:app/pages/screens/profile/ProfileFollowMemberScreen.dart';
import 'package:app/pages/screens/profile/profile_following_game_screen.dart';
import 'package:app/pages/screens/splash.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:rich_text_view/rich_text_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/utils.dart';
import '../../../models/PostFileModel.dart';
import '../../../models/PostModel.dart';
import '../../../models/res/btn_bottom_sheet_model.dart';
import '../../components/BtnBottomSheetWidget.dart';
import '../../components/GalleryBottomSheet.dart';
import '../../components/GameWidget.dart';
import '../../components/MyAssetPicker.dart';
import '../../components/UserListItemWidget.dart';
import '../../components/app_text.dart';
import '../../base/base_state.dart';
import '../../components/loading_widget.dart';
import '../../components/post_widget.dart';
import '../newPostScreen.dart';

class SettingAlarmScreen extends StatefulWidget {
  SettingAlarmScreen({super.key, });

  @override
  State<SettingAlarmScreen> createState() => _SettingAlarmScreen();
}

class _SettingAlarmScreen extends BaseState<SettingAlarmScreen> {
  UserModel user = Constants.user;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: ColorConstants.colorBg1,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            SizedBox(height: Get.height*0.07),
            Padding(
              padding:EdgeInsets.only(left: 15, right: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: (){
                            Get.back();
                          },
                          child: Icon(Icons.arrow_back_ios, color:Colors.white)),

                      AppText(
                        text: "알림 설정",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),

                ],
              ),
            ),
            SizedBox(height: 30),


            SizedBox(height: 10),

            Padding(
              padding: EdgeInsets.only(left: 20,right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15,),

                  AppText(
                    text: "수신 설정",
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 5,),

                  AppText(
                    text: "DM을 허용할 사용자를 선택해 주세요.",
                    fontSize: 13,
                    color: ColorConstants.halfWhite,
                    fontWeight: FontWeight.w400,
                  ),

                  SizedBox(height: 5,),

                  Container(
                    color: ColorConstants.halfWhite,
                    height: 0.5,
                    width: double.maxFinite,
                  ),

                  SizedBox(height: 20,),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "모두 일시 중단",
                                fontSize: 14,
                                textAlign: TextAlign.start,
                                fontWeight: FontWeight.w700,
                              ),

                              SizedBox(height: 5,),

                              AppText(
                                text: "모든 알림을 중단합니다.",
                                fontSize: 12,
                                textAlign: TextAlign.start,
                                color: ColorConstants.halfWhite,
                              )
                            ],
                          )
                      ),

                      FlutterSwitch(
                        value: user.setting.alarm,
                        width: 40,
                        height: 24,
                        activeColor: ColorConstants.colorMain,
                        activeToggleColor: ColorConstants.white,
                        inactiveColor: ColorConstants.textGry,
                        inactiveToggleColor: ColorConstants.white,
                        toggleSize: 20,
                        padding: 3,
                        onToggle: (newValue) async {
                          var response = await DioClient.setAlarm("notify_alarm", newValue);
                          setState(() {
                            user.setting = SettingModel.fromJson(response.data["result"]);
                          });
                        },
                      ),
                    ],
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 12),
                    height: 0.5,
                    color: ColorConstants.halfWhite,
                    width: double.maxFinite,
                  ),

                  SizedBox(height: 15,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "댓글",
                                fontSize: 14,
                                textAlign: TextAlign.start,
                                fontWeight: FontWeight.w700,
                              ),

                              SizedBox(height: 5,),

                              AppText(
                                text: "누군가 내 게시물에 댓글을 달면 알림이 전송됩니다.",
                                fontSize: 12,
                                textAlign: TextAlign.start,
                                color: ColorConstants.halfWhite,
                              )
                            ],
                          )
                      ),

                      FlutterSwitch(
                        value: user.setting.reply.state,
                        width: 40,
                        height: 24,
                        activeColor: ColorConstants.colorMain,
                        activeToggleColor: ColorConstants.white,
                        inactiveColor: ColorConstants.textGry,
                        inactiveToggleColor: ColorConstants.white,
                        toggleSize: 20,
                        padding: 3,
                        onToggle: (newValue) async {
                          var response = await DioClient.setAlarm("notify_reply", newValue);
                          setState(() {
                            user.setting = SettingModel.fromJson(response.data["result"]);
                          });
                        },
                      ),
                    ],
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 12),
                    height: 0.5,
                    color: ColorConstants.halfWhite,
                    width: double.maxFinite,
                  ),

                  SizedBox(height: 15,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "좋아요",
                                fontSize: 14,
                                textAlign: TextAlign.start,
                                fontWeight: FontWeight.w700,
                              ),

                              SizedBox(height: 5,),

                              AppText(
                                text: "다른 사람이 귀하의 댓글이나 게시물을 좋아할 때 알림입니다.",
                                fontSize: 12,
                                textAlign: TextAlign.start,
                                color: ColorConstants.halfWhite,
                              )
                            ],
                          )
                      ),

                      FlutterSwitch(
                        value: user.setting.like.state,
                        width: 40,
                        height: 24,
                        activeColor: ColorConstants.colorMain,
                        activeToggleColor: ColorConstants.white,
                        inactiveColor: ColorConstants.textGry,
                        inactiveToggleColor: ColorConstants.white,
                        toggleSize: 20,
                        padding: 3,
                        onToggle: (newValue) async {
                          var response = await DioClient.setAlarm("notify_like", newValue);
                          setState(() {
                            user.setting = SettingModel.fromJson(response.data["result"]);
                          });
                        },
                      ),
                    ],
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 12),
                    height: 0.5,
                    color: ColorConstants.halfWhite,
                    width: double.maxFinite,
                  ),

                  SizedBox(height: 15,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "팔로우",
                                fontSize: 14,
                                textAlign: TextAlign.start,
                                fontWeight: FontWeight.w700,
                              ),

                              SizedBox(height: 5,),

                              AppText(
                                text: "다른 사람이 귀하를 팔로우 할 때 알림입니다.",
                                fontSize: 12,
                                textAlign: TextAlign.start,
                                color: ColorConstants.halfWhite,
                              )
                            ],
                          )
                      ),

                      FlutterSwitch(
                        value: user.setting.follow.state,
                        width: 40,
                        height: 24,
                        activeColor: ColorConstants.colorMain,
                        activeToggleColor: ColorConstants.white,
                        inactiveColor: ColorConstants.textGry,
                        inactiveToggleColor: ColorConstants.white,
                        toggleSize: 20,
                        padding: 3,
                        onToggle: (newValue) async {
                          var response = await DioClient.setAlarm("notify_follow", newValue);
                          setState(() {
                            user.setting = SettingModel.fromJson(response.data["result"]);
                          });
                        },
                      ),
                    ],
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 12),
                    height: 0.5,
                    color: ColorConstants.halfWhite,
                    width: double.maxFinite,
                  ),

                  SizedBox(height: 15,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "DM",
                                fontSize: 14,
                                textAlign: TextAlign.start,
                                fontWeight: FontWeight.w700,
                              ),

                              SizedBox(height: 5,),

                              AppText(
                                text: "다른 사람이 나에게 DM을 전송했을 때 알림입니다.",
                                fontSize: 12,
                                textAlign: TextAlign.start,
                                color: ColorConstants.halfWhite,
                              )
                            ],
                          )
                      ),

                      FlutterSwitch(
                        value: user.setting.dm.state,
                        width: 40,
                        height: 24,
                        activeColor: ColorConstants.colorMain,
                        activeToggleColor: ColorConstants.white,
                        inactiveColor: ColorConstants.textGry,
                        inactiveToggleColor: ColorConstants.white,
                        toggleSize: 20,
                        padding: 3,
                        onToggle: (newValue) async {
                          var response = await DioClient.setAlarm("notify_chat", newValue);
                          setState(() {
                            user.setting = SettingModel.fromJson(response.data["result"]);
                          });
                        },
                      ),
                    ],
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 12),
                    height: 0.5,
                    color: ColorConstants.halfWhite,
                    width: double.maxFinite,
                  ),

                  SizedBox(height: 15,),
                ],
              ),
            ),


          ],
        )
    );

  }
}