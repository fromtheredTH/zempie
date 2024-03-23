

import 'package:app/Constants/Constants.dart';
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
import '../../models/MatchEnumModel.dart';

class BottomProfileJobWidget extends StatefulWidget{
  BottomProfileJobWidget({Key? key, required this.selectedJobGroup, required this.onSelectJobGroup}) : super(key: key);
  MatchEnumModel selectedJobGroup;
  Function(MatchEnumModel) onSelectJobGroup;

  @override
  State<BottomProfileJobWidget> createState() {
    // TODO: implement createState
    return _BottomProfileJobWidget();
  }
}

class _BottomProfileJobWidget extends BaseState<BottomProfileJobWidget> {
  late MatchEnumModel selectedJobGroup;
  bool isExpanded = false;

  @override
  void initState() {
    selectedJobGroup = widget.selectedJobGroup;
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
            text: "직군",
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          AppText(
            text: "직군을 선택해 주세요.",
            fontSize: 12,
            color: ColorConstants.halfWhite,
          ),

          SizedBox(height: Get.height * 0.01,),

          Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeLeft: true,
                removeRight: true,
                removeBottom: true,
                child: ListView.builder(
                    itemCount: Constants.jobGroups.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 0,left: 10, right: 0),
                    itemBuilder: (context,index){
                      return GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedJobGroup = Constants.jobGroups[index];
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 5, left: 0, right: 10,bottom: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        selectedJobGroup?.enumValue == Constants.jobGroups[index].enumValue ? ImageConstants.radioButtonYellow : ImageConstants.radioButton ,
                                        height: Get.height * 0.024,
                                      ),

                                      SizedBox(width: 5,),

                                      AppText(
                                        text: Constants.jobGroups[index].enName,
                                        color: ColorConstants.white,
                                        fontSize: 14,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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
                      Get.back();
                      widget.onSelectJobGroup(selectedJobGroup);
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
