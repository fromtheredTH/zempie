

import 'package:app/pages/screens/joinmembership/enterPassword.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../controller/join_membership_controller.dart';
import '../../components/app_text.dart';
import '../../components/app_text_field.dart';

class EnterUserId extends StatelessWidget {
   EnterUserId({super.key});

   final joinMembershipController = Get.put(JoinMembershipController());
   RxBool isUserIdTextEmpty = false.obs; // Initial button color
   GlobalKey<FormState> joinMemberShipKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.colorBg1,
      body: Form(
        key: joinMemberShipKey,
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
                    fontSize: 0.020,
                    color: Colors.white,
                    fontFamily: FontConstants.AppFont,
                    fontWeight: FontWeight.w700,
                  ),

                ],
              ),
              SizedBox(height: Get.height*0.08),
              AppText(
                text: "사용자 아이디",
                fontSize: 0.021,
                color: Colors.white,
                fontFamily: FontConstants.AppFont,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: Get.height*0.02),
              AppText(
                textAlign: TextAlign.center,
                text: "사용자 아이디는 4글자이상 15글자이내의 영문과 숫자, ‘_’, ‘.’를 사용하실 수 있습니다.",
                fontSize: 0.016,
                color: Colors.grey,
                fontFamily: FontConstants.AppFont,
                fontWeight: FontWeight.w400,
              ),
              SizedBox(height: Get.height*0.06),
              AppTextField(
                  onChanged: (value) => {
                    if(value.isEmpty)
                    isUserIdTextEmpty.value = true
                    else
                      isUserIdTextEmpty.value = false
                  },

                  hintText: "이메일 주소", textColor: Colors.white),
              SizedBox(height: Get.height*0.01),
              Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  textAlign: TextAlign.start,
                  text: "이미 사용 중인 아이디입니다.",
                  fontSize: 0.015,
                  color: ColorConstants.red,
                  fontFamily: FontConstants.AppFont,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: Get.height*0.05),
              GestureDetector(
                onTap: (){
                  if (joinMemberShipKey.currentState!.validate()) {
                    isUserIdTextEmpty.value = false;
                    Get.to(EnterPassword());
                  }

                },
                child: Obx(
                  () => Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                          color: (isUserIdTextEmpty.value)?ColorConstants.gray3:ColorConstants.yellow,
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
