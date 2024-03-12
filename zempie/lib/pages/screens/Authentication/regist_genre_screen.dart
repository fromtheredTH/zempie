

import 'package:app/Constants/Constants.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/MatchEnumModel.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:app/pages/screens/Authentication/regist_city_screen.dart';
import 'package:app/pages/screens/Authentication/regist_country_screen.dart';
import 'package:app/pages/screens/Authentication/regist_job_position_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/ImageUtils.dart';
import '../../../models/CountryModel.dart';
import '../../base/base_state.dart';
import '../../components/loading_widget.dart';

class RegistGenreScreen extends StatefulWidget {
  RegistGenreScreen({super.key, required this.user});
  UserModel user;

  @override
  State<RegistGenreScreen> createState() => _RegistGenreScreen();
}


class _RegistGenreScreen extends BaseState<RegistGenreScreen> {

  TextEditingController controller = TextEditingController();
  List<MatchEnumModel> selectedItems = [];


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
              percent: 7/7.0,
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
                                text: "관심 분야",
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 5,),
                            Container(
                              width: double.maxFinite,
                              child: AppText(
                                text: "관심 분야를 선택해 주세요.",
                                fontSize: 14,
                                color: ColorConstants.halfWhite,
                              ),
                            ),

                            SizedBox(height: 30,),

                            // if(selectedItems.length > 0)
                            //   Container(
                            //     height: 25,
                            //     margin: EdgeInsets.only(bottom: 20),
                            //     child: Row(
                            //       children: [
                            //         Expanded(
                            //           child: SingleChildScrollView(
                            //             scrollDirection: Axis.horizontal,
                            //             child: Row(
                            //               children: [
                            //                 ListView.builder(
                            //                     shrinkWrap: true,
                            //                     scrollDirection: Axis.horizontal,
                            //                     itemBuilder: (BuildContext context,
                            //                         int index) {
                            //                       return GestureDetector(
                            //                         onTap: () {
                            //                           setState(() {
                            //                             selectedItems.removeAt(index);
                            //                           });
                            //                         },
                            //                         child: Container(
                            //                           margin: EdgeInsets.only(right: 10),
                            //                           padding: EdgeInsets.symmetric(
                            //                               horizontal: 8),
                            //                           decoration: BoxDecoration(
                            //                               borderRadius: BorderRadius.circular(
                            //                                   30),
                            //                               border: Border.all(color: ColorConstants.colorMain, width: 0.5)),
                            //                           child: Row(
                            //                             children: [
                            //                               AppText(
                            //                                 text: selectedItems[index].koName,
                            //                                 fontSize: 14,
                            //                                 color: ColorConstants.colorMain,
                            //                               ),
                            //                               Container(
                            //                                 margin: EdgeInsets.only(
                            //                                     left: 4),
                            //                                 decoration: BoxDecoration(
                            //                                     borderRadius: BorderRadius.circular(6),
                            //                                     color: ColorConstants.colorMain
                            //                                 ),
                            //                                 child: Icon(Icons.close_rounded, size: 12, color: ColorConstants.colorBg1,),
                            //                               ),
                            //                             ],
                            //                           ),
                            //                         ),
                            //                       );
                            //                     },
                            //                     itemCount: selectedItems.length),
                            //               ],
                            //             ),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),

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
                                                      text: Constants.interestGenres[index].koName,
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
                            )


                          ],
                        ),
                      ),

                      SizedBox(height: 15,),

                      GestureDetector(
                        onTap: () async {
                          if(selectedItems.length != 0){
                            String genre = "";
                            genre += selectedItems[0].idx.toString();
                            for(int i=1;i<selectedItems.length;i++){
                              genre += ",${selectedItems[i].idx}";
                            }
                            var response = await DioClient.updateProfile(widget.user.profile.jobDept, widget.user.profile.jobGroup, widget.user.profile.jobPosition, widget.user.profile.country, widget.user.profile.city, widget.user.profile.interestGameGenre, genre);
                            Constants.getUserInfo(context, apiP);
                          }
                        },
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                                color: selectedItems.length == 0 ? ColorConstants.textGry : ColorConstants.colorMain,
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