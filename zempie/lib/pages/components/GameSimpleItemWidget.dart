

import 'package:app/models/CommunityModel.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/ImageUtils.dart';
import '../base/base_state.dart';
import '../screens/discover/DiscoverGameDetails.dart';
import 'item/TagCreator.dart';
import 'item/TagDev.dart';

class GameSimpleItemWidget extends StatefulWidget {
  GameSimpleItemWidget({Key? key, required this.game}) : super(key: key);
  GameModel game;

  @override
  State<GameSimpleItemWidget> createState() => _GameSimpleItemWidget();
}

class _GameSimpleItemWidget extends BaseState<GameSimpleItemWidget> {
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
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle
                  ),
                  child: ImageUtils.setRectNetworkImage(
                      game.urlThumb,
                      45,
                      45
                  ),
                ),
                SizedBox(width: 10),

                Flexible(
                    child:AppText(text: game.title,
                        fontSize: 13,
                        color: ColorConstants.white,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLine: 2,
                        fontFamily: FontConstants.AppFont,
                        fontWeight: FontWeight.w400
                    )
                ),

                SizedBox(width: 15,)
              ],
            ),

            SizedBox(height: 25,)
          ],
        )
      ),
    );
  }
}
