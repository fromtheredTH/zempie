

import 'package:app/global/DioClient.dart';
import 'package:app/models/MatchEnumModel.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:app/pages/screens/Authentication/regist_city_screen.dart';
import 'package:app/pages/screens/Authentication/regist_country_screen.dart';
import 'package:app/pages/screens/Authentication/regist_game_genre_screen.dart';
import 'package:app/pages/screens/Authentication/regist_genre_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../Constants/ColorConstants.dart';
import '../../../Constants/Constants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/ImageUtils.dart';
import '../../../models/CountryModel.dart';
import '../../base/base_state.dart';
import '../../components/loading_widget.dart';

class RegistJobPositionScreen extends StatefulWidget {
  RegistJobPositionScreen({super.key, required this.user});
  UserModel user;

  @override
  State<RegistJobPositionScreen> createState() => _RegistJobPositionScreen();
}


class _RegistJobPositionScreen extends BaseState<RegistJobPositionScreen> {

  RxBool isExistText = false.obs;
  RxBool isExistFieldText = false.obs;
  TextEditingController controller = TextEditingController();
  MatchEnumModel? selectedItem;
  List<MatchEnumModel> jobPositions = [];

  @override
  void initState() {
    if(widget.user.profile.jobGroup == "1"){
      jobPositions.addAll(Constants.jobPositions);
    }
    super.initState();
  }

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
              percent: 3/7.0,
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

                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: double.maxFinite,
                              child: AppText(
                                text: "무슨 일을 하시나요?",
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 5,),
                            Container(
                              width: double.maxFinite,
                              child: AppText(
                                text: "직무를 선택해 주세요",
                                fontSize: 14,
                                color: ColorConstants.halfWhite,
                              ),
                            ),

                            SizedBox(height: 30,),

                            Expanded(
                                child: MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  removeLeft: true,
                                  removeRight: true,
                                  removeBottom: true,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        ListView.builder(
                                            itemCount: jobPositions.length,
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.only(top: 0,left: 10, right: 0),
                                            itemBuilder: (context,index){
                                              return GestureDetector(
                                                onTap: (){
                                                  setState(() {
                                                    selectedItem = jobPositions[index];
                                                  });
                                                },
                                                child: Container(
                                                  height: 45,
                                                  margin: EdgeInsets.only(top: 5, left: 0, right: 10,bottom: 5),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(),

                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: AppText(
                                                              text: jobPositions[index].enumValue,
                                                              color: jobPositions[index].color,
                                                              fontSize: 14,
                                                            ),
                                                          ),

                                                          (selectedItem?.enumValue ?? "") == jobPositions[index].enumValue ?
                                                          Icon(Icons.check_rounded , size: 14, color: ColorConstants.colorMain,) : Container()
                                                        ],
                                                      ),

                                                      Container(
                                                        color: ColorConstants.textGry,
                                                        height: 0.5,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),

                                        SizedBox(height: 15,),

                                        Container(
                                            width: Get.width, // Set width according to your needs
                                            decoration: BoxDecoration(
                                              color: ColorConstants.searchBackColor,
                                              borderRadius: BorderRadius.circular(6.0), // Adjust the value as needed
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: TextField(
                                                    controller: controller,
                                                    maxLength: 5,
                                                    maxLines: 1,
                                                    onChanged: (text){
                                                      setState(() {
                                                        selectedItem = null;
                                                      });
                                                    },
                                                    style: TextStyle(
                                                        color: ColorConstants.white,
                                                        fontFamily: FontConstants.AppFont,
                                                        fontSize: 16
                                                    ),
                                                    textInputAction: TextInputAction.search,
                                                    decoration: InputDecoration(
                                                      hintText: '직접 입력',
                                                      contentPadding: EdgeInsets.symmetric(
                                                          horizontal: 16.0,
                                                          vertical: 12.0), // Adjust vertical padding
                                                      border: InputBorder.none,
                                                      counterText: "",
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
                                  )
                                )
                            )


                          ],
                        ),
                      ),

                      SizedBox(height: 15,),

                      GestureDetector(
                        onTap: () async {
                          UserModel? user;
                          if(selectedItem != null){
                            if(selectedItem!.idx == -1){
                              var response = await DioClient.updateProfile(widget.user.profile.jobDept, widget.user.profile.jobGroup, "해당 없음", widget.user.profile.country, widget.user.profile.city, widget.user.profile.interestGameGenre, widget.user.profile.stateMsg);
                              user = UserModel.fromJson(response.data["result"]["user"]);
                            }else{
                              var response = await DioClient.updateProfile(widget.user.profile.jobDept, widget.user.profile.jobGroup, selectedItem!.idx.toString(), widget.user.profile.country, widget.user.profile.city, widget.user.profile.interestGameGenre, widget.user.profile.stateMsg);
                              user = UserModel.fromJson(response.data["result"]["user"]);
                            }
                          }else if(controller.text.isNotEmpty){
                            var response = await DioClient.updateProfile(widget.user.profile.jobDept, widget.user.profile.jobGroup, controller.text, widget.user.profile.country, widget.user.profile.city, widget.user.profile.interestGameGenre, widget.user.profile.stateMsg);
                            user = UserModel.fromJson(response.data["result"]["user"]);
                          }
                          if(user != null){
                            if(user.profile.country.isEmpty){
                              Get.to(RegistCountryScreen(user: user));
                            }else if(user.profile.city.isEmpty){
                              Get.to(RegistCityScreen(user: user));
                            }else if(user.profile.interestGameGenre.isEmpty){
                              Get.to(RegistGameGenreScreen(user: user));
                            }else if(user.profile.stateMsg.isEmpty){
                              Get.to(RegistGenreScreen(user: user));
                            }else {
                              Constants.getUserInfo(context, apiP);
                            }
                          }
                        },
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                                color: selectedItem == null && controller.text.isEmpty ? ColorConstants.textGry : ColorConstants.colorMain,
                                borderRadius: BorderRadius.circular(4)),
                            height: 48,
                            width: Get.width ,
                            child: Center(
                              child: AppText(
                                text: "다음",
                                fontSize: 16,
                                fontFamily: FontConstants.AppFont,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
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