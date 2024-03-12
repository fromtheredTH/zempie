


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
import 'package:app/pages/components/item/TagCreator.dart';
import 'package:app/pages/screens/discover/GameDetailReplyScreen.dart';
import 'package:app/pages/screens/discover/GameFollowerScreen.dart';
import 'package:app/pages/screens/profile/ProfileFollowMemberScreen.dart';
import 'package:app/pages/screens/profile/profile_following_game_screen.dart';
import 'package:app/pages/screens/splash.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class SettingSecurityScreen extends StatefulWidget {
  SettingSecurityScreen({super.key, });

  @override
  State<SettingSecurityScreen> createState() => _SettingSecurityScreen();
}

class _SettingSecurityScreen extends BaseState<SettingSecurityScreen> {

  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if(Constants.user.idVerified){
      phoneController.text = Constants.user.verifiedInfo.mobileNum;
    }
    passwordEmailController.text = Constants.user.email;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: ColorConstants.colorBg1,
        resizeToAvoidBottomInset: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        text: "보안",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),

                ],
              ),
            ),
            SizedBox(height: 30),

           Container(
             margin: EdgeInsets.only(left: 20),
             child:  AppText(
               text: "본인인증",
               fontWeight: FontWeight.w700,
             ),
           ),

            SizedBox(height: 10,),

            Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorConstants.halfWhite,
                  width: 0.5
                ),
                borderRadius: BorderRadius.all(Radius.circular(4))
              ),
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 13,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400,
                        ),
                        readOnly: Constants.user.idVerified,
                        controller: phoneController,
                        decoration: InputDecoration(
                          filled: true,
                            fillColor: ColorConstants.colorBg1,
                            hintText: "휴대폰 본인인증이 필요합니다.",
                            hintStyle: TextStyle(
                              color: Color(0xFFFFFFFF).withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                              fontFamily: FontConstants.AppFont,
                              fontSize: 13,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              gapPadding: 5,
                              borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 0
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              gapPadding: 5,
                              borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 0
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0)),
                      ),
                  ),

                  SizedBox(width: 10,),

                  GestureDetector(
                    onTap: (){
                      if(phoneController.text.isEmpty){
                        Utils.showToast("휴대폰 번호를 입력해 주세요");
                        return;
                      }
                      if(!Constants.user.idVerified){
                        if(GetUtils.isPhoneNumber(phoneController.text)) {

                        }else{
                          Utils.showToast("휴대폰 번호 형식이 맞지 않습니다.");
                          return;
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Constants.user.idVerified ? ColorConstants.textGry : ColorConstants.colorMain
                      ),
                      child: AppText(
                        text: Constants.user.idVerified ? "인증완료" :"본인인증",
                        fontSize: 12,
                      ),
                    )
                  )
                ],
              ),
            ),

            SizedBox(height: 30,),

            Container(
              margin: EdgeInsets.only(left: 20),
              child:  AppText(
                text: "비밀번호 변경",
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 10,),

            Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: ColorConstants.halfWhite,
                      width: 0.5
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4))
              ),
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        color: ColorConstants.halfWhite,
                        fontSize: 13,
                        fontFamily: FontConstants.AppFont,
                        fontWeight: FontWeight.w400,
                      ),
                      readOnly: true,
                      controller: passwordEmailController,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: ColorConstants.colorBg1,
                          hintText: "",
                          hintStyle: TextStyle(
                            color: Color(0xFFFFFFFF).withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                            fontFamily: FontConstants.AppFont,
                            fontSize: 13,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            gapPadding: 5,
                            borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 0
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            gapPadding: 5,
                            borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 0
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0)),
                    ),
                  ),

                  SizedBox(width: 10,),

                  GestureDetector(
                      onTap: (){
                        FirebaseAuth.instance.sendPasswordResetEmail(email: Constants.user.email).then((error) {
                          Utils.showToast("비밀번호 재설정 링크를 전송하였습니다");
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Constants.user.idVerified ? ColorConstants.textGry : ColorConstants.colorMain
                        ),
                        child: AppText(
                          text: "재설정 링크 메일 발송",
                          fontSize: 12,
                        ),
                      )
                  )
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 20, top: 5),
              child:  AppText(
                text: "비밀번호 재설정 링크를 해당 메일로 발송합니다.",
                fontSize: 13,
                color: ColorConstants.halfWhite,
              ),
            ),

          ],
        )
    );

  }
}