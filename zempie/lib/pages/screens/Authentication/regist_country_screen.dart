

import 'package:app/global/DioClient.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:app/pages/screens/Authentication/regist_city_screen.dart';
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
import '../../../Constants/utils.dart';
import '../../../models/CountryModel.dart';
import '../../base/base_state.dart';
import '../../components/loading_widget.dart';

class RegistCountryScreen extends StatefulWidget {
  RegistCountryScreen({super.key, required this.user});
  UserModel user;

  @override
  State<RegistCountryScreen> createState() => _RegistCountryScreen();
}


class _RegistCountryScreen extends BaseState<RegistCountryScreen> {

  RxBool isExistText = false.obs;
  RxBool isExistFieldText = false.obs;
  TextEditingController controller = TextEditingController();
  RxString country = "".obs;
  List<CountryModel> countries = [];
  CountryModel? selectedCountry;

  Future<void> initCountries() async {
    await Constants.initCountryModels();
    setState(() {
      countries.addAll(Constants.allCountries);
    });
  }

  @override
  void initState() {
    countries.addAll(Constants.allCountries);
    super.initState();
    if(countries.isEmpty){
      initCountries();
    }
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
              percent: 4/7.0,
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
                                  text: "country".tr(),
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 5,),
                              Container(
                                width: double.maxFinite,
                                child: AppText(
                                  text: "country_select_description".tr(),
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
                                            isExistFieldText.value = !text.isEmpty;
                                            countries.clear();
                                            setState(() {
                                              if(text.isEmpty){
                                                countries.addAll(Constants.allCountries);
                                              }else {
                                                for (int i =0 ;i<Constants.allCountries.length;i++){
                                                  if(Constants.allCountries[i].nameModel.ko.contains(text) || Constants.allCountries[i].nameModel.en.contains(text)){
                                                    countries.add(Constants.allCountries[i]);
                                                  }
                                                }
                                              }
                                            });
                                          },
                                          style: TextStyle(
                                              color: ColorConstants.white,
                                              fontFamily: FontConstants.AppFont,
                                              fontSize: 16
                                          ),
                                          textInputAction: TextInputAction.search,
                                          decoration: InputDecoration(
                                            hintText: 'country_input_description'.tr(),
                                            contentPadding: EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 12.0), // Adjust vertical padding
                                            border: InputBorder.none,
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: SvgPicture.asset(ImageConstants.searchIcon,
                                                color: Colors.white,
                                              ),
                                            ),
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

                              SizedBox(height: 15,),

                              Expanded(
                                  child: MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    removeLeft: true,
                                    removeRight: true,
                                    removeBottom: true,
                                    child: ListView.builder(
                                        itemCount: countries.length,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.only(top: 0,left: 10, right: 0),
                                        itemBuilder: (context,index){
                                          return GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                selectedCountry = countries[index];
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
                                                          text: Constants.languageCode == "ko" ? countries[index].nameModel.ko : countries[index].nameModel.en,
                                                          color: (selectedCountry?.code ?? "") == countries[index].code ? ColorConstants.colorMain : ColorConstants.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),

                                                      (selectedCountry?.code ?? "") == countries[index].code ?
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
                                  )
                              )


                            ],
                          ),
                      ),

                      SizedBox(height: 15,),

                      GestureDetector(
                        onTap: () async {
                          if(selectedCountry != null){
                            Utils.showDialogWidget(context);
                            var response = await DioClient.updateProfile(widget.user.profile.jobDept, widget.user.profile.jobGroup, widget.user.profile.jobPosition, selectedCountry!.code, widget.user.profile.city, widget.user.profile.interestGameGenre, widget.user.profile.stateMsg);
                            UserModel user = UserModel.fromJson(response.data["result"]["user"]);
                            Get.back();
                            if(user.profile.city.isEmpty){
                              Get.to(RegistCityScreen(user: user));
                            }else if(user.profile.interestGameGenre.isEmpty){
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
                                color: selectedCountry == null ? ColorConstants.textGry : ColorConstants.colorMain,
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