

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../controller/join_membership_controller.dart';
import '../../components/app_text.dart';
import '../../components/app_text_field.dart';
import 'enterUserId.dart';

class EnterName extends StatelessWidget {
   EnterName({super.key});

  final joinMembershipController = Get.put(JoinMembershipController());
   RxBool isNameTextEmpty = false.obs; // Initial button color
   GlobalKey<FormState> joinMemberShipKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.colorBg1,
      body: Form(
        key:joinMemberShipKey ,
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
                text: "이름",
                fontSize: 0.021,
                color: Colors.white,
                fontFamily: FontConstants.AppFont,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: Get.height*0.02),
              AppText(
                text: "이름을 최소 2글자이상으로 입력해 주세요.",
                fontSize: 0.016,
                color: Colors.grey,
                fontFamily: FontConstants.AppFont,
                fontWeight: FontWeight.w400,
              ),
              SizedBox(height: Get.height*0.06),
              Expanded(

                  child: AppTextField(
                      onChanged: (value) => {
                        if(value.isEmpty)
                          isNameTextEmpty.value = true
                        else
                          isNameTextEmpty.value = false
                      },
                      validator: ((value) {
                        return joinMembershipController.enterNameValidation(value!);
                      }),
                      hintText: "홍길동", textColor: Colors.white)),
              SizedBox(height: Get.height*0.05),
              GestureDetector(
                onTap: (){
                  if (joinMemberShipKey.currentState!.validate()) {
                    Get.to(EnterUserId());
                  }

                },
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Obx(
                    () =>  Container(
                      decoration: BoxDecoration(
                          color: (isNameTextEmpty.value)?ColorConstants.gray3:ColorConstants.yellow,
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
