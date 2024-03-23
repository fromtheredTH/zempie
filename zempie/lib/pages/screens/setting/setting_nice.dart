


import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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

class SettingNiceScreen extends StatefulWidget {
  SettingNiceScreen({super.key,required this. encData, required this.integrityValue, required this.tokenVersionId, required this.request_no});
  String encData;
  String integrityValue;
  String tokenVersionId;
  String request_no;

  @override
  State<SettingNiceScreen> createState() => _SettingNiceScreen();
}

class _SettingNiceScreen extends BaseState<SettingNiceScreen> {

  final InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      cacheEnabled: true,
      clearCache: true,
      transparentBackground: true,
      useShouldOverrideUrlLoading: true,
      javaScriptEnabled: true,
      userAgent: "hmdsAgent",
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
      mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      initialScale: 100
    ),
    ios: IOSInAppWebViewOptions(
      useOnNavigationResponse: true,
      scrollsToTop: false,
      allowsInlineMediaPlayback: true,
    )
  );

  late String url;

  @override
  void initState() {

    String baseUrl = "https://nice.checkplus.co.kr/CheckPlusSafeModel/service.cb?";
    String encData = Uri.encodeComponent(widget.encData);
    String integrityValue = Uri.encodeComponent(widget.integrityValue);
    String tokenVersionId = Uri.encodeComponent(widget.tokenVersionId);
    String request_no = Uri.encodeComponent(widget.request_no);
    String queryUrl = "${"enc_data=${encData}&integrity_value=${integrityValue}&token_version_id=${tokenVersionId}&m=service&request_no=${request_no}"}";
    url = baseUrl + queryUrl;
    print(url);
    super.initState();
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
                        text: "setting_sicurity_nice".tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),

                ],
              ),
            ),
            SizedBox(height: 30),

            Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: Uri.parse(url),
                  ),
                  initialOptions: options,
                  onWebViewCreated: (controller) {
                    controller.addJavaScriptHandler(
                        handlerName: 'FlutterHandler',
                        callback: (arguments) {
                          print("나이스 리턴값 ${arguments[0]}");
                          Map<String ,dynamic> response = jsonDecode(arguments[0]);
                          if(response['isPass']) {
                            print("인증 성공");
                          }
                        }
                    );
                  },
                )
            )

          ],
        )
    );

  }
}