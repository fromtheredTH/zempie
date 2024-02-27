

import 'package:app/Constants/ColorConstants.dart';
import 'package:app/Constants/FontConstants.dart';
import 'package:app/pages/components/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import '../../models/dto/chat_room_dto.dart';
import '../../models/res/btn_bottom_sheet_model.dart';
import 'app_text.dart';

class EditRoomNameBottomSheet extends StatelessWidget {
  EditRoomNameBottomSheet({Key? key, required this.roomDto, required this.inputName}) : super(key: key);
  Function(String) inputName;
  ChatRoomDto roomDto;

  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nameController.text = roomDto.name ?? "";
    return Container(
      height: MediaQuery.of(context).padding.bottom + 240,
      decoration: BoxDecoration(
          color: ColorConstants.colorSub,
          borderRadius: BorderRadius.only(topRight: Radius.circular(24), topLeft: Radius.circular(24))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 15,),
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                  color: Color(0xffd9d9d9),
                  borderRadius: BorderRadius.circular(4)
              ),
            ),
          ),
          SizedBox(height: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: "채팅방 이름 변경",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),

                SizedBox(height: 15,),

                Column(
                  children: [
                    TextField(
                      controller: nameController,
                      maxLength: 20,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: FontConstants.AppFont,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: -10.0),
                        hintText: "변경할 이름을 입력 해주세요.",
                        hintStyle: TextStyle(
                          color: ColorConstants.halfWhite,
                          fontSize: 14,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w700,
                        ),
                        hintMaxLines: 1,
                      ),
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                    
                    Container(
                      height: 0.5,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      color: ColorConstants.halfWhite,
                    )
                  ],
                ),

                SizedBox(height: 10,),

                AppText(
                  text: "글자 수 등 명칭 제약 조건 설명...",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: ColorConstants.halfWhite,
                ),

                SizedBox(height: 10,),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          child: AppButton(
                              text: "cancel".tr(),
                              color: ColorConstants.gray3,
                              margin: 0,
                              onTap: (){
                                Get.back();
                              }
                          ),
                      ),

                      SizedBox(width: 10,),

                      Expanded(
                          child: AppButton(
                              text: "confirm".tr(),
                              margin: 0,
                              onTap: () async {
                                Get.back();
                                inputName(nameController.text);
                              }
                          )
                      )
                    ],
                  ),
                )
              ]
          ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 27),
        ],
      ),
    );
  }
}