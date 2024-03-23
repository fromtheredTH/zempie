
import 'package:app/Constants/ColorConstants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:html/parser.dart';

import '../../Constants/ImageConstants.dart';
import '../../global/DioClient.dart';
import '../../models/PostModel.dart';
import '../screens/discover/DiscoverGameDetails.dart';

class GameWidget extends StatefulWidget {
  GameWidget({super.key, required this.game});
  GameModel game;

  @override
  State<GameWidget> createState() {
    // TODO: implement createState
    return _GameWidget();
  }
}

class _GameWidget extends State<GameWidget> {

  late GameModel game;
  List<String> supportedType = [];

  @override
  void initState() {
    game = widget.game;
    if(game.supportPlatform.isNotEmpty) {
      if (game.gameType == 1) {
        supportedType.add("html");
      } else {
        List<String> types = game.supportPlatform.split(",");
        if (types.contains("1"))
          supportedType.add("window");
        if (types.contains("2"))
          supportedType.add("ios");
        if (types.contains("3"))
          supportedType.add("android");
        if (types.contains("4"))
          supportedType.add("ios");
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        Get.to(DiscoverGameDetails(game: game, refreshGame: (game){
          setState(() {
            this.game = game;
          });
        },));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:  EdgeInsets.only(left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageUtils.setGameListNetworkImage(game.urlThumb),
                SizedBox(height: Get.height*0.014,),
                AppText(
                  text: game.title,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  maxLine: 1,
                ),
                SizedBox(height: Get.height*0.014,),
                supportedType.length != 0 ?
                  Column(
                    children: [
                      Container(
                        width: double.maxFinite,
                        height: 30,
                        child: ListView.builder(
                            itemCount: supportedType.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context,index){
                              return  Container(
                                  height: 24,
                                  width: 24,
                                  margin: EdgeInsets.only(right: 10),
                                  child: Center(
                                    child: Image.asset(
                                      supportedType[index] == "html" ? ImageConstants.htmlIcon :
                                      supportedType[index] == "window" ? ImageConstants.windowIcon :
                                      supportedType[index] == "mac" ? ImageConstants.macIcon :
                                      supportedType[index] == "android" ? ImageConstants.androidIcon : ImageConstants.iosIcon,
                                      width: 24,
                                      height: 24,
                                    ),
                                  )
                              );
                            }),
                      )

                    ],
                  ) : Container(height: 30),
              ],
            ),
          ),
          SizedBox(height: 15,),
          Container(color: ColorConstants.tabTextColor, height: 0.5,),
        ],
      ),
    );
  }
}