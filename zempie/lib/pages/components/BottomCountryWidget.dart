

import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/utils.dart';
import 'package:app/models/ChannelModel.dart';
import 'package:app/models/CommunityModel.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/pages/base/base_state.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/ImageUtils.dart';
import '../../models/CountryModel.dart';
import '../../models/MatchEnumModel.dart';

class BottomCountryWidget extends StatefulWidget{
  BottomCountryWidget({Key? key, required this.selectedCountry,required this.city, required this.onSelectCountry}) : super(key: key);
  CountryModel selectedCountry;
  String city;
  Function(CountryModel, String) onSelectCountry;

  @override
  State<BottomCountryWidget> createState() {
    // TODO: implement createState
    return _BottomCountryWidget();
  }
}

class _BottomCountryWidget extends BaseState<BottomCountryWidget> {
  List<CountryModel> countries = [];
  late CountryModel selectedCountry;
  RxBool isExistText = false.obs;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    selectedCountry = widget.selectedCountry;
    controller.text = widget.city;
    countries.addAll(Constants.allCountries);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: Get.width,
      height: Get.height*0.5,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30),
              topRight: Radius.circular(30))
      ),
      child: Column(

        children: [
          SizedBox(height: Get.height * 0.01,),
          Container(
            height: Get.height * 0.01,
            width: Get.width * 0.18,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: ColorConstants.white
            ),
          ),
          SizedBox(height: Get.height * 0.02,),
          AppText(
            text: "country_city_title".tr(),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          AppText(
            text: "country_city_description".tr(),
            fontSize: 12,
            color: ColorConstants.halfWhite,
          ),

          SizedBox(height: Get.height * 0.01,),

          Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      removeLeft: true,
                      removeRight: true,
                      removeBottom: true,
                      child: ListView.builder(
                          itemCount: countries.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
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
                                      children: [
                                        SvgPicture.asset(
                                          selectedCountry?.code == countries[index].code ? ImageConstants.radioButtonYellow : ImageConstants.radioButton ,
                                          height: Get.height * 0.024,
                                        ),

                                        SizedBox(width: 5,),

                                        AppText(
                                          text: countries[index].nameModel.ko,
                                          color: (selectedCountry?.code ?? "") == countries[index].code ? ColorConstants.colorMain : ColorConstants.white,
                                          fontSize: 14,
                                        ),
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
                    ),


                  ],
                )

              )
          ),

          Container(
              width: Get.width, // Set width according to your needs
              margin: EdgeInsets.only(left: 10, right: 10,bottom: 15),
              decoration: BoxDecoration(
                color: ColorConstants.white10Percent,
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

                        });
                      },
                      style: TextStyle(
                          color: ColorConstants.white,
                          fontFamily: FontConstants.AppFont,
                          fontSize: 16
                      ),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: "input_city_name_hint".tr(),
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

          SizedBox(height: Get.height * 0.01,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 15,),
              Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Get.back();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                          color: ColorConstants.gray3,
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: Center(
                        child: AppText(
                          text: "cancel".tr(),
                          fontSize: 0.016,
                          color: ColorConstants.white,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
              ),
              SizedBox(width: 15,),
              Expanded(
                  child: GestureDetector(
                    onTap: (){
                      if(controller.text.isEmpty){
                        Utils.showToast("please_input_city".tr());
                        return;
                      }
                      Get.back();
                      widget.onSelectCountry(selectedCountry, controller.text);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                          color: ColorConstants.colorMain,
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: Center(
                        child: AppText(
                          text: "confirm".tr(),
                          fontSize: 0.016,
                          color: ColorConstants.white,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
              ),
              SizedBox(width: 15,),
            ],
          ),

          SizedBox(height: 20,)
        ],
      ),
    );
  }
}
