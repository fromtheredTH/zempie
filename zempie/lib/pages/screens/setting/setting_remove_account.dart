


import 'dart:convert';
import 'dart:io';

import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/models/ReplyModel.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/components/BottomProfileWidget.dart';
import 'package:app/pages/components/GameSimpleItemWidget.dart';
import 'package:app/pages/components/GameUserPageWidget.dart';
import 'package:app/pages/components/ReplyWidget.dart';
import 'package:app/pages/components/app_button.dart';
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

class SettingRemoveAccountScreen extends StatefulWidget {
  SettingRemoveAccountScreen({super.key, });

  @override
  State<SettingRemoveAccountScreen> createState() => _SettingRemoveAccountScreen();
}

class _SettingRemoveAccountScreen extends BaseState<SettingRemoveAccountScreen> {

  TextEditingController msgController = TextEditingController();
  bool isSelected = false;

  @override
  void initState() {
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
                        text: "remove_account".tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),

                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 20,right: 20, top: 25),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: "resignup_limit_title".tr(),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),

                            SizedBox(height: 15,),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: "·",
                                  fontSize: 13,
                                  color: ColorConstants.halfWhite,
                                ),

                                SizedBox(width: 5,),

                                Expanded(child: AppText(
                                  text: "resignup_limit_desc".tr(),
                                  fontSize: 13,
                                  color: ColorConstants.halfWhite,
                                ),)
                              ],
                            ),
                            SizedBox(height: 5,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: "·",
                                  fontSize: 13,
                                  color: ColorConstants.halfWhite,
                                ),

                                SizedBox(width: 5,),

                                Expanded(child: AppText(
                                  text: "resignup_limit_desc_2".tr(),
                                  fontSize: 13,
                                  color: ColorConstants.halfWhite,
                                ),)
                              ],
                            ),
                            SizedBox(height: 5,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: "·",
                                  fontSize: 13,
                                  color: ColorConstants.halfWhite,
                                ),

                                SizedBox(width: 5,),

                                Expanded(child: AppText(
                                  text: "resignup_limit_desc_3".tr(),
                                  fontSize: 13,
                                  color: ColorConstants.halfWhite,
                                ),)
                              ],
                            ),
                            SizedBox(height: 5,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: "·",
                                  fontSize: 13,
                                  color: ColorConstants.halfWhite,
                                ),

                                SizedBox(width: 5,),

                                Expanded(child: AppText(
                                  text: "resignup_limit_desc_4".tr(),
                                  fontSize: 13,
                                  color: ColorConstants.halfWhite,
                                ),)
                              ],
                            ),

                            SizedBox(height: 25,),

                            AppText(
                              text: "remove_account_info".tr(),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),

                            SizedBox(height: 15,),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: "·",
                                  fontSize: 13,
                                  color: ColorConstants.halfWhite,
                                ),

                                SizedBox(width: 5,),

                                Expanded(child: AppText(
                                  text: "remove_account_info_desc_1".tr(),
                                  fontSize: 13,
                                  color: ColorConstants.halfWhite,
                                ),)
                              ],
                            ),
                            SizedBox(height: 5,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: "·",
                                  fontSize: 13,
                                  color: ColorConstants.halfWhite,
                                ),

                                SizedBox(width: 5,),

                                Expanded(child: AppText(
                                  text: "remove_account_info_desc_2".tr(),
                                  fontSize: 13,
                                  color: ColorConstants.halfWhite,
                                ),)
                              ],
                            ),

                            SizedBox(height: 25,),

                            AppText(
                              text: "why_delete_account".tr(),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),

                            SizedBox(height: 15,),

                            TextField(
                              maxLines: 5,
                              minLines: 5,
                              maxLength: 500,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: FontConstants.AppFont,
                                  fontSize: 13
                              ),
                              controller: msgController,
                              decoration: InputDecoration(
                                  counterText: "",
                                  hintText: "input".tr(),
                                  hintStyle: TextStyle(
                                      color: ColorConstants.halfWhite,
                                      fontSize: 13,
                                      fontFamily: FontConstants.AppFont,
                                      fontWeight: FontWeight.w400
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    gapPadding: 5,
                                    borderSide: BorderSide(
                                        color: ColorConstants.halfWhite,
                                        width: 0.5
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    gapPadding: 5,
                                    borderSide: BorderSide(
                                        color: ColorConstants.halfWhite,
                                        width: 0.0
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(10)
                              ),
                              onChanged: (text) {
                                setState(() {

                                });
                              },
                            ),

                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  isSelected = !isSelected;
                                });
                              },
                              child: Container(
                                height: 35,
                                margin: EdgeInsets.only(bottom: 5, top: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    isSelected ?
                                    Icon(Icons.check_box_rounded, size: 24, color: ColorConstants.colorMain,)
                                        : Icon(Icons.check_box_outline_blank_rounded, size: 24, color: ColorConstants.halfWhite,),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: AppText(
                                        text: "delete_account_agree".tr(),
                                        color: isSelected ? ColorConstants.colorMain : ColorConstants.halfWhite,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ]
                  ),
                ),
              )
            ),

            Container(
              margin: EdgeInsets.only(bottom: 15, left: 15, right: 15),
              child: AppButton(
                  disabled: !isSelected,
                  disableColor: ColorConstants.textGry,
                  margin: 0,
                  text: "send".tr(),
                  onTap: () async {

                    Get.back();
                  }
              ),
            )
          ],
        )
    );

  }
}