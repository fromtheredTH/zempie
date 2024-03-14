import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:app/pages/screens/Authentication/loginscreen.dart';
import 'package:app/pages/screens/chat.dart';
import 'package:app/pages/screens/onboard_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:app/global/app_colors.dart';
import 'package:app/global/global.dart';
import 'package:app/global/local_service.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/helpers/transition.dart';
import 'package:app/models/dto/user_dto.dart';
import 'package:app/pages/base/base_state.dart';
import 'package:app/pages/base/page_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/Constants.dart';
import '../../Constants/ImageConstants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends BaseState<SplashPage> {

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> load() async {
    User? user = await FirebaseAuth.instance.currentUser;
    if(user != null){
      Constants.getUserInfo(false,context, apiP);
    }else{
      Get.off(OnBoardScreen(),transition: Transition.rightToLeft);
    }
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // String authProvider = prefs.getString("authProvider") ?? "";
    // if(authProvider.isNotEmpty){
    //   if(authProvider == "email"){
    //     final String? id = prefs.getString('id');
    //     final String? pwd = prefs.getString('pwd');
    //
    //     onClickLogin(id!, pwd!);
    //   }else if(authProvider == "google") {
    //     String accessToken = prefs.getString('accessToken') ?? "";
    //     String idToken = prefs.getString('idToken') ?? "";
    //
    //     final credential = GoogleAuthProvider.credential(
    //         accessToken: accessToken, idToken: idToken);
    //
    //     final data = await FirebaseAuth.instance.signInWithCredential(credential);
    //
    //     Constants.getUserInfo(false,context, apiP);
    //
    //   }else if(authProvider == "apple") {
    //     String accessToken = prefs.getString('accessToken') ?? "";
    //     String idToken = prefs.getString('idToken') ?? "";
    //
    //     final oauthCredential = OAuthProvider("apple.com").credential(
    //       idToken: accessToken,
    //       accessToken: idToken,
    //     );
    //
    //     final data = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    //
    //     Constants.getUserInfo(false,context, apiP);
    //
    //   }else if(authProvider == "facebook") {
    //     String accessToken = prefs.getString('accessToken') ?? "";
    //     String idToken = prefs.getString('idToken') ?? "";
    //
    //     final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken);
    //
    //     final data = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    //
    //     Constants.getUserInfo(false,context, apiP);
    //   }
    // }else {
    //   final bool isShowOnBoard = prefs.getBool('isShowOnBoard') ?? false;
    //   if(isShowOnBoard) {
    //     Get.to(LoginScreen(),transition: Transition.rightToLeft);
    //   }else{
    //     prefs.setBool("isShowOnBoard", true);
    //     Get.to(OnBoardScreen(),transition: Transition.rightToLeft);
    //   }
    // }
  }

  Future<void> onClickLogin(String id, String pwd) async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final allInfo = deviceInfo.data;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: id,
        password: pwd,
      );
    } on FirebaseAuthException catch (e) {
      print(e.code);
      showToast('${e.code}:${e.message ?? ''}');
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String? token = await currentUser.getIdToken();
      print("auth token = $token");

      String device_id = "";
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        device_id = androidInfo.id;
        const _androidIdPlugin = AndroidId();
        device_id = await _androidIdPlugin.getId() ?? '';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        device_id = iosInfo.identifierForVendor ?? '';
      }
      print("device_id = $device_id");

      //set fcm token
      Map<String, dynamic> body = {"token": gPushKey, "device_id": device_id};
      showLoading();
      apiC
          .setFcmToken("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", jsonEncode(body))
          .then((value) async {
        Constants.getUserInfo(false,context, apiP);
      }).catchError((Object obj) {
        Constants.getUserInfo(false,context, apiP);
      });
    } else {
      showToast("login_failed".tr());
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.colorBg1,
      body: Stack(
        children: [
          Center(
            child:SvgPicture.asset(ImageConstants.appLogo,fit: BoxFit.cover,),
          ),
        ],
      ),
    );
  }
}
