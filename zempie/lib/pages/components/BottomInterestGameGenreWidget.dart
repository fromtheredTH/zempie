

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

class BottomInterestGameGenreWidget extends StatefulWidget{
  BottomInterestGameGenreWidget({Key? key, required this.selectedGameGenre, required this.onSelectGameGenre}) : super(key: key);
  List<MatchEnumModel> selectedGameGenre;
  Function(List<MatchEnumModel>) onSelectGameGenre;

  @override
  State<BottomInterestGameGenreWidget> createState() {
    // TODO: implement createState
    return _BottomInterestGameGenreWidget();
  }
}

class _BottomInterestGameGenreWidget extends BaseState<BottomInterestGameGenreWidget> {
  List<MatchEnumModel> selectedItems = [];

  @override
  void initState() {
    selectedItems = widget.selectedGameGenre;
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
            text: "select_interest_game_genre_title".tr(),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          AppText(
            text: "select_interest_game_genre_description".tr(),
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
                    itemCount: Constants.interestGameGenres.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 0,left: 10, right: 0),
                    itemBuilder: (context,index){
                      bool isSelected = selectedItems.map((e) => e.idx).toList().contains(Constants.interestGameGenres[index].idx);
                      return GestureDetector(
                          onTap: (){
                            setState(() {
                              if(!isSelected){
                                selectedItems.add(Constants.interestGameGenres[index]);
                              }else{
                                for(int i=0;i<selectedItems.length;i++){
                                  if(selectedItems[i].idx == Constants.interestGameGenres[index].idx) {
                                    selectedItems.removeAt(i);
                                    break;
                                  }
                                }
                              }
                            });
                          },
                          child: Container(
                            height: 35,
                            margin: EdgeInsets.only(bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                isSelected ?
                                Icon(Icons.check_box_rounded, size: 30, color: ColorConstants.colorMain,)
                                    : Icon(Icons.check_box_outline_blank_rounded, size: 30, color: ColorConstants.white,),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: AppText(
                                    text: Constants.languageCode == "ko" ? Constants.interestGameGenres[index].koName : Constants.interestGameGenres[index].enName,
                                    color: isSelected ? ColorConstants.colorMain : ColorConstants.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                      );
                    }),
              )
          ),

          if(selectedItems.length > 0)
            Container(
              height: 25,
              margin: EdgeInsets.only(bottom: 20, left: 10),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context,
                                  int index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedItems.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            30),
                                        border: Border.all(color: ColorConstants.colorMain, width: 0.5)),
                                    child: Row(
                                      children: [
                                        AppText(
                                          text: Constants.languageCode == "ko" ? selectedItems[index].koName : selectedItems[index].enName,
                                          fontSize: 14,
                                          color: ColorConstants.colorMain,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 4),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(6),
                                              color: ColorConstants.colorMain
                                          ),
                                          child: Icon(Icons.close_rounded, size: 12, color: ColorConstants.colorBg1,),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              itemCount: selectedItems.length),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                      widget.onSelectGameGenre(selectedItems);
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
