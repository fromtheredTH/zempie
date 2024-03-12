

import 'package:app/Constants/Constants.dart';
import 'package:app/models/ChannelModel.dart';
import 'package:app/models/CommunityModel.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/pages/base/base_state.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';

class BottomPostGameWidget extends StatefulWidget{
  BottomPostGameWidget({Key? key, required this.selectedGame, required this.onSelectGame}) : super(key: key);
  GameModel? selectedGame;
  Function(GameModel?) onSelectGame;

  @override
  State<BottomPostGameWidget> createState() {
    // TODO: implement createState
    return _BottomPostGameWidget();
  }
}

class _BottomPostGameWidget extends BaseState<BottomPostGameWidget> {

  GameModel? selectedGame;

  @override
  void initState() {
    selectedGame = widget.selectedGame;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: Get.width,
      height: Constants.user.games.length == 0 ? Get.height*0.32 : Get.height*0.5,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                text: "${Constants.user.games.length}",
                fontSize: 14,
                color: ColorConstants.colorMain,
                fontWeight: FontWeight.w700,
              ),
              AppText(
                text: "개 게임이 등록되어 있습니다.",
                fontSize: 14,
                color: ColorConstants.white,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),

          SizedBox(height: Get.height * 0.01,),

          Constants.user.games.length != 0 ?
              Expanded(
                  child: Column(
                    children: [
                      AppText(
                        text: "포스트를 게시할 게임 1개를 선택해 주세요.",
                        fontSize: 0.016,
                        textAlign: TextAlign.center,
                        color: ColorConstants.backGryText,
                        fontFamily: FontConstants.AppFont,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: Get.height * 0.02,),
                      Expanded(child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: Constants.user.games.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  left: Get.width * 0.04, bottom: Get.height * 0.02),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedGame = Constants.user.games[index];
                                  });
                                },
                                child: Row(
                                  children: [
                                    (selectedGame?.id ?? 0) == Constants.user.games[index].id ?
                                    SvgPicture.asset(ImageConstants.orangeCircle) :
                                    SvgPicture.asset(ImageConstants.whiteCircle),
                                    SizedBox(width: Get.width * 0.02,),
                                    AppText(
                                      text: Constants.user.games[index].title,
                                      fontSize: 14,
                                      color: (selectedGame?.id ?? 0) == Constants.user.games[index].id
                                          ? ColorConstants.yellow
                                          : ColorConstants.white,
                                    )
                                  ],
                                ),
                              )
                            );
                          }),)
                    ],
                  )
              ) : Container(
            height: Get.height*0.15,
            child: Center(
              child: AppText(
                text: "개발하신 게임이 있다면 젬파이에 등록하고,\n더 많은 유저들을 확보해 보세요.",
              ),
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
                          text: Constants.user.games.length == 0 ? "닫기" : "취소",
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
                      widget.onSelectGame(selectedGame);
                      Get.back();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                          color: ColorConstants.colorMain,
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: Center(
                        child: AppText(
                          text: Constants.user.games.length == 0 ? "게임 등록하기" : "확인",
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
