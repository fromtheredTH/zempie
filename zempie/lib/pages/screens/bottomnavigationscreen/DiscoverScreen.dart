import 'package:app/Constants/Constants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/Constants/RouteString.dart';
import 'package:app/models/User.dart';
import 'package:app/pages/base/base_state.dart';
import 'package:app/pages/components/CommunitySimpleItemWidget.dart';
import 'package:app/pages/components/GameSimpleItemWidget.dart';
import 'package:app/pages/components/UserListItemWidget.dart';
import 'package:app/pages/components/discover_widget.dart';
import 'package:app/pages/components/loading_widget.dart';
import 'package:app/pages/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:html/parser.dart';
import 'package:http/http.dart';
import '../../../Constants/ColorConstants.dart';
import '../../../Constants/FontConstants.dart';
import '../../../Constants/ImageConstants.dart';
import '../../../global/DioClient.dart';
import '../../../models/CommunityModel.dart';
import '../../../models/GameModel.dart';
import '../../../models/PostModel.dart';
import '../../components/CutomTitleBar.dart';
import '../../components/app_text.dart';
import '../discover/discoverSearchScreen.dart';
import 'bottomNavBarScreen.dart';

class DiscoverScreen extends StatefulWidget {
  DiscoverScreen({Key? key, this.hashTag, required this.changePage, required this.onTapLogo, required this.discoverController});
  Function(String, String) changePage;
  String? hashTag;
  Function() onTapLogo;
  HomeController discoverController;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreen(discoverController);
}

class _DiscoverScreen extends BaseState<DiscoverScreen> {

  _DiscoverScreen(HomeController discoverController){
    discoverController.initHome = initHome;
  }

  void initHome(){
    setState(() {
      isSearchMode = false;
      searchController.text = "";
    });
  }

  late Future postFuture;
  late List<PostModel> posts;
  bool isShowKeyboard = false;
  TextEditingController searchController = TextEditingController();
  String previousSearchText = "";
  bool isSearchMode = false;
  bool isSearchLoading = false;
  RxBool isExistSearchText = false.obs;
  bool isLoading = false;
  ScrollController scrollController = ScrollController();
  bool hasPostNextPage = false;
  int discoverPage = 0;

  String? hashTag;

  List<UserModel> users = <UserModel>[];
  List<GameModel> games = <GameModel>[];
  List<CommunityModel> communities = <CommunityModel>[];

  Future<List<PostModel>> initPosts() async {
    posts = Constants.discoverPosts;
    discoverPage = 1;
    hasPostNextPage = Constants.initDiscoverHasNextPage;
    return posts;
  }

  Future<void> getNextPost() async {
    if(scrollController.position.extentAfter < 200 && !isLoading && hasPostNextPage) {
      isLoading = true;
      var response = await DioClient.getDiscovers(10, discoverPage);
      List<PostModel> results = response.data["result"] == null ? [] : response
          .data["result"].map((json) => PostModel.fromJson(json)).toList().cast<
          PostModel>();
      discoverPage += 1;
      hasPostNextPage = response.data["pageInfo"]?["hasNextPage"] ?? false;
      setState(() {
        posts.addAll(results);
        isLoading = false;
      });
    }
  }

  Future<void> getSearch(String query) async {
    var response = await DioClient.searchTotal(query, 5, 0);
    List<UserModel> userResults = response.data["users"] == null ? [] : response
        .data["users"].map((json) => UserModel.fromJson(json)).toList().cast<
        UserModel>();
    List<GameModel> gameResults = response.data["games"] == null ? [] : response
        .data["games"].map((json) => GameModel.fromJson(json)).toList().cast<
        GameModel>();
    List<CommunityModel> communityResults = response.data["community"] == null ? [] : response
        .data["community"].map((json) => CommunityModel.fromJson(json)).toList().cast<
        CommunityModel>();
    setState(() {
      users = userResults;
      games = gameResults;
      communities = communityResults;
      isSearchLoading = false;
    });
  }

  @override
  void initState() {
    postFuture = initPosts();
    hashTag = widget.hashTag;
    super.initState();
    scrollController.addListener(getNextPost);
    if(hashTag != null){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        widget.changePage(RouteString.disvoerSearch, hashTag!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = size.width * 0.4 * 1.8; // Adjust the fraction as needed
    final double itemWidth = size.width * 0.4;

    return Scaffold(
      backgroundColor: ColorConstants.colorBg1,
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding:  EdgeInsets.only(right: Get.width*0.01,left: Get.width*0.01),
        child: Column(
          children: [

            Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: CustomTitleBar(callBack: (){
                  Get.to(ProfileScreen(user: Constants.user));
                },onTapLogo: (){
                  widget.onTapLogo();
                },)),
            SizedBox(height: Get.height*0.02),
            Padding(
              padding: EdgeInsets.only(
                  right: Get.width * 0.02, left: Get.width * 0.02),
              child: Container(
                width: Get.width, // Set width according to your needs
                decoration: BoxDecoration(
                  color: ColorConstants.searchBackColor,
                  borderRadius:
                  BorderRadius.circular(6.0), // Adjust the value as needed
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                        child: TextFormField(
                          controller: searchController,
                          onFieldSubmitted: (text){
                            widget.changePage(RouteString.disvoerSearch, text);
                          },
                          onChanged: (text){

                            isSearchLoading = true;
                            if(previousSearchText.isEmpty && text.isNotEmpty){
                              setState(() {
                                isSearchMode = true;
                              });
                              getSearch(text);
                              isExistSearchText.value = true;
                            }else if(previousSearchText.isNotEmpty && text.isEmpty){
                              setState(() {
                                isSearchMode = false;
                              });
                            }else{
                              print("검색");
                              print(text);
                              print(searchController.text);
                              getSearch(text);
                              isExistSearchText.value = true;
                            }
                            previousSearchText = text;
                          },
                          style: TextStyle(
                              color: ColorConstants.white,
                              fontFamily: FontConstants.AppFont,
                              fontSize: 16
                          ),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0), // Adjust vertical padding
                            border: InputBorder.none,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SvgPicture.asset(ImageConstants.searchIcon,
                                color: Colors.white,
                              ),
                            ),
                            // Align hintText to center
                            hintStyle: TextStyle(
                                color: ColorConstants.halfWhite,
                                fontFamily: FontConstants.AppFont,
                                fontSize: 16),
                            // alignLabelWithHint: true,
                          ),
                        ),
                    ),

                    Obx(() => isExistSearchText.value ?
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              isExistSearchText.value = false;
                              searchController.text = "";
                              previousSearchText = "";
                              isSearchMode = false;
                            });
                          },
                          child: ImageUtils.setImage(ImageConstants.searchX, 20, 20),
                        ) : Container()
                    ),

                    SizedBox(width: 10,)
                  ],
                )
              ),
            ),
            isSearchMode ?
            Expanded(
                child: isSearchLoading ?
                    LoadingWidget()
                    : users.length == 0 && games.length == 0 && communities.length == 0?
                Center(
                  child: AppText(
                    text: "검색 결과가 없습니다",
                    fontSize: 13,
                    color: ColorConstants.gray3,
                  ),
                )
                    : Padding(
                  padding: EdgeInsets.only(left: 10,right: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 25,),

                        users.isNotEmpty ?
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(width: 30),
                                  Expanded(child: Container(height: 0.5, color: ColorConstants.colorMain)),
                                  SizedBox(width: 20),
                                  AppText(
                                    text: "유저",
                                    fontSize: 10,
                                    color: ColorConstants.colorMain,
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(child: Container(height:0.51, color: ColorConstants.colorMain)),
                                  SizedBox(width: 30),
                                ],
                              ),
                            ),

                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: users.length,
                                itemBuilder: (context, index) {
                                  Key key = Key(users[index].id.toString());
                                  return UserListItemWidget(key: key, user: users[index], isShowAction: true, deleteUser: (){
                                    setState(() {
                                      users.removeAt(index);
                                    });
                                  },);
                                }
                            ),
                          ],
                        ) : Container(),

                        games.isNotEmpty ?
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(width: 30),
                                  Expanded(child: Container(height: 0.5, color: ColorConstants.colorMain)),
                                  SizedBox(width: 20),
                                  AppText(
                                    text: "게임",
                                    fontSize: 10,
                                    color: ColorConstants.colorMain,
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(child: Container(height:0.51, color: ColorConstants.colorMain)),
                                  SizedBox(width: 30),
                                ],
                              ),
                            ),

                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: games.length,
                                itemBuilder: (context, index) {
                                  return GameSimpleItemWidget(game: games[index]);
                                }
                            ),
                          ],
                        ) : Container(),

                        communities.isNotEmpty ?
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(width: 30),
                                  Expanded(child: Container(height: 0.5, color: ColorConstants.colorMain)),
                                  SizedBox(width: 20),
                                  AppText(
                                    text: "커뮤니티",
                                    fontSize: 10,
                                    color: ColorConstants.colorMain,
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(child: Container(height:0.51, color: ColorConstants.colorMain)),
                                  SizedBox(width: 30),
                                ],
                              ),
                            ),

                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: communities.length,
                                itemBuilder: (context, index) {
                                  return CommunitySimpleItemWidget(community: communities[index]);
                                }
                            ),
                          ],
                        ) : Container()
                      ],
                    ),
                  ),
                )
                )
            : Expanded(
                child: FutureBuilder(
                    future: postFuture,
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        return RefreshIndicator(
                            onRefresh: () async {
                              await initPosts();
                              setState(() {

                              });
                            },
                            child: GridView.builder(
                          padding: EdgeInsets.only(top: 15),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          controller: scrollController,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 1개의 행에 항목을 3개씩
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: (itemWidth / itemHeight)
                          ),
                          itemCount: hasPostNextPage ? posts.length+1 : posts.length,
                          itemBuilder: (context, index) {
                            if(posts.length == index){
                              return Padding(
                                padding: EdgeInsets.only(top: 30, bottom: 50),
                                child: LoadingWidget(),
                              );
                            }
                            return DiscoverWidget(post: posts[index]);
                          },
                        )
                        );
                      }
                      return Expanded(
                          child: LoadingWidget()
                      );
                    }
                )
            ),
            SizedBox(height: Get.height*0.05,)

          ],
        ),
      ),
    );
  }
}
