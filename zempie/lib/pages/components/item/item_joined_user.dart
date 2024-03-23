import 'package:app/Constants/Constants.dart';
import 'package:app/models/dto/user_dto.dart';
import 'package:app/pages/components/item/item_user_name.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/global/app_colors.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/models/dto/chat_room_dto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import '../../../Constants/ColorConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../Constants/ImageUtils.dart';
import '../../../Constants/utils.dart';
import '../../../global/DioClient.dart';
import '../../../models/res/btn_bottom_sheet_model.dart';
import '../BtnBottomSheetWidget.dart';
import '../app_text.dart';
import '../report_user_dialog.dart';

class ItemJoinedUser extends StatefulWidget {
  UserDto info;
  ItemJoinedUser({Key? key, required this.info}) : super(key: key);

  @override
  State<ItemJoinedUser> createState() {
    // TODO: implement createState
    return _ItemJoinedUser();
  }
}
class _ItemJoinedUser extends State<ItemJoinedUser> {
  late UserDto user;

  @override
  void initState() {
    user = widget.info;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 10),

            ImageUtils.ProfileImage(user.picture ?? "", 45, 45),

            const SizedBox(width: 10),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserNameWidget(user: user),
                    SizedBox(height: 3,),
                    AppText(
                      text: user.nickname ?? '',
                      overflow: TextOverflow.ellipsis,
                      fontSize: 12,
                      maxLine: 1,
                      color: ColorConstants.halfWhite,
                    ),
                  ],
                )),

            if(user.id != (Constants.user.id ?? 0))
              !(user.is_following ?? false) ?
              GestureDetector(
                onTap: () async {
                  setState(() {
                    user.is_following = true;
                  });
                  var response = await DioClient.postUserFollow(user.id);
                },
                child: ImageUtils.setImage(ImageConstants.followUser, 30, 30),
              )
                  :
              GestureDetector(
                  onTap: (){
                    List<BtnBottomSheetModel> items = [];
                    items.add(BtnBottomSheetModel(ImageConstants.reportUserIcon, "user_report".tr(), 0));
                    items.add(BtnBottomSheetModel(ImageConstants.block, "user_block".tr(), 1));
                    items.add(BtnBottomSheetModel(ImageConstants.unSubscribe, "follow_cancel".tr(), 2));


                    Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BtnBottomSheetWidget(btnItems: items, onTapItem: (menuIndex) async {
                      if(menuIndex == 0){
                        showModalBottomSheet<dynamic>(
                            isScrollControlled: true,
                            context: context,
                            useRootNavigator: true,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext bc) {
                              return ReportUserDialog(onConfirm: (reportList, reason) async {
                                var response = await DioClient.reportUser(user.id, reportList, reason);
                                Utils.showToast("report_complete".tr());
                              },);
                            }
                        );
                      }else if(menuIndex == 1){
                        var response = await DioClient.postUserBlock(user.id);
                        Utils.showToast("ban_complete".tr());
                      }else {
                        setState(() {
                          user.is_following = false;
                        });
                        var response = await DioClient.postUserUnFollow(user.id);
                      }
                    }));
                  },
                  child: SvgPicture.asset(ImageConstants.moreIcon, width: 30,)
              ),
            const SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
