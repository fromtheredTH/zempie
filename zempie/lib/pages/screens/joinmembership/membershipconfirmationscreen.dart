

import 'package:app/pages/screens/bottomnavigationscreen/bottomNavBarScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../components/app_text.dart';

class MemberShipConfirmationScreen extends StatelessWidget {
  const MemberShipConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    RxBool? isEveryOneAgrees = false.obs;
    RxBool? isAgreeTermOfServices = false.obs;
    RxBool? isAgreeToPersonalInfo = false.obs;
    RxBool? isAgreeToMarketingPromotion = false.obs;

    return Scaffold(
      backgroundColor: ColorConstants.colorBg1,
      resizeToAvoidBottomInset: true,
      body: Padding(
       padding:EdgeInsets.only(left: 15, right: 15),
        child: SingleChildScrollView(
          child: Container(
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
                SizedBox(height: Get.height*0.03),
                Row(
                  children: [
                    Obx(() => SizedBox(
                      width:34,
                      child:
                        Checkbox(
                          activeColor: ColorConstants.yellow,
                          checkColor: ColorConstants.white,
                          value: isEveryOneAgrees.value,
                          shape: CircleBorder(),
                          onChanged: (bool? value) {
                            isEveryOneAgrees.value = value!;
                          },
                        ),
                    )),
                    SizedBox(
                      height: Get.height * 0.03,
                    ),
                    AppText(
                      text: "모두 동의합니다.",
                      color: ColorConstants.white,
                      fontSize: 0.018,
                      fontWeight: FontWeight.w400,
                      fontFamily: FontConstants.AppFont,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Obx(() => SizedBox(
                      width:30,
                      child: Checkbox(
                        activeColor: ColorConstants.yellow,
                        checkColor: ColorConstants.white,
                        value: isAgreeTermOfServices.value,
                        onChanged: (bool? value) {
                          isAgreeTermOfServices.value = value!;
                        },
                      ),
                    )),
                    SizedBox(
                      height: Get.height * 0.02,
                    ),
                    AppText(
                      text: "서비스 이용 약관 동의 (필수)",
                      color: ColorConstants.white,
                      fontSize: 0.017,
                      fontWeight: FontWeight.w400,
                      fontFamily: FontConstants.AppFont,
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 8, right: 8),
                  width: Get.width, // Set the width as per your requirement// Set the height as per your requirement
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white, // Set the border color
                      width: 0.5, // Set the border width
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: AppText(
                      fontFamily: FontConstants.AppFont,
                       color: Colors.grey,
                       text: 'Urna, ultricies fringilla platea nibh. Sem ut dignissim dignissim purus. Lacus, amet vitae urna elit in. Adipiscing leo ac lectus donec. Semper bibendum consectetur mauris, ut non vel eros. Dis blandit et gravida maecenas. Lectus interdum nulla urna potenti neque sagittis. Risus tincidunt consectetur eget faucibus. Vel suspendisse porta proin facilisis quam.',
                      fontSize: 0.014,
                    ),
                  ),
                ),

                SizedBox(
                  height: Get.height * 0.02,
                ),
                Row(
                  children: [
                    Obx(() => SizedBox(
                      width:30,
                      child: Checkbox(
                        activeColor: ColorConstants.yellow,
                        checkColor: ColorConstants.white,
                        value: isAgreeToPersonalInfo.value,
                        onChanged: (bool? value) {
                          isAgreeToPersonalInfo.value = value!;
                        },
                      ),
                    )),
                    SizedBox(
                      height: Get.height * 0.02,
                    ),
                    AppText(
                      text: "개인정보 처리 방침 동의 (필수)",
                      color: ColorConstants.white,
                      fontSize: 0.017,
                      fontWeight: FontWeight.w400,
                      fontFamily: FontConstants.AppFont,
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 8, right: 8),
                  width: Get.width, // Set the width as per your requirement// Set the height as per your requirement
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white, // Set the border color
                      width: 0.5, // Set the border width
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: AppText(
                      fontFamily: FontConstants.AppFont,
                      color: Colors.grey,
                      text: 'Urna, ultricies fringilla platea nibh. Sem ut dignissim dignissim purus. Lacus, amet vitae urna elit in. Adipiscing leo ac lectus donec. Semper bibendum consectetur mauris, ut non vel eros. Dis blandit et gravida maecenas. Lectus interdum nulla urna potenti neque sagittis. Risus tincidunt consectetur eget faucibus. Vel suspendisse porta proin facilisis quam.',
                      fontSize: 0.014,
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Row(
                  children: [
                    Obx(() => SizedBox(
                      width:30,
                      child: Checkbox(
                        activeColor: ColorConstants.yellow,
                        checkColor: ColorConstants.white,
                        value: isAgreeToMarketingPromotion.value,
                        onChanged: (bool? value) {
                          isAgreeToMarketingPromotion.value = value!;
                        },
                      ),
                    )),
                    SizedBox(
                      height: Get.height * 0.03,
                    ),
                    AppText(
                      text: "마케팅 프로모션 정책 동의 (선택)",
                      color: ColorConstants.white,
                      fontSize: 0.017,
                      fontWeight: FontWeight.w400,
                      fontFamily: FontConstants.AppFont,
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 8, right: 8),
                  width: Get.width, // Set the width as per your requirement// Set the height as per your requirement
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white, // Set the border color
                      width: 0.5, // Set the border width
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: AppText(
                      fontFamily: FontConstants.AppFont,
                      color: Colors.grey,
                      text: 'Urna, ultricies fringilla platea nibh. Sem ut dignissim dignissim purus. Lacus, amet vitae urna elit in. Adipiscing leo ac lectus donec. Semper bibendum consectetur mauris, ut non vel eros. Dis blandit et gravida maecenas. Lectus interdum nulla urna potenti neque sagittis. Risus tincidunt consectetur eget faucibus. Vel suspendisse porta proin facilisis quam.',
                      fontSize: 0.014,
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.02 ,
                ),
                GestureDetector(
                  onTap: (){
                    Get.to(BottomNavBarScreen());
                  },
                  child: Obx(
                    () => Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                            color: (isEveryOneAgrees.value && isAgreeTermOfServices.value && isAgreeToPersonalInfo.value && isAgreeToMarketingPromotion.value)?ColorConstants.yellow:ColorConstants.gray3,
                            borderRadius: BorderRadius.circular(4)),
                        height: Get.height * 0.050,
                        width: Get.width ,
                        child: Center(
                          child: AppText(
                            text: "회원가입",
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
                SizedBox(
                  height: Get.height * 0.02,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
