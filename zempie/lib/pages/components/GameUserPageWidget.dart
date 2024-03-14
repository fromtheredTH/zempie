

import 'package:app/global/DioClient.dart';
import 'package:app/models/CommunityModel.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/components/BtnBottomSheetWidget.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:app/pages/components/report_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
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
import '../screens/discover/DiscoverGameDetails.dart';
import 'item/TagCreator.dart';
import 'item/TagDev.dart';

class GameUserPageWidget extends StatefulWidget {
  GameUserPageWidget({Key? key, required this.game,required this.isAction, required this.removeItem}) : super(key: key);
  GameModel game;
  bool isAction;
  Function() removeItem;

  @override
  State<GameUserPageWidget> createState() => _GameSimpleItemWidget();
}

class _GameSimpleItemWidget extends BaseState<GameUserPageWidget> {
  late GameModel game;

  @override
  void initState() {
    game = widget.game;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: (){
        Get.to(DiscoverGameDetails(game: game, refreshGame: (game){
          this.game = game;
        },));
      },
      child: Column(
        children: [
          Container(
            width: Get.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                      border: Border.all(color: ColorConstants.white, width: 1)
                  ),
                  child: ImageUtils.setRectNetworkImage(
                      game.urlThumb,
                      45,
                      45
                  ),
                ),
                SizedBox(width: 10),

                Expanded(
                  child: Text.rich(
                    maxLines: 2,
                    TextSpan(
                      text: game.title,
                      style: TextStyle(
                        color: ColorConstants.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        fontFamily: FontConstants.AppFont,
                        overflow: TextOverflow.ellipsis,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: ' by @${game.user?.nickname ?? ""}',
                            style: TextStyle(
                              color: ColorConstants.halfWhite,
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              fontFamily: FontConstants.AppFont,
                              overflow: TextOverflow.ellipsis,
                            )
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 15,),

                if(widget.isAction)
                  game.isFollow ?
                  GestureDetector(
                    onTap: (){
                      List<BtnBottomSheetModel> items = [];
                      items.add(BtnBottomSheetModel(ImageConstants.unSubscribe, "팔로우 취소", 0));
                      items.add(BtnBottomSheetModel(ImageConstants.report, "게임 신고", 1));

                      Get.bottomSheet(BtnBottomSheetWidget(btnItems: items, onTapItem: (menuIndex) async {
                        if(menuIndex == 0){
                          setState(() {
                            game.isFollow = false;
                          });
                          await DioClient.postGameUnFollow(game.id);
                        }else{
                          showModalBottomSheet<dynamic>(
                              isScrollControlled: true,
                              context: context,
                              useRootNavigator: true,
                              backgroundColor: Colors.transparent,
                              builder: (BuildContext bc) {
                                return ReportDialog(type: "game", onConfirm: (reportList, reason) async {
                                  var response = await DioClient.reportGame(game.id, reportList, reason);
                                  Utils.showToast("report_complete".tr());
                                },);
                              }
                          );
                        }
                      }));
                    },
                    child:
                    SvgPicture.asset(ImageConstants.moreIcon),
                  )
                      : GestureDetector(
                    onTap: () async {
                      var response = await DioClient.postGameFollow(game.id);
                      setState(() {
                        game.isFollow = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorConstants.white,width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: AppText(
                          text: "팔로우",
                          color: ColorConstants.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),

          SizedBox(height: 15,),
        ],
      ),
    );
  }
}
