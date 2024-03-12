


import 'dart:convert';
import 'dart:io';

import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/screens/setting/setting_remove_account.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/utils.dart';
import '../../../models/PostFileModel.dart';
import '../../../models/PostModel.dart';
import '../../../models/res/btn_bottom_sheet_model.dart';
import '../../components/BtnBottomSheetWidget.dart';
import '../../components/GalleryBottomSheet.dart';
import '../../components/GameWidget.dart';
import '../../components/MyAssetPicker.dart';
import '../../components/UserListItemWidget.dart';
import '../../components/app_text.dart';
import '../../base/base_state.dart';
import '../../components/app_text_field.dart';
import '../../components/loading_widget.dart';
import '../../components/post_widget.dart';
import '../newPostScreen.dart';

class SettingAccountScreen extends StatefulWidget {
  SettingAccountScreen({super.key, required this.onChangedUser});
  Function(UserModel) onChangedUser;

  @override
  State<SettingAccountScreen> createState() => _SettingAccountScreen();
}

class _SettingAccountScreen extends BaseState<SettingAccountScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();

  RxBool isTapNicknameOkBtn = false.obs;
  RxBool isNicknameEmpty = false.obs;
  RxBool isNicknameCorrect = true.obs;
  RxBool isNicknameNotDuplicate = true.obs;

  RxBool isTapNameOkBtn = false.obs;
  RxBool isNameEmpty = false.obs;
  RxBool isNameCorrect = true.obs;

  @override
  void initState() {
    super.initState();
    emailController.text = Constants.user.email;
    nameController.text = Constants.user.name;
    nicknameController.text = Constants.user.nickname;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: ColorConstants.colorBg1,
        resizeToAvoidBottomInset: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(height: Get.height*0.07),
                Padding(
                  padding:EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: (){
                                Get.back();
                              },
                              child: Icon(Icons.arrow_back_ios, color:Colors.white)),

                          AppText(
                            text: "계정",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          )
                        ],
                      ),

                      GestureDetector(
                        onTap: (){
                          Get.to(SettingRemoveAccountScreen());
                        },
                        child: AppText(
                          text: "계정 삭제",
                          fontSize: 14,
                          color: ColorConstants.halfWhite,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 30),


                Padding(
                  padding: EdgeInsets.only(left: 20,right: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        AppText(
                          text: "이메일",
                          fontWeight: FontWeight.w700,
                        ),
                        SizedBox(height: 10,),

                        TextField(
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 13,
                            fontFamily: FontConstants.AppFont,
                            fontWeight: FontWeight.w400,
                          ),
                          readOnly: true,
                          controller: emailController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                BorderSide(color: Color(0xFFFFFFFF).withOpacity(
                                    0.5)),
                              ),
                              hintText: "",
                              hintStyle: TextStyle(
                                color: Color(0xFFFFFFFF).withOpacity(0.5),
                                fontWeight: FontWeight.w400,
                                fontFamily: FontConstants.AppFont,
                                fontSize: 13,
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                        ),

                        SizedBox(height: 25,),

                        Row(
                          children: [
                            AppText(
                              text: "이름",
                              fontWeight: FontWeight.w700,
                            ),
                            SizedBox(width: 5,),

                            GestureDetector(
                              onTap: (){
                                Utils.showToast("프로필에서 사용자의 본명 또는 활동명을 나타내는 공간입니다.");
                              },
                              child: ImageUtils.setImage(ImageConstants.accountEditQuestion, 16, 16),
                            )
                          ],
                        ),
                        SizedBox(height: 10,),

                        TextField(
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 13,
                            fontFamily: FontConstants.AppFont,
                            fontWeight: FontWeight.w400,
                          ),
                          onChanged: (value){
                            isTapNameOkBtn.value = false;
                            isNameEmpty.value = value.isEmpty;
                            if(value.isNotEmpty && value.length < 2) {
                              isNameCorrect.value = false;
                            }else{
                              isNameCorrect.value = true;
                            }
                          },
                          controller: nameController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                BorderSide(color: Color(0xFFFFFFFF).withOpacity(
                                    0.5)),
                              ),
                              hintText: "",
                              hintStyle: TextStyle(
                                color: Color(0xFFFFFFFF).withOpacity(0.5),
                                fontWeight: FontWeight.w400,
                                fontFamily: FontConstants.AppFont,
                                fontSize: 13,
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                        ),

                        SizedBox(height: 5,),

                        Obx(() => AppText(
                          text:
                          !isNameCorrect.value || isNameEmpty.value ? "이름은 최소 2자이상으로 작성해 주세요." :
                          "사용할 수 있는 이름입니다.",
                          color: isNameEmpty.value && isTapNameOkBtn.value ? ColorConstants.red :
                          !isNameCorrect.value ? ColorConstants.red
                              : ColorConstants.halfWhite,

                          fontSize: 11,
                          maxLine: 2,
                        )),

                        SizedBox(height: 25,),

                        Row(
                          children: [
                            AppText(
                              text: "닉네임",
                              fontWeight: FontWeight.w700,
                            ),
                            SizedBox(width: 5,),

                            GestureDetector(
                              onTap: (){
                                Utils.showToast("각 사용자를 고유하게 식별하는 아이디입니다. 다른 사람들은 이 닉네임을 사용하여 여러분을 찾을 수 있습니다.");
                              },
                              child: ImageUtils.setImage(ImageConstants.accountEditQuestion, 16, 16),
                            )
                          ],
                        ),
                        SizedBox(height: 10,),

                        TextField(
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 13,
                            fontFamily: FontConstants.AppFont,
                            fontWeight: FontWeight.w400,
                          ),
                          onChanged: (value){
                            isTapNicknameOkBtn.value = false;
                            isNicknameEmpty.value = value.isEmpty;
                            isNicknameNotDuplicate.value = true;
                            if(value.isNotEmpty && value.length < 4 && !GetUtils.isUsername(value)) {
                              isNicknameCorrect.value = false;
                            }else{
                              isNicknameCorrect.value = true;
                            }
                          },
                          controller: nicknameController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                BorderSide(color: Color(0xFFFFFFFF).withOpacity(
                                    0.5)),
                              ),
                              hintText: "",
                              hintStyle: TextStyle(
                                color: Color(0xFFFFFFFF).withOpacity(0.5),
                                fontWeight: FontWeight.w400,
                                fontFamily: FontConstants.AppFont,
                                fontSize: 13,
                              ),
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                        ),

                        SizedBox(height: 5,),

                        Obx(() => AppText(
                          text:
                          isNicknameCorrect.value && isNicknameNotDuplicate.value && isNicknameEmpty.value ? "닉네임은 4자이상 15자이내의 영문, 숫자, ‘_’, ‘.’ 로 작성해 주세요." :
                          isNicknameCorrect.value && isNicknameNotDuplicate.value ? "사용할 수 있는 닉네임입니다." :
                          !isNicknameCorrect.value ? "사용자 닉네임은 4자 이상이어야 합니다."
                              : "이미 사용중인 닉네임 입니다.",
                          color: isNicknameCorrect.value && isNicknameNotDuplicate.value && isNicknameEmpty.value ? isTapNicknameOkBtn.value ? ColorConstants.red : ColorConstants.halfWhite :
                          isNicknameCorrect.value && isNicknameNotDuplicate.value ? ColorConstants.halfWhite :
                          !isNicknameCorrect.value ? ColorConstants.red
                              : ColorConstants.red,
                          fontSize: 11,
                          maxLine: 2,
                        )),

                        SizedBox(height: 25,),
                      ]
                  ),
                )
              ],
            ),

            GestureDetector(
              onTap: () async {
                isTapNicknameOkBtn.value = true;
                isTapNameOkBtn.value = true;

                if(nicknameController.text.isEmpty || !isNicknameCorrect.value || nameController.text.isEmpty || !isNameCorrect.value){
                  return;
                }

                var nicknameResponse = await DioClient.checkNickname(nicknameController.text);
                if(nicknameResponse.data["result"]["success"]){
                  isNicknameNotDuplicate.value = false;
                  return;
                }

                var response = await DioClient.updateAccount(nameController.text, nicknameController.text);
                Constants.user = UserModel.fromJson(response.data["result"]["user"]);
                Utils.showToast("계정 수정이 완료되었습니다.");
                Get.back();
              },
              child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFFE99315),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      "저장",
                      style: TextStyle(
                          color: Color(0xFFFFFFFFF),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          fontFamily: FontConstants.AppFont),
                    ),
                  )),
            )
          ],
        )
    );

  }
}