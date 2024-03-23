

import 'package:app/Constants/utils.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/base/page_layout.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/Constants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../controller/join_membership_controller.dart';
import '../../../global/DioClient.dart';
import '../../../models/UserAuthModel.dart';
import '../../base/base_state.dart';
import '../../components/app_text.dart';
import '../../components/app_text_field.dart';
import '../Authentication/regist_city_screen.dart';
import '../Authentication/regist_country_screen.dart';
import '../Authentication/regist_game_genre_screen.dart';
import '../Authentication/regist_genre_screen.dart';
import '../Authentication/regist_job_dept_screen.dart';
import '../Authentication/regist_job_group_screen.dart';
import '../Authentication/regist_job_position_screen.dart';

class JoinTheMembership extends StatefulWidget {
   JoinTheMembership({super.key, this.socialInfo});
   UserSocialInfo? socialInfo;

  @override
  State<JoinTheMembership> createState() => _JoinTheMembershipState();
}


class _JoinTheMembershipState extends BaseState<JoinTheMembership> {

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  RxBool isTapEmailOkBtn = false.obs;
  RxBool isEmailEmpty = true.obs;
  RxBool isEmailCorrect = true.obs;
  RxBool isEmailNotDuplicate = true.obs;

  RxBool isTapNicknameOkBtn = false.obs;
  RxBool isNicknameEmpty = true.obs;
  RxBool isNicknameLengthCorrect = true.obs;
  RxBool isNicknameCorrect = true.obs;
  RxBool isNicknameNotDuplicate = true.obs;

  RxBool isTapNameOkBtn = false.obs;
  RxBool isNameEmpty = true.obs;
  RxBool isNameCorrect = true.obs;

  RxBool isTapPasswordOkBtn = false.obs;
  RxBool isPasswordEmpty = true.obs;
  RxBool isPasswordCorrect = true.obs;

  RxBool isTapPasswordConfirmOkBtn = false.obs;
  RxBool isPasswordConfirmCorrect = true.obs;

  RxBool isEveryOneAgrees = false.obs;
  RxBool isAgreeTermOfServices = false.obs;
  RxBool isAgreeToPersonalInfo = false.obs;
  RxBool isAgreeToMarketingPromotion = false.obs;

  void setAgree() {
    if(!isAgreeTermOfServices.value || !isAgreeToPersonalInfo.value || !isAgreeToMarketingPromotion.value) {
      isEveryOneAgrees.value = false;
    }else if(isAgreeTermOfServices.value && isAgreeToPersonalInfo.value && isAgreeToMarketingPromotion.value) {
      isEveryOneAgrees.value = true;
    }
  }

  void setAllAgree() {
    isAgreeTermOfServices.value = isEveryOneAgrees.value;
    isAgreeToPersonalInfo.value = isEveryOneAgrees.value;
    isAgreeToMarketingPromotion.value = isEveryOneAgrees.value;
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
        child: Scaffold(
          backgroundColor: ColorConstants.colorBg1,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding:EdgeInsets.only(left: 15, right: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: (){
                            Get.back();
                          },
                          child: Icon(Icons.arrow_back_ios, color:Colors.white)),
                      AppText(
                        text: "signup".tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),

                    ],
                  ),

                  Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 25),
                            AppText(
                              text: "Welcome to Zempie!",
                              fontSize: 18,
                            ),
                            SizedBox(height: Get.height*0.05),

                            widget.socialInfo != null ?
                            Container(
                              width: double.maxFinite,
                              child: AppText(
                                text: widget.socialInfo!.email!,
                                fontSize: 14,
                                color: ColorConstants.halfWhite,
                              ),
                            )
                                : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                AppTextField(
                                  textController: emailController,
                                  onChanged: (value) {
                                    isTapEmailOkBtn.value = false;
                                    isEmailEmpty.value = value.isEmpty;
                                    isEmailNotDuplicate.value = true;
                                    if(!GetUtils.isEmail(value) && value.isNotEmpty) {
                                      isEmailCorrect.value = false;
                                    }else{
                                      isEmailCorrect.value = true;

                                      DioClient.checkEmail(value).then((value) {
                                        if(value.data["result"] is bool){
                                          isEmailNotDuplicate.value = false;
                                        }else{
                                          isEmailNotDuplicate.value = true;
                                        }
                                      });

                                    }
                                  },
                                  hintText: "email".tr(),
                                  textColor: Colors.white,
                                  textColorHint: ColorConstants.halfWhite,
                                ),

                                SizedBox(height: 5,),

                                Obx(() => AppText(
                                  text:
                                  isEmailCorrect.value && isEmailNotDuplicate.value && isEmailEmpty.value ? "please_input_email_address".tr() :
                                  isEmailCorrect.value && isEmailNotDuplicate.value ? "correct_email".tr() :
                                  !isEmailCorrect.value ? "email_guide_incorrect".tr()
                                      : "already_email".tr(),
                                  color: isEmailCorrect.value && isEmailNotDuplicate.value && isEmailEmpty.value ? isTapEmailOkBtn.value ? ColorConstants.red : ColorConstants.halfWhite :
                                  isEmailCorrect.value && isEmailNotDuplicate.value ? ColorConstants.halfWhite :
                                  !isEmailCorrect.value ? ColorConstants.red
                                      : ColorConstants.red,
                                  fontSize: 11,
                                  maxLine: 2,
                                ))
                              ],
                            ),

                            SizedBox(height: Get.height*0.01),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                AppTextField(
                                  textController: nicknameController,
                                  onChanged: (value) {
                                    isTapNicknameOkBtn.value = false;
                                    isNicknameEmpty.value = value.isEmpty;
                                    isNicknameNotDuplicate.value = true;
                                    if(value.isNotEmpty && value.length < 4) {
                                      isNicknameLengthCorrect.value = false;
                                    }else{
                                      isNicknameLengthCorrect.value = true;
                                      if(!GetUtils.hasMatch(value,r'^(?=.*[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ])[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ._]{4,15}$')){
                                        isNicknameCorrect.value = false;
                                      }else{
                                        isNicknameCorrect.value = true;
                                        DioClient.checkNickname(value).then((value) {
                                          if(value.data["result"]["success"] is bool){
                                            isNicknameNotDuplicate.value = !value.data["result"]["success"];
                                          }
                                        });
                                      }
                                    }
                                  },
                                  hintText: "nickname".tr(),
                                  textColor: Colors.white,
                                  textColorHint: ColorConstants.halfWhite,
                                ),

                                SizedBox(height: 5,),

                                Obx(() => AppText(
                                  text:
                                  isNicknameEmpty.value ? "please_input_nickname".tr() :
                                  !isNicknameLengthCorrect.value ? "nickname_length_incorrect".tr() :
                                  !isNicknameNotDuplicate.value ? "already_use_nickname".tr() :
                                  !isNicknameCorrect.value ? "nickname_format_guide".tr() :
                                  "enable_nickname".tr(),
                                  color: isNicknameEmpty.value ? ColorConstants.halfWhite :
                                  !isNicknameLengthCorrect.value ? ColorConstants.red :
                                  !isNicknameNotDuplicate.value ? ColorConstants.red :
                                  !isNicknameCorrect.value ? ColorConstants.red :
                                  ColorConstants.halfWhite,
                                  fontSize: 11,
                                  maxLine: 2,
                                ))
                              ],
                            ),

                            SizedBox(height: Get.height*0.01),

                            widget.socialInfo?.nickname != null ?
                            Container(
                              width: double.maxFinite,
                              child: AppText(
                                text: widget.socialInfo!.nickname ?? "",
                                fontSize: 14,
                                color: ColorConstants.halfWhite,
                              ),
                            )
                                : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                AppTextField(
                                  textController: nameController,
                                  onChanged: (value) {
                                    isTapNameOkBtn.value = false;
                                    isNameEmpty.value = value.isEmpty;
                                    if(value.isNotEmpty && value.length < 2) {
                                      isNameCorrect.value = false;
                                    }else{
                                      isNameCorrect.value = true;
                                    }
                                  },
                                  hintText: "name".tr(),
                                  textColor: Colors.white,
                                  textColorHint: ColorConstants.halfWhite,
                                ),

                                SizedBox(height: 5,),

                                Obx(() => AppText(
                                  text:
                                  !isNameCorrect.value || isNameEmpty.value ? "name_length_incorrect".tr() :
                                  "enable_name".tr(),
                                  color: isNameEmpty.value && isTapNameOkBtn.value ? ColorConstants.red :
                                  !isNameCorrect.value ? ColorConstants.red
                                      : ColorConstants.halfWhite,

                                  fontSize: 11,
                                  maxLine: 2,
                                ))
                              ],
                            ),

                            SizedBox(height: Get.height*0.01),

                            if(widget.socialInfo == null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  AppTextField(
                                    textController: passwordController,
                                    obscureText: true,
                                    onChanged: (value) {
                                      isTapPasswordOkBtn.value = false;
                                      isPasswordEmpty.value = value.isEmpty;
                                      if(!GetUtils.hasMatch(value,r'^(?=.*[a-z])(?=.*[0-9!@#\$%^&*])[a-zA-Z0-9!@#\$%^&*]{6,20}$')) {
                                        isPasswordCorrect.value = false;
                                      }else{
                                        isPasswordCorrect.value = true;
                                      }
                                    },
                                    hintText: "password".tr(),
                                    textColor: Colors.white,
                                    textColorHint: ColorConstants.halfWhite,
                                  ),

                                  SizedBox(height: 5,),

                                  Obx(() => AppText(
                                    text:
                                    "password_format_guide".tr(),
                                    color: isPasswordCorrect.value && isPasswordEmpty.value && isTapPasswordOkBtn.value ? ColorConstants.red :
                                    !isPasswordCorrect.value && !isPasswordEmpty.value ? ColorConstants.red : ColorConstants.halfWhite,
                                    fontSize: 11,
                                    maxLine: 2,
                                  ))
                                ],
                              ),

                            SizedBox(height: Get.height*0.01),

                            if(widget.socialInfo == null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  AppTextField(
                                    textController: passwordConfirmController,
                                    obscureText: true,
                                    onChanged: (value) {
                                      isTapPasswordConfirmOkBtn.value = false;
                                      isPasswordConfirmCorrect.value = true;
                                    },
                                    hintText: "password_confirm".tr(),
                                    textColor: Colors.white,
                                    textColorHint: ColorConstants.halfWhite,
                                  ),

                                  SizedBox(height: 5,),

                                  Obx(() => AppText(
                                    text:
                                    isTapPasswordConfirmOkBtn.value && !isPasswordConfirmCorrect.value ? "check_password".tr() : "",
                                    color: ColorConstants.red,
                                    fontSize: 11,
                                    maxLine: 2,
                                  ))
                                ],
                              ),

                            Container(
                              margin: EdgeInsets.only(top: 15),
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: ColorConstants.white10Percent
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Container(
                                    height: 35,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Obx(() => SizedBox(
                                          width:30,
                                          child: Checkbox(
                                            activeColor: ColorConstants.yellow,
                                            checkColor: ColorConstants.white,
                                            value: isEveryOneAgrees.value,
                                            onChanged: (bool? value) {
                                              isEveryOneAgrees.value = value!;
                                              setAllAgree();
                                            },
                                          ),
                                        )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: AppText(
                                            text: "all_agree".tr(),
                                            color: ColorConstants.halfWhite,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    height: 35,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Obx(() => SizedBox(
                                          width:30,
                                          child: Checkbox(
                                            activeColor: ColorConstants.yellow,
                                            checkColor: ColorConstants.white,
                                            value: isAgreeTermOfServices.value,
                                            onChanged: (bool? value) {
                                              isAgreeTermOfServices.value = value!;
                                              setAgree();
                                            },
                                          ),
                                        )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: AppText(
                                            text: "service_agree".tr(),
                                            color: ColorConstants.halfWhite,
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            if(Constants.languageCode == "ko") {
                                              Utils.urlLaunch("https://zempie.com/ko/terms");
                                            }else{
                                              Utils.urlLaunch("https://zempie.com/myaccount/terms");
                                            }
                                          },
                                          child: AppText(
                                            text: "see".tr(),
                                            color: ColorConstants.white,
                                            fontSize: 12,
                                            textDecoration: TextDecoration.underline,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                                  Container(
                                    height: 35,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Obx(() => SizedBox(
                                          width:30,
                                          child: Checkbox(
                                            activeColor: ColorConstants.yellow,
                                            checkColor: ColorConstants.white,
                                            value: isAgreeToPersonalInfo.value,
                                            onChanged: (bool? value) {
                                              isAgreeToPersonalInfo.value = value!;
                                              setAgree();
                                            },
                                          ),
                                        )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: AppText(
                                            text: "personal_agree".tr(),
                                            color: ColorConstants.halfWhite,
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            if(Constants.languageCode == "ko") {
                                              Utils.urlLaunch("https://zempie.com/ko/terms");
                                            }else{
                                              Utils.urlLaunch("https://zempie.com/myaccount/terms");
                                            }

                                          },
                                          child: AppText(
                                            text: "see".tr(),
                                            color: ColorConstants.white,
                                            fontSize: 12,
                                            textDecoration: TextDecoration.underline,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                                  Container(
                                    height: 35,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Obx(() => SizedBox(
                                          width:30,
                                          child: Checkbox(
                                            activeColor: ColorConstants.yellow,
                                            checkColor: ColorConstants.white,
                                            value: isAgreeToMarketingPromotion.value,
                                            onChanged: (bool? value) {
                                              isAgreeToMarketingPromotion.value = value!;
                                              setAgree();
                                            },
                                          ),
                                        )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: AppText(
                                            text: "marketing_agree".tr(),
                                            color: ColorConstants.halfWhite,
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            if(Constants.languageCode == "ko") {
                                              Utils.urlLaunch(
                                                  "https://zempie.com/ko/terms-marketing");
                                            }else{
                                              Utils.urlLaunch(
                                                  "https://zempie.com/en/terms-marketing");
                                            }
                                          },
                                          child: AppText(
                                            text: "see".tr(),
                                            color: ColorConstants.white,
                                            fontSize: 12,
                                            textDecoration: TextDecoration.underline,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )

                          ],
                        ),
                      )
                  ),

                  GestureDetector(
                    onTap: () async {
                      Utils.showDialogWidget(context);
                      if(!isAgreeTermOfServices.value || !isAgreeToPersonalInfo.value) {
                        Get.back();
                        return;
                      }

                      isTapEmailOkBtn.value = true;
                      isTapNicknameOkBtn.value = true;
                      isTapNameOkBtn.value = true;
                      isTapPasswordOkBtn.value = true;
                      isTapPasswordConfirmOkBtn.value = true;


                      if(widget.socialInfo != null){
                        if(isNicknameEmpty.value || !isNicknameCorrect.value){
                          Get.back();
                          return;
                        }

                      }else{
                        if(!isEmailCorrect.value || isEmailEmpty.value || isNicknameEmpty.value
                            || !isNicknameCorrect.value || isNameEmpty.value || !isNameCorrect.value
                            || isPasswordEmpty.value){
                          Get.back();
                          return;
                        }else {

                          var emailResponse = await DioClient.checkEmail(emailController.text);
                          var nicknameResponse = await DioClient.checkNickname(nicknameController.text);

                          if(emailResponse.data["result"] is bool){
                            isEmailNotDuplicate.value = emailResponse.data["result"];
                          }

                          if(nicknameResponse.data["result"]["success"]){
                            isNicknameNotDuplicate.value = false;
                          }

                          if(passwordController.text != passwordConfirmController.text) {
                            isPasswordConfirmCorrect.value = false;
                            Get.back();
                            return;
                          }

                          if(!isEmailNotDuplicate.value || !isNicknameNotDuplicate.value){
                            Get.back();
                            return;
                          }


                          try {
                            await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordConfirmController.text,
                            );
                            await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordConfirmController.text,
                            );
                          } on FirebaseAuthException catch (e) {
                            Utils.showToast(e.message ?? "");
                            print(e.code);
                          }
                        }
                      }

                      var signupResponse = await DioClient.signUp(nicknameController.text, nameController.text);
                      UserModel user = UserModel.fromJson(signupResponse.data["result"]["user"]);
                      Get.back();
                      Utils.showToast("complete_sign_up".tr());
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
                        Get.back();
                      }
                    },
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Obx(() => Container(
                        decoration: BoxDecoration(
                            color: isAgreeTermOfServices.value && isAgreeToPersonalInfo.value ? ColorConstants.yellow : ColorConstants.textGry,
                            borderRadius: BorderRadius.circular(4)),
                        height: 48,
                        width: Get.width ,
                        child: Center(
                          child: AppText(
                            text: "next".tr(),
                            fontSize: 16,
                            fontFamily: FontConstants.AppFont,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )),
                    ),
                  ),
                  SizedBox(height: Get.height*0.02),
                ],
              ),
            ),
          ),
        )
    );
  }
}
