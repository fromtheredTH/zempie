

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

class BottomInterestGenreWidget extends StatefulWidget{
  BottomInterestGenreWidget({Key? key, required this.selectedGenre, required this.onSelectGenre}) : super(key: key);
  List<MatchEnumModel> selectedGenre;
  Function(List<MatchEnumModel>) onSelectGenre;

  @override
  State<BottomInterestGenreWidget> createState() {
    // TODO: implement createState
    return _BottomInterestGenreWidget();
  }
}

class _BottomInterestGenreWidget extends BaseState<BottomInterestGenreWidget> {
  List<MatchEnumModel> selectedItems = [];

  @override
  void initState() {
    selectedItems = widget.selectedGenre;
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
            text: "interset_genre".tr(),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          AppText(
            text: "interset_genre_select".tr(),
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
                    itemCount: Constants.interestGenres.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 0,left: 0, right: 0),
                    itemBuilder: (context,index){
                      bool isSelected = selectedItems.map((e) => e.idx).toList().contains(Constants.interestGenres[index].idx);
                      return GestureDetector(
                          onTap: (){
                            setState(() {
                              if(!isSelected){
                                selectedItems.add(Constants.interestGenres[index]);
                              }else{
                                for(int i=0;i<selectedItems.length;i++){
                                  if(selectedItems[i].idx == Constants.interestGenres[index].idx) {
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
                                    text: Constants.languageCode == "ko" ? Constants.interestGenres[index].koName : Constants.interestGenres[index].enName,
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
                      widget.onSelectGenre(selectedItems);
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
