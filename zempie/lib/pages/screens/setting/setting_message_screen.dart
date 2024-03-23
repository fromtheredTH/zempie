


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
import '../../components/BlockUserListItemWidget.dart';
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

class SettingMessageScreen extends StatefulWidget {
  SettingMessageScreen({super.key, });

  @override
  State<SettingMessageScreen> createState() => _SettingMessageScreen();
}

class _SettingMessageScreen extends BaseState<SettingMessageScreen> {
  UserModel user = Constants.user;
  int selectedIndex = 0;

  Future<void> setDMRange(int range) async {
    setState(() {
      selectedIndex = range - 1;
    });
    var response = await DioClient.setDMAlarmRange(range);
    Constants.user.setting = SettingModel.fromJson(response.data["result"]);
  }

  @override
  void initState() {
    selectedIndex = user.setting.dm.range-1;
    super.initState();
  }

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
                        text: "message_manage".tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),

                ],
              ),
            ),
            SizedBox(height: 10),

            Padding(
              padding: EdgeInsets.only(left: 20,right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15,),

                  AppText(
                    text: "alarm_receive_setting".tr(),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 5,),

                  AppText(
                    text: "alarm_receive_setting_desc".tr(),
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

                  GestureDetector(
                    onTap: () {
                      setDMRange(1);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          selectedIndex == 0 ? ImageConstants.radioButtonYellow : ImageConstants.radioButton ,
                          height: Get.height * 0.024,
                        ),

                        SizedBox(width: 5,),

                        AppText(
                          text: "setting_message_all".tr(),
                          color: selectedIndex == 0 ? ColorConstants.colorMain : ColorConstants.white,
                          fontSize: 14,
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 15,),

                  GestureDetector(
                    onTap: () {
                      setDMRange(2);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          selectedIndex == 1 ? ImageConstants.radioButtonYellow : ImageConstants.radioButton ,
                          height: Get.height * 0.024,
                        ),

                        SizedBox(width: 5,),

                        AppText(
                          text: "setting_message_follow".tr(),
                          color: selectedIndex == 1 ? ColorConstants.colorMain : ColorConstants.white,
                          fontSize: 14,
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 15,),

                  GestureDetector(
                    onTap: () {
                      setDMRange(3);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          selectedIndex == 2 ? ImageConstants.radioButtonYellow : ImageConstants.radioButton ,
                          height: Get.height * 0.024,
                        ),

                        SizedBox(width: 5,),

                        AppText(
                          text: "setting_message_no".tr(),
                          color: selectedIndex == 2 ? ColorConstants.colorMain : ColorConstants.white,
                          fontSize: 14,
                        )
                      ],
                    ),
                  ),

                ],
              ),
            ),



          ],
        )
    );

  }
}