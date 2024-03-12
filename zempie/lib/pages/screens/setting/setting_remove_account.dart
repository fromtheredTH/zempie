


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
                        text: "계정 삭제",
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
                              text: "회원 재가입 제한",
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
                                  text: "탈퇴 후 재가입 시 신규 회원으로 가입되며, 탈퇴 전의 정보는 복원되지 않습니다.",
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
                                  text: "커뮤니티 서비스에 등록한 포스팅은 탈퇴 후에도 남으니 아이디 탈퇴 전 반드시 비공개 처리하거나 삭제해 주시기 바랍니다.",
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
                                  text: "매니저로 계신 커뮤니티가 존재하여도 회원 탈퇴가 가능하니 탈퇴 전 반드시 매니저 위임을 진행해 주셔야 합니다.",
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
                                  text: "사이버 머니가 남아있을 시, 탈퇴 정책에 의해 환불에 따른 수수료 지급 및 소액 잔액 미환급 등의 불이익이 있을 수 있습니다.",
                                  fontSize: 13,
                                  color: ColorConstants.halfWhite,
                                ),)
                              ],
                            ),

                            SizedBox(height: 25,),

                            AppText(
                              text: "개인정보 파기",
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
                                  text: "탈퇴 신청 후 3일의 유예 기간 동안 개인정보를 임시 보관하게 되며, 유예 기간 이후에는 회사의 회원 정보 는 즉시 파기됩니다.",
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
                                  text: "관계 법령의 규정에 의하여 보관할 필요가 있는 경우 회사는 수집 및 이용 목적 달성 후에도 관계 법령에서 정한 일정 기간 회원의 개인정보를 보관할 수 있습니다.",
                                  fontSize: 13,
                                  color: ColorConstants.halfWhite,
                                ),)
                              ],
                            ),

                            SizedBox(height: 25,),

                            AppText(
                              text: "탈퇴 사유 및 개선점 (선택)",
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
                                  hintText: "입력...",
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
                                        text: "회원탈퇴 유의사항을 모두 확인하였으며 회원 탈퇴에 동의합니다.",
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
                  text: "보내기",
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