

import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/utils.dart';
import 'package:app/models/ChannelModel.dart';
import 'package:app/models/CommunityModel.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/models/TranslationModel.dart';
import 'package:app/pages/base/base_state.dart';
import 'package:app/pages/components/app_text.dart';
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

class BottomTranslationWidget extends StatefulWidget{
  BottomTranslationWidget({Key? key, required this.onTapLanguage}) : super(key: key);
  Function(TranslationModel) onTapLanguage;

  @override
  State<BottomTranslationWidget> createState() {
    // TODO: implement createState
    return _BottomTranslationWidget();
  }
}

class _BottomTranslationWidget extends BaseState<BottomTranslationWidget> {


  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height*0.5,
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
            text: "언어",
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          AppText(
            text: "젬파이 앱에서 사용할 언어를 선택해 주세요.",
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
                            itemCount: Constants.translationModel.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.only(top: 0,left: 10, right: 0),
                            itemBuilder: (context,index){
                              return GestureDetector(
                                onTap: (){

                                },
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        Get.back();
                                        widget.onTapLanguage(Constants.translationModel[index]);
                                      },
                                      child: AppText(
                                        text: Constants.translationModel[index].origin,
                                        fontSize: 16,
                                      ),
                                    ),

                                    Container(
                                      margin: EdgeInsets.all(20),
                                      height: 0.5,
                                      color: ColorConstants.halfWhite,
                                    ),
                                  ],
                                )
                              );
                            }),
                      ),


                    ],
                  )

              )
          ),

          SizedBox(height: 20,)
        ],
      ),
    );
  }
}
