

import 'package:app/Constants/Constants.dart';
import 'package:app/models/ChannelModel.dart';
import 'package:app/models/CommunityModel.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/pages/base/base_state.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/ImageUtils.dart';
import '../../models/MatchEnumModel.dart';

class BottomProfileJobPositionWidget extends StatefulWidget{
  BottomProfileJobPositionWidget({Key? key, required this.selectedJobGroup,required this.selectedJobPosition, required this.onSelectJobPosition}) : super(key: key);
  MatchEnumModel selectedJobGroup;
  MatchEnumModel? selectedJobPosition;
  Function(MatchEnumModel, MatchEnumModel) onSelectJobPosition;

  @override
  State<BottomProfileJobPositionWidget> createState() {
    // TODO: implement createState
    return _BottomProfileJobPositionWidget();
  }
}

class _BottomProfileJobPositionWidget extends BaseState<BottomProfileJobPositionWidget> {
  late MatchEnumModel selectedJobGroup;
  late MatchEnumModel? selectedJobPosition;
  RxBool isExistText = false.obs;
  RxBool isExistFieldText = false.obs;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    selectedJobGroup = widget.selectedJobGroup;
    selectedJobPosition = widget.selectedJobPosition;
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
            text: "직무",
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          AppText(
            text: "직무를 선택해 주세요.",
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if(selectedJobGroup.enumValue == "CREATOR")
                        ListView.builder(
                            itemCount: Constants.jobPositions.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.only(top: 0,left: 10, right: 0),
                            itemBuilder: (context,index){
                              return GestureDetector(
                                onTap: (){
                                  setState(() {
                                    selectedJobPosition = Constants.jobPositions[index];
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
                                            selectedJobPosition?.enumValue == Constants.jobPositions[index].enumValue ? ImageConstants.radioButtonYellow : ImageConstants.radioButton ,
                                            height: Get.height * 0.024,
                                          ),

                                          SizedBox(width: 5,),

                                          AppText(
                                            text: Constants.jobPositions[index].enumValue,
                                            color: Constants.jobPositions[index].color,
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

                        SizedBox(height: 15,),

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
                                        selectedJobPosition = null;
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
                          text: "취소",
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
                      MatchEnumModel position = selectedJobPosition != null ? selectedJobPosition! : MatchEnumModel(100, controller.text, controller.text, controller.text, Colors.white);
                      widget.onSelectJobPosition(selectedJobGroup, position);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                          color: ColorConstants.colorMain,
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: Center(
                        child: AppText(
                          text: "확인",
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
