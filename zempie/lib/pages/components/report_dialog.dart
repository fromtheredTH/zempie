import 'package:app/Constants/utils.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:app/global/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../Constants/ColorConstants.dart';
import '../../Constants/Constants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../base/base_state.dart';
import 'app_text.dart';

class ReportDialog extends StatefulWidget {
  ReportDialog({Key? key, required this.onConfirm, required this.type}) : super(key: key);
  Function(String, String) onConfirm;
  String type;

  @override
  ReportDialogState createState() => ReportDialogState();
}

class ReportDialogState extends BaseState<ReportDialog> {
  TextEditingController infoController = TextEditingController();
  List<int> selectedIndex = [];

  @override
  void initState() {
    super.initState();
  }

  Future<bool> onBackPressed() async {
    Navigator.pop(context);
    return true;
  }

  void onConfirm() {
    if(selectedIndex.isEmpty){
      Utils.showToast("신고 사유를 선택해 주세요");
      return;
    }
    String result = "${selectedIndex[0]}";
    for(int i=1;i<selectedIndex.length;i++){
      result += ",${selectedIndex[i]}";
    }
    Get.back();
    widget.onConfirm(result, infoController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: 550,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30),
              topRight: Radius.circular(30)),
          color: ColorConstants.colorBg1
      ),
      child: Column(

        children: [
          SizedBox(height: 15,),
          Container(
            height: 8,
            width: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: ColorConstants.white
            ),
          ),
          SizedBox(height: 10,),
          AppText(
            text: widget.type == "post" ? "게시물 신고" : widget.type == "game" ? "게임 신고" : "댓글 신고",
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 10,),
          Padding(
            padding: EdgeInsets.only(left: 20,right: 20),
            child: AppText(
              text: "신고 사유를 선택해 주세요. 신고 사유에 맞지 않는 신고일 경우, 해당 신고는 처리되지 않습니다. 검토까지는 최대 24시간이 소요됩니다.",
              fontSize: 12,
              textAlign: TextAlign.center,
              color: ColorConstants.halfWhite,
            ),
          ),

          SizedBox(height: 10,),

          Expanded(
            child: ListView.builder(
                itemCount: Constants.reportLists.length,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 0,left: 20, right: 0),
                itemBuilder: (context,index){
                  return GestureDetector(
                    onTap: (){
                      setState(() {
                        if(selectedIndex.contains(index)){
                          selectedIndex.remove(index);
                        }else{
                          selectedIndex.add(index);
                        }
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
                                    selectedIndex.contains(index) ? ImageConstants.radioButtonYellow : ImageConstants.radioButton ,
                                    height: 20,
                                  ),

                                  SizedBox(width: 5,),

                                  AppText(
                                    text: Constants.reportLists[index],
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
          ),

          SizedBox(height: 20,),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              maxLines: 4,
              minLines: 4,
              maxLength: 500,
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: FontConstants.AppFont,
                  fontSize: 13
              ),
              controller: infoController,
              decoration: InputDecoration(
                  counterText: "",
                  hintText: "추가적인 정보를 입력해 주세요...",
                  fillColor: ColorConstants.white10Percent,
                  filled: true,
                  hintStyle: TextStyle(
                      color: ColorConstants.halfWhite,
                      fontSize: 13,
                      fontFamily: FontConstants.AppFont,
                      fontWeight: FontWeight.w400
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    gapPadding: 5,
                    borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 0
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    gapPadding: 5,
                    borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 0
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10)
              ),
              onChanged: (text) {
                setState(() {

                });
              },
            ),
          ),

          SizedBox(height: 15,),
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
                      onConfirm();
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
