import 'package:app/global/DioClient.dart';
import 'package:app/models/CommunityModel.dart';
import 'package:app/models/GameModel.dart';
import 'package:app/pages/components/loading_widget.dart';
import 'package:app/pages/screens/communityScreens/nicknameScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../models/User.dart';
import '../../base/base_state.dart';
import '../../components/GameUserPageWidget.dart';
import '../../components/UserListItemWidget.dart';
import '../../components/app_text.dart';

class ProfileFollowingGameScreen extends StatefulWidget {
  ProfileFollowingGameScreen({Key? key, required this.user, required this.refreshList}) : super(key: key);
  UserModel user;
  Function() refreshList;

  @override
  State<ProfileFollowingGameScreen> createState() => _MemberScreen();
}

class _MemberScreen extends BaseState<ProfileFollowingGameScreen> {

  late UserModel user;

  late List<GameModel> games;
  late Future gameFuture;
  int gamePage = 0;
  bool hasGameNextPage = false;
  bool isLoading = false;
  ScrollController userScrollController = ScrollController();

  Future<List<GameModel>> initUsers() async{
    var response = await DioClient.getUserGameList(user.id);
    games = response.data["result"] == null ? [] : response
        .data["result"].map((json) => GameModel.fromJson(json)).toList().cast<
        GameModel>();
    for(int i=0;i<games.length;i++){
      games[i].isFollow = true;
    }
    return games;
  }

  @override
  void initState() {
    user = widget.user;
    gameFuture = initUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ColorConstants.colorBg1,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: Get.height * 0.06,
                left: Get.width * 0.05,
                right: Get.width * 0.05,
                bottom: 15),
            child:Row(
              children: [
                GestureDetector(
                  onTap:(){
                    Get.back();
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: Get.width * 0.01,
                ),
                AppText(
                  text: "팔로잉 중인 게임",
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),

          FutureBuilder(
            future: gameFuture,
            builder: (context, snapshot){
              if(snapshot.hasData){
                if(games.isEmpty){
                  return Expanded(
                      child: Center(
                        child: AppText(
                          text: "팔로잉중인 게임이 없습니다",
                          fontSize: 13,
                          color: ColorConstants.halfWhite,
                        ),
                      )
                  );
                }

                return Expanded(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      removeLeft: true,
                      removeRight: true,
                      removeBottom: true,
                      child: ListView.builder(
                          controller: userScrollController,
                          itemCount: games.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 15,left: 10, right: 10),
                          itemBuilder: (context,index){
                            Key key = Key(games[index].id.toString());
                            return GameUserPageWidget(key: key, game: games[index], isAction: true, removeItem: (){
                              widget.refreshList();
                            },);
                          }),
                    )
                );
              }
              return Expanded(
                child: Center(
                  child: LoadingWidget(),
                ),
              );
            },
          )

        ],
      ),
    );
  }
}
