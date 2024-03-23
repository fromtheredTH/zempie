import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:app/pages/components/dialog.dart';
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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/Constants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/utils.dart';
import '../../models/User.dart';
import 'Authentication/regist_city_screen.dart';
import 'Authentication/regist_country_screen.dart';
import 'Authentication/regist_game_genre_screen.dart';
import 'Authentication/regist_genre_screen.dart';
import 'Authentication/regist_job_dept_screen.dart';
import 'Authentication/regist_job_group_screen.dart';
import 'Authentication/regist_job_position_screen.dart';
import 'joinmembership/jointhemembership.dart';

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
    var response = await DioClient.getVersion();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String recentVersion = "";
    if(Platform.isAndroid){
      recentVersion = response.data["result"]["android"];
    }else{
      recentVersion = response.data["result"]["ios"];
    }
    if(packageInfo.version.compareTo(recentVersion) < 0){
      AppDialog.showOneDialog(context, "version_title".tr(), "version_description".tr(), () {
        if(Platform.isAndroid){
          Utils.urlLaunch("https://play.google.com/store/apps/details?id=com.fromthered.zempie");
        }else{
          Utils.urlLaunch("https://apps.apple.com/kr/app/zempie/id6449574630");
        }
      });
      return;
    }
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('first_run') ?? true) {
      FlutterSecureStorage storage = FlutterSecureStorage();

      await storage.deleteAll();
      await FirebaseAuth.instance.signOut();

      prefs.setBool('first_run', false);
    }
    print(response);
    User? user = await FirebaseAuth.instance.currentUser;
    if(user != null){
      try {
        String token = "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}";
        var response = await apiP.userInfo(token);
        UserModel user = UserModel.fromJson(response.data["result"]["user"]);

        if(user.profile.jobDept.isEmpty){
          Get.to(RegistJobDeptScreen(user: user));
        }else if(user.profile.jobGroup.isEmpty){
          Get.to(RegistJobGroupScreen(user: user));
        }else if(user.profile.jobPosition.isEmpty){
          Get.to(RegistJobPositionScreen(user: user));
        }else if(user.profile.country.isEmpty){
          Get.to(RegistCountryScreen(user: user));
        }else if(user.profile.city.isEmpty){
          Get.to(RegistCityScreen(user: user));
        }else if(user.profile.interestGameGenre.isEmpty){
          Get.to(RegistGameGenreScreen(user: user));
        }else if(user.profile.stateMsg.isEmpty){
          Get.to(RegistGenreScreen(user: user));
        }else {
          Constants.getUserInfo(false,context, apiP);
        }
      } catch(e) {
        print(e);
        Get.off(OnBoardScreen(),transition: Transition.rightToLeft);
      }
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
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(ImageConstants.splashLogo,width: Get.width*0.3, fit: BoxFit.cover,),

                SizedBox(height: 20,),
                AppText(
                    text: "Today’s Game Developers Community",
                  fontSize: 13,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
