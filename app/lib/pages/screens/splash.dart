import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:app/pages/screens/chat.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends BaseState<SplashPage> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwdController = TextEditingController();

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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = prefs.getString('id');
    final String? pwd = prefs.getString('pwd');
    setState(() {
      idController.text = id ?? '';
      pwdController.text = pwd ?? '';
      if (idController.text.isNotEmpty && pwdController.text.isNotEmpty) {
        onClickLogin();
      }
    });
  }

  Future<void> onClickLogin() async {
    hideKeyboard();

    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final allInfo = deviceInfo.data;

    if (idController.text.isEmpty) {
      showToast("id_hint".tr());
      return;
    }
    if (pwdController.text.isEmpty) {
      showToast("pw_hint".tr());
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: idController.text,
        password: pwdController.text,
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
          .then((value) {
        getUserInfo();
      }).catchError((Object obj) {
        getUserInfo();
      });
    } else {
      showToast("login_failed".tr());
    }
  }

  Future<void> getUserInfo() async {
    apiP.userInfo("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}").then((value) async {
      hideLoading();

      gCurrentId = value.result.user.id;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('id', idController.text);
      await prefs.setString('pwd', pwdController.text);

      Navigator.pushReplacement(context, SlideRightTransRoute(builder: (context) => const ChatPage()));
    }).catchError((Object obj) {
      hideLoading();
      showToast("connection_failed".tr());
    });
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return PageLayout(
        isLoading: isLoading,
        child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "id".tr(),
                          style: const TextStyle(color: appColorText1, fontSize: 16),
                        ),
                        Container(
                          height: 40,
                          child: Center(
                            child: TextField(
                              controller: idController,
                              cursorColor: Colors.black,
                              style: const TextStyle(color: appColorText1, fontSize: 16),
                              onEditingComplete: () => {node.nextFocus()},
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.start,
                              textAlignVertical: TextAlignVertical.center,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: EdgeInsets.zero,
                                hintText: 'id_hint'.tr(),
                                isDense: true,
                                hintStyle: TextStyle(color: appColorHint, fontSize: 16),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          color: appColorLightGrey,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "pw".tr(),
                          style: const TextStyle(color: appColorText1, fontSize: 16),
                        ),
                        Container(
                          height: 40,
                          child: Center(
                            child: TextField(
                              controller: pwdController,
                              cursorColor: Colors.black,
                              style: TextStyle(color: appColorText1, fontSize: 16),
                              onEditingComplete: onClickLogin,
                              keyboardType: TextInputType.visiblePassword,
                              textAlign: TextAlign.start,
                              textAlignVertical: TextAlignVertical.center,
                              textInputAction: TextInputAction.done,
                              obscureText: true,
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: EdgeInsets.zero,
                                hintText: 'pw_hint'.tr(),
                                isDense: true,
                                hintStyle: TextStyle(color: appColorHint, fontSize: 16),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          color: appColorLightGrey,
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: onClickLogin,
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: appColorRed,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                "login".tr(),
                                style: const TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }
}
