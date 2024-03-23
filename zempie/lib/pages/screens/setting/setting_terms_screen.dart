


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

class SettingTermsScreen extends StatefulWidget {
  SettingTermsScreen({super.key, });

  @override
  State<SettingTermsScreen> createState() => _SettingTermsScreen();
}

class _SettingTermsScreen extends BaseState<SettingTermsScreen> {


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
                        text: "terms".tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),

                ],
              ),
            ),
            SizedBox(height: 30),


            Padding(
              padding: EdgeInsets.only(left: 20,right: 20),
              child: Column(
                  children: [

                  ]
              ),
            )
          ],
        )
    );

  }
}