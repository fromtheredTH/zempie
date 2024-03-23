

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

class BottomLanguageWidget extends StatefulWidget{
  BottomLanguageWidget({Key? key, required this.onTapLanguage}) : super(key: key);
  Function(String) onTapLanguage;

  @override
  State<BottomLanguageWidget> createState() {
    // TODO: implement createState
    return _BottomLanguageWidget();
  }
}

class _BottomLanguageWidget extends BaseState<BottomLanguageWidget> {


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: Get.width,
      height: 250,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30),
              topRight: Radius.circular(30)),
        color: ColorConstants.colorBg1
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
            text: "language".tr(),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          AppText(
            text: "launuage_select".tr(),
            fontSize: 12,
            color: ColorConstants.halfWhite,
          ),

          SizedBox(height: Get.height * 0.01,),

          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  GestureDetector(
                    onTap: (){
                      Get.back();
                      widget.onTapLanguage("ko");
                    },
                    child: AppText(
                      text: "한국어",
                      fontSize: 16,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.all(20),
                    height: 0.5,
                    color: ColorConstants.halfWhite,
                  ),

                  GestureDetector(
                    onTap: (){
                      Get.back();
                      widget.onTapLanguage("en");
                    },
                    child: AppText(
                      text: "English",
                      fontSize: 16,
                    ),
                  ),

                ],
              )
          ),

          SizedBox(height: 20,)
        ],
      ),
    );
  }
}
