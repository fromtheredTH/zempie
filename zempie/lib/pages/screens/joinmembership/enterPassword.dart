

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../components/app_text.dart';
import '../../../controller/join_membership_controller.dart';
import '../../components/app_text_field.dart';
import 'membershipconfirmationscreen.dart';

class EnterPassword extends StatelessWidget {
   EnterPassword({super.key});

  final joinMembershipController = Get.put(JoinMembershipController());

   RxBool isPasswordTextEmpty = true.obs; // Initial button color
   RxBool isConfirmPasswordTextEmpty = true.obs; // Initial button color

  GlobalKey<FormState> joinMemberShipKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.colorBg1,
      body: Form(
        key:joinMemberShipKey,
        child: Padding(
         padding:EdgeInsets.only(left: 15, right: 15),
          child: Column(
           mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: Get.height*0.07),
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
                    text: "회원가입",
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: FontConstants.AppFont,
                    fontWeight: FontWeight.w700,
                  ),

                ],
              ),
              SizedBox(height: Get.height*0.08),
              AppText(
                text: "비밀번호",
                fontSize: 16,
                color: Colors.white,
                fontFamily: FontConstants.AppFont,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: Get.height*0.02),
              AppText(
                textAlign: TextAlign.center,
                text: "영문과 최소 1개의 숫자 혹은 특수 문자를 포함한 6~20자리 글자로 작성해 주세요.",
                fontSize: 0.016,
                color: Colors.grey,
                fontFamily: FontConstants.AppFont,
                fontWeight: FontWeight.w400,
              ),
              SizedBox(height: Get.height*0.06),
              AppTextField(
                  onChanged: (value) => {
                    if(value.isEmpty)
                    isPasswordTextEmpty.value = true
                    else
                      isPasswordTextEmpty.value = false
                  },
                  validator: ((value) {
                    return joinMembershipController.passwordValidation(value!);
                  }),
                  hintText: "비밀번호", textColor: Colors.white),
              SizedBox(height: Get.height*0.01),
              Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  textAlign: TextAlign.start,
                  text: "비밀번호 형식이 맞지 않습니다.",
                  fontSize: 0.015,
                  color: ColorConstants.red,
                  fontFamily: FontConstants.AppFont,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: Get.height*0.01),
              AppTextField(
                    onChanged: (value) => {
                      if(value.isEmpty)
                        isConfirmPasswordTextEmpty.value = true
                      else
                        isConfirmPasswordTextEmpty.value = false

                    },
                  validator: ((value) {
                    return joinMembershipController.validateConfirmPasswordReg(value!);
                  }),
                  textController: joinMembershipController.password,
                  hintText: "비밀번호 확인", textColor: Colors.white),
              /*SizedBox(height: Get.height*0.01),
              Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  textAlign: TextAlign.start,
                  text: "비밀번호를 동일하게 입력해 주세요.",
                  fontSize: 0.015,
                  color: ColorConstants.red,
                  fontFamily: FontConstants.AppFont,
                  fontWeight: FontWeight.w400,
                ),
              ),*/
              SizedBox(height: Get.height*0.05),
              GestureDetector(
                onTap: (){
                  if(joinMemberShipKey.currentState!.validate())
                    {
                      Get.to(MemberShipConfirmationScreen());
                    }

                },
                child: Obx(
                    () => Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                          color: (isPasswordTextEmpty.value || isConfirmPasswordTextEmpty.value)?ColorConstants.gray3:ColorConstants.yellow,
                          borderRadius: BorderRadius.circular(4)),
                      height: Get.height * 0.050,
                      width: Get.width ,
                      child: Center(
                        child: AppText(
                          text: "확인",
                          fontSize: 0.016,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Get.height*0.02),




            ],
          ),
        ),
      ),
    );
  }
}
