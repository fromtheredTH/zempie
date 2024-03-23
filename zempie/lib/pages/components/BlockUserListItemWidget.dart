

import 'package:app/Constants/Constants.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/components/BtnBottomSheetWidget.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/ImageUtils.dart';
import '../../Constants/utils.dart';
import '../../models/res/btn_bottom_sheet_model.dart';
import '../base/base_state.dart';
import '../screens/profile/profile_screen.dart';
import 'item/TagCreator.dart';
import 'item/TagDev.dart';
import 'loading_widget.dart';

class BlockUserListItemWidget extends StatefulWidget {
  BlockUserListItemWidget({Key? key, required this.user, required this.deleteUser}) : super(key: key);
  UserModel user;
  Function() deleteUser;

  @override
  State<BlockUserListItemWidget> createState() => _BlockUserListItemWidget();
}

class _BlockUserListItemWidget extends BaseState<BlockUserListItemWidget> {
  late UserModel user;

  late List<UserModel> users;
  late Future userFuture;
  int userPage = 0;
  bool hasUserNextPage = false;
  bool isLoading = false;
  ScrollController userScrollController = ScrollController();

  Future<List<UserModel>> initUsers() async{
    var response = await DioClient.getBlockUsers(20, 0);
    List<UserModel> userResults = response.data["result"] == null ? [] : response
        .data["result"].map((json) => UserModel.fromJson(json)).toList().cast<
        UserModel>();
    userPage = 1;
    hasUserNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
    users = userResults;

    return users;
  }

  Future<void> getUserNextPage() async {
    if (!isLoading && userScrollController.position.extentAfter < 200 && hasUserNextPage) {
      var response = await DioClient.getBlockUsers(20, userPage);
      List<UserModel> userResults = response.data["result"] == null ? [] : response
          .data["result"].map((json) => UserModel.fromJson(json)).toList().cast<
          UserModel>();
      userPage += 1;
      hasUserNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
      setState(() {
        users.addAll(userResults);
      });
      isLoading = true;
    }
  }

  @override
  void initState() {
    user = widget.user;
    userFuture = initUsers();
    super.initState();
    userScrollController.addListener(getUserNextPage);
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: Get.width*0.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      Get.to(ProfileScreen(user: user));
                    },
                    child: ClipOval(
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle
                        ),
                        child: ImageUtils.ProfileImage(
                            user.picture,
                            45,
                            45
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Get.width*0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(text: user.nickname,
                          fontSize: 13,
                          color: ColorConstants.white,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w700
                      ),

                      SizedBox(height: 5,),

                      AppText(text: user.name,
                          fontSize: 13,
                          color: ColorConstants.halfWhite,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          fontFamily: FontConstants.AppFont,
                          fontWeight: FontWeight.w400
                      )
                    ],
                  )
                ],
              ),
            ),

            GestureDetector(
              onTap: () async{
                await DioClient.userUnBlock(user.id);
                widget.deleteUser();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: ColorConstants.red,
                        width: 1
                    )
                ),
                child: AppText(
                  text: "차단 취소",
                  color: ColorConstants.red,
                  fontSize: 14,
                ),
              ),
            )
          ]
        ),

        SizedBox(height: 15,)
      ],
    );
  }
}
