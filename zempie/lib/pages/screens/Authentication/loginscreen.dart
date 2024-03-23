import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:app/Constants/utils.dart';
import 'package:app/controller/join_membership_controller.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/base/base_state.dart';
import 'package:app/pages/base/page_layout.dart';
import 'package:app/pages/screens/Authentication/regist_city_screen.dart';
import 'package:app/pages/screens/Authentication/regist_country_screen.dart';
import 'package:app/pages/screens/Authentication/regist_game_genre_screen.dart';
import 'package:app/pages/screens/Authentication/regist_genre_screen.dart';
import 'package:app/pages/screens/Authentication/regist_job_dept_screen.dart';
import 'package:app/pages/screens/Authentication/regist_job_group_screen.dart';
import 'package:app/pages/screens/Authentication/regist_job_position_screen.dart';
import 'package:app/pages/screens/bottomnavigationscreen/bottomNavBarScreen.dart';
import 'package:app/pages/screens/joinmembership/jointhemembership.dart';
import 'package:app/pages/screens/joinmembership/membershipconfirmationscreen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/Constants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../controller/login_controller.dart';
import '../../../global/global.dart';
import '../../../helpers/common_util.dart';
import '../../../models/UserAuthModel.dart';
import '../../../models/UserAuthModel.dart' as model;
import '../../../service/social_service.dart';
import '../../components/app_text.dart';
import 'forget_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreen createState() => _LoginScreen();
}


class _LoginScreen extends BaseState<LoginScreen> {

  LoginController controller =Get.put(LoginController());
  RxBool isVisiblePassword = true.obs;
  bool isOnlySocial = true;

  Future<void> onClickLogin() async {
    try {
      final data = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: controller.emailController.text,
        password: controller.passwordController.text,
      );

      String token = "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}";
      var response = await apiP.userInfo(token);
      UserModel user = UserModel.fromJson(response.data["result"]["user"]);
      hideLoading();
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
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('authProvider', "email");
        prefs.setString('id', controller.emailController.text);
        prefs.setString('pwd', controller.passwordController.text);
        Constants.getUserInfo(true,context, apiP);
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      hideLoading();
      showToast('${e.code}:${e.message ?? ''}');
    }
  }

  Future<void> socialLogin(UserSocialInfo userInfo) async {
    try {
      String token = "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}";
      var response = await apiP.userInfo(token);
      hideLoading();
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
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('authProvider', userInfo.authProvider.name);
        prefs.setString('accessToken', userInfo.accessToken ?? "");
        prefs.setString('idToken', userInfo.refreshToken ?? "");
        Constants.getUserInfo(true,context, apiP);
      }
    } catch(e) {
      print(e);
      hideLoading();
      Get.to(JoinTheMembership(socialInfo: userInfo,));
    }


  }

  Future<bool> onKeyboardHide() async {
    hideKeyboard();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      isAvoidResize: false,
      onTap: onKeyboardHide,
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: ColorConstants.colorBg1,
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20,),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Expanded(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(child: SvgPicture.asset(ImageConstants.appLogo)),
                        SizedBox(
                          height: 30,
                        ),
                        AppText(
                          text: "Playground for Game Developers!",
                          color: ColorConstants.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10,),
                        AppText(
                          text: "Join our Game Developers’ Social Network -\n Where Innovation Meets Imagination",
                          color: ColorConstants.halfWhite,
                          fontSize: 14,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
              ),

              if(!isOnlySocial)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.5)),
                      ),
                      child: TextField(
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        cursorColor: Color(0xFFFFFFFF).withOpacity(0.7),
                        controller:controller.emailController,
                        onChanged: (text){
                          controller.emailValidationText.value = "";
                        },
                        decoration: InputDecoration(
                          border:InputBorder.none,
                          filled: true,
                          fillColor: Color(0xFFFFFFFF).withOpacity(0.1),
                          prefixIcon: Container(
                            margin:EdgeInsets.only(right: 15),
                            width: 50,
                            height: 50,
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(topLeft:Radius.circular(5.0),bottomLeft: Radius.circular(5.0)),
                            ),
                            child: SvgPicture.asset(
                              ImageConstants.user,
                              width: 25,
                              height: 25,
                            ),
                          ),
                          prefixIconColor: Colors.amber,
                          prefixIconConstraints:
                          BoxConstraints(minWidth: 40, minHeight: 40),
                          hintText: "email_address".tr(),
                          hintStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: FontConstants.AppFont,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    Obx(() => Text(controller.emailValidationText.value,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Color(0xFFEB5757),
                      ),
                    )),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.5)),
                        ),
                        child: Obx(() =>
                            TextField(
                              controller: controller.passwordController,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              obscureText: isVisiblePassword.value,
                              decoration: InputDecoration(
                                border:InputBorder.none,
                                filled: true,
                                fillColor: Color(0xFFFFFFFF).withOpacity(0.1),
                                prefixIcon: Container(
                                  margin:EdgeInsets.only(right: 15),
                                  width: 50,
                                  height: 50,
                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.only(topLeft:Radius.circular(5.0),bottomLeft: Radius.circular(5.0)),
                                  ),
                                  child: SvgPicture.asset(
                                    ImageConstants.lock,
                                    width: 25,
                                    height: 25,
                                  ),
                                ),
                                prefixIconColor: Colors.amber,
                                prefixIconConstraints:
                                const BoxConstraints(minWidth: 40, minHeight: 40),
                                suffixIcon: GestureDetector(
                                  onTap: (){
                                    isVisiblePassword.value = !isVisiblePassword.value;
                                  },
                                  child: SvgPicture.asset(ImageConstants.eyeButton).paddingOnly(right: 10),
                                ),
                                suffixIconConstraints: BoxConstraints(
                                    minWidth: 20, minHeight: 20
                                ),
                                hintText: "pw_hint".tr(),
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontFamily: FontConstants.AppFont,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                        )
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: (){
                        Get.to(ForgetScreen());
                      },
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: AppText(
                          text: "비밀번호를 잊으셨습니까?",
                          textAlign: TextAlign.end,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (!EmailValidator.validate(controller.emailController.text,true)) { // Use EmailValidator.validate() to validate email
                          controller.emailValidationText.value="올바른 이메일 형식을 작성해 주세요.";
                        } else{
                          if(controller.emailController.text.isEmpty){
                            showToast("please_input_email".tr());
                            return;
                          }else if(controller.passwordController.text.isEmpty){
                            showToast("please_input_password".tr());
                            return;
                          }
                          var emailResponse = await DioClient.checkEmail(controller.emailController.text);

                          if(emailResponse.data["result"] is bool && !emailResponse.data["result"]){
                            controller.emailValidationText.value="존재하지 않는 이메일입니다. 회원가입을 진행해주세요.";
                            return;
                          }
                          showLoading();
                          controller.emailValidationText.value = "";
                          onClickLogin();
                        }
                      },
                      child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Color(0xFFE99315),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: AppText(
                              text: "로그인",
                              fontWeight:FontWeight.w700,
                              fontSize: 16,
                            ),
                          )
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: AppText(
                        text: "- 또는 -",
                        textAlign: TextAlign.center,
                        fontSize: 12,
                        color: ColorConstants.halfWhite,
                      ),
                    ),
                  ],
                ),

              GestureDetector(
                onTap: () async {
                  Utils.showDialogWidget(context);
                  SocialService socialService = GetIt.I.get<SocialService>();
                  UserSocialInfo? socialInfo = await socialService.getProfile(model.AuthProvider.google);
                  if(socialInfo != null) {
                    socialLogin(socialInfo);
                  }
                  Get.back();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: isOnlySocial ? 10 : 5),
                  padding: EdgeInsets.symmetric(vertical: 12,horizontal: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                          width:10
                      ),
                      Flexible(
                          child: SvgPicture.asset(ImageConstants.googleLogo)),
                      const SizedBox(
                          width:10
                      ),
                      Flexible(
                        child: AppText(
                          text: "구글 계정으로 로그인",
                          color: ColorConstants.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: () async {
                  showLoading();
                  SocialService socialService = GetIt.I.get<SocialService>();
                  UserSocialInfo? socialInfo = await socialService.getProfile(model.AuthProvider.facebook);
                  if(socialInfo != null) {
                    socialLogin(socialInfo);
                  }
                  hideLoading();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: isOnlySocial ? 10 : 5),
                  padding: EdgeInsets.symmetric(vertical: 12,horizontal: 10),
                  decoration: BoxDecoration(
                    color: Color(0xff39579A).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                          width:10
                      ),
                      Container(
                        child: Image.asset(ImageConstants.facebookLogo),
                        height: 25,
                        width: 25,),

                      SizedBox(width: 15,),
                      Flexible(
                        flex: 2,
                        child: AppText(
                          text: "페이스북 계정으로 로그인",
                          color: ColorConstants.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  SocialService socialService = GetIt.I.get<SocialService>();
                  UserSocialInfo? socialInfo = await socialService.getProfile(model.AuthProvider.apple);
                  if(socialInfo != null) {
                    socialLogin(socialInfo);
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: isOnlySocial ? 10 : 5),
                  padding: EdgeInsets.symmetric(vertical: 12,horizontal: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFF000000),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                          width:10
                      ),
                      Flexible(
                          child: SvgPicture.asset(ImageConstants.appleLogo, height: 27,width: 27)),
                      const SizedBox(
                          width:10
                      ),
                      Flexible(
                        child: AppText(
                          text: "애플 계정으로 로그인",
                          color: ColorConstants.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                  height:10
              ),

              !isOnlySocial ?
              ElevatedButton(
                  onPressed: () {
                    Get.to(JoinTheMembership());
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(Get.width, 50),
                      backgroundColor: Color(0xFFF1A1C29),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(color: Color(0xFFFFFFFF).withOpacity(0.5)),
                      )),
                  child: Center(
                    child: AppText(
                      text: "회원가입",
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  )
              ).paddingSymmetric(vertical: 10)
              : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        isOnlySocial = false;
                      });
                    },
                    child: AppText(
                      text: "Sign-in with email",
                      fontSize: 14,
                      textDecoration: TextDecoration.underline,
                      color: ColorConstants.halfWhite,
                    ),
                  ),

                  SizedBox(height: 15,),

                  GestureDetector(
                    onTap: (){
                      Get.to(JoinTheMembership());
                    },
                    child: AppText(
                      text: "Sign-up",
                      fontSize: 14,
                      textDecoration: TextDecoration.underline,
                      color: ColorConstants.halfWhite,
                    ),
                  ),
                ],
              ),


              SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 20
              ),
            ],
          ),
        ),
      ),
    );
  }
}
