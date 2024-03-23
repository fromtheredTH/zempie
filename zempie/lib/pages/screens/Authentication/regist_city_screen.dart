

import 'package:app/Constants/utils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:app/pages/screens/Authentication/regist_game_genre_screen.dart';
import 'package:app/pages/screens/Authentication/regist_genre_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../Constants/ColorConstants.dart';
import '../../../Constants/Constants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/ImageUtils.dart';
import '../../base/base_state.dart';

class RegistCityScreen extends StatefulWidget {
  RegistCityScreen({super.key, required this.user});
  UserModel user;

  @override
  State<RegistCityScreen> createState() => _RegistCityScreen();
}


class _RegistCityScreen extends BaseState<RegistCityScreen> {

  RxBool isExistText = false.obs;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.colorBg1,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10,),

            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              percent: 5/7.0,
              lineHeight: 8,
              width: Get.width,
              backgroundColor: ColorConstants.white20Percent,
              progressColor: ColorConstants.colorMain,
            ),

            Expanded(
              child: Padding(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Column(
                        children: [
                          Container(
                            width: double.maxFinite,
                            child: AppText(
                              text: "city".tr(),
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 5,),
                          Container(
                            width: double.maxFinite,
                            child: AppText(
                              text: "city_select_description".tr(),
                              fontSize: 14,
                              color: ColorConstants.halfWhite,
                            ),
                          ),

                          SizedBox(height: 30,),

                          Container(
                              width: Get.width, // Set width according to your needs
                              decoration: BoxDecoration(
                                color: ColorConstants.searchBackColor,
                                borderRadius:
                                BorderRadius.circular(6.0), // Adjust the value as needed
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: TextFormField(
                                      controller: controller,
                                      onChanged: (text){
                                        isExistText.value = !text.isEmpty;
                                      },
                                      style: TextStyle(
                                          color: ColorConstants.white,
                                          fontFamily: FontConstants.AppFont,
                                          fontSize: 16
                                      ),
                                      textInputAction: TextInputAction.search,
                                      decoration: InputDecoration(
                                        hintText: 'city_select_description'.tr(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 12.0), // Adjust vertical padding
                                        border: InputBorder.none,
                                        // prefixIcon: Padding(
                                        //   padding: const EdgeInsets.all(10.0),
                                        //   child: SvgPicture.asset(ImageConstants.searchIcon,
                                        //     color: Colors.white,
                                        //   ),
                                        // ),
                                        // Align hintText to center
                                        hintStyle: TextStyle(
                                            color: ColorConstants.halfWhite,
                                            fontFamily: FontConstants.AppFont,
                                            fontSize: 16),
                                        // alignLabelWithHint: true,
                                      ),
                                    ),
                                  ),

                                  Obx(() => isExistText.value ?
                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        isExistText.value = false;
                                        controller.text = "";
                                      });
                                    },
                                    child: ImageUtils.setImage(ImageConstants.searchX, 20, 20),
                                  ) : Container()
                                  ),

                                  SizedBox(width: 10,)
                                ],
                              )
                          ),
                        ],
                      ),

                      Obx(() => GestureDetector(
                        onTap: () async {
                          if(isExistText.value){
                            Utils.showDialogWidget(context);
                            var response = await DioClient.updateProfile(widget.user.profile.jobDept, widget.user.profile.jobGroup, widget.user.profile.jobPosition, widget.user.profile.country, controller.text, widget.user.profile.interestGameGenre, widget.user.profile.stateMsg);
                            UserModel user = UserModel.fromJson(response.data["result"]["user"]);
                            Get.back();
                            if(user.profile.interestGameGenre.isEmpty){
                              Get.to(RegistGameGenreScreen(user: user));
                            }else if(user.profile.stateMsg.isEmpty){
                              Get.to(RegistGenreScreen(user: user));
                            }else {
                              Constants.getUserInfo(true,context, apiP);
                            }
                          }
                        },
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                                color: !isExistText.value ? ColorConstants.textGry : ColorConstants.colorMain,
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
                          ),
                        ),
                      ),),
                    ],
                  )
              ),
            )
          ],
        ),
      ),
    );
  }

}