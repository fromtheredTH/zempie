import 'dart:io';
import 'dart:ui';

import 'package:app/Constants/ImageUtils.dart';
import 'package:app/global/DioClient.dart';
import 'package:app/models/HexColor.dart';
import 'package:app/models/PostModel.dart';
import 'package:app/pages/base/base_state.dart';
import 'package:app/pages/components/BottomPostCommunityWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:rich_text_view/rich_text_view.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../Constants/ColorConstants.dart';
import '../../Constants/Constants.dart';
import '../../Constants/FontConstants.dart';
import '../../Constants/ImageConstants.dart';
import '../../Constants/utils.dart';
import '../../models/ChannelModel.dart';
import '../../models/GameModel.dart';
import '../../models/PostFileModel.dart';
import '../../models/User.dart';
import '../../models/dto/file_dto.dart';
import '../components/BottomPostGameWidget.dart';
import '../components/GalleryBottomSheet.dart';
import '../components/MyAssetPicker.dart';
import '../components/UserListItemWidget.dart';
import '../components/app_text.dart';
import '../components/dialog.dart';
import '../components/item/mentionable_text_field/src/mentionable_text_field.dart';

class NewPostScreen extends StatefulWidget {
  NewPostScreen({Key? key, required this.uploadedPost, this.firstChannel, this.firstGame, this.post}) : super(key: key);
  Function(PostModel) uploadedPost;
  ChannelModel? firstChannel;
  GameModel? firstGame;
  PostModel? post;

  @override
  State<NewPostScreen> createState() {
    // TODO: implement createState
    return _NewPostScreen();
  }
}

class _NewPostScreen extends BaseState<NewPostScreen> {


   List<UserModel> mentionUsers = [];
   MentionTextEditingController? mentionController;

   String postContent = "";

   GameModel? selectedGame;
   List<ChannelModel> selectedChannels = [];
   List<PostFileModel> fileModels = [];
   int fileIndex = 0;

   FocusNode _node = FocusNode();
   bool isKeyboardVisible = false;
   bool focusChanged = false;
   int selectedBg = 0;

   String content = "";

   Future<void> getUpdatePost() async {
     var response = await DioClient.getPost(widget.post!.id);

     List<dynamic> comList = response.data["posted_at"]["posted_at"][0]["communities"] ?? [];
     selectedChannels = comList.map((json) {
       ChannelModel channel = ChannelModel.fromJson(json);
       channel.id = json["channel_id"];
       channel.communityId = json["id"];
       return channel;
     }).toList();
     List<dynamic> gameList = response.data["posted_at"]["posted_at"][0]["games"] ?? [];
     List<GameModel> games = gameList.map((json) => GameModel.fromJson(json)).toList();
     if(games.isNotEmpty){
       selectedGame = games.first;
     }
     if(response.data["posted_at"]["background_id"] != null){
       for(int i=0;i<Constants.bgLists.length;i++) {
         if(response.data["posted_at"]["background_id"] == Constants.bgLists[i].id) {
           selectedBg = i+1;
           break;
         }
       }
     }
     content = response.data["contents"];
     if(mentionController != null){
       mentionController!.text = content;
     }
     List<dynamic> attatchmentFile = response.data["attatchment_files"] ?? [];

     List<PostFileModel> files = [];
     for(int i=0;i<attatchmentFile.length;i++){
       String url = attatchmentFile[i]["url"] ?? "";
       File file = await ImageUtils.urlToFile(url, i);
       PostFileModel item = PostFileModel(i, attatchmentFile[i]["type"], file, null);
       fileModels.add(item);
     }

     setState(() {

     });
   }

   @override
  void initState() {
     if(widget.post != null){
       getUpdatePost();
     }
     if(widget.firstChannel != null){
       selectedChannels.add(widget.firstChannel!);
     }
     selectedGame = widget.firstGame;
     _node.addListener(() {
       setState(() {
         isKeyboardVisible = _node.hasFocus;
       });
     });
    super.initState();

  }

   Future<bool> _promptPermissionSetting() async {
     if (Platform.isIOS) {
       if (await Permission.photos.request().isGranted || await Permission.storage.request().isGranted) {
         return true;
       }
     }
     if (Platform.isAndroid) {
       if (await Permission.storage.request().isGranted ||
           await Permission.photos.request().isGranted &&
               await Permission.videos.request().isGranted) {
         return true;
       }
     }
     return false;
   }

   Future<void> procAssets(List<AssetEntity>? assets) async {
     if (assets != null) {
       await Future.forEach<AssetEntity>(assets, (file) async {
         File? f = await file.originFile;
         if (file.type == AssetType.video) {
           //thumbnail
           final fileName = await VideoThumbnail.thumbnailFile(
             video: f!.path,
             thumbnailPath: (await getTemporaryDirectory()).path,
             imageFormat: ImageFormat.PNG,
             quality: 100,
           );
           if (fileName != null) {
             setState(() {
               fileModels.add(PostFileModel(fileIndex++, "video", f!, File(fileName)));
             });
           }
         } else {
           setState(() {
             fileModels.add(PostFileModel(fileIndex++, "image", f!, null));
           });
         }
       });
     }
   }

   Future<void> procAssetsWithGallery(List<Medium> assets) async {

     await Future.forEach<Medium>(assets, (file) async {
       File? f = await file.getFile();
       if (file.mediumType == MediumType.video) {
         //thumbnail
         final fileName = await VideoThumbnail.thumbnailFile(
           video: f.path,
           thumbnailPath: (await getTemporaryDirectory()).path,
           imageFormat: ImageFormat.PNG,
           quality: 100,
         );
         if (fileName != null) {
           setState(() {
             fileModels.add(PostFileModel(fileIndex++, "video", f!, File(fileName)));
           });
         }
       } else {
         setState(() {
           fileModels.add(PostFileModel(fileIndex++, "image", f!, null));
         });
       }
     });
   }

   Future<void> allFileUpload() async {
     for(int i=0;i<fileModels.length;i++){
       if(fileModels[i].type == "image"){
         await uploadImage(fileModels[i].file, i);
       }else{
         await uploadVideo(fileModels[i].file, i);
       }
     }
   }

   Future<void> uploadImage(File file, int index) async {
     var response = await apiP
         .uploadFile(
         "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken
           ()}", [file]);
       List<FileDto> images = response.result.where((element) => element.type == "image").toList();
       if(images.length != 0){
         fileModels[index].dto = images[0];
       }
   }

   Future<void> uploadVideo(File video, int index) async {
     var response = await apiP
         .uploadFile("Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}", [video]);

       List<FileDto> videos = response.result.where((element) => element.type == "video").toList();
       if(videos.length != 0){
         fileModels[index].dto = videos[0];
       }

   }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {

        if(fileModels.length != 0 || (mentionController?.buildMentionedValue() ?? "").isNotEmpty || selectedChannels.length != 0 || selectedGame != null) {
          AppDialog.showConfirmDialog(
              context, "delete_post".tr(), "정말로 삭제하시겠습니까?", () async {
            Get.back();
          });
          return false;
        }

        return true;
      },
      child: Scaffold(
          backgroundColor: ColorConstants.colorBg1,
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              SizedBox(height: Get.height*0.07),
              Padding(
                padding:  EdgeInsets.only(right: Get.width*0.04,left: Get.width*0.04),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                            onTap: (){
                              if(fileModels.length != 0 || (mentionController?.buildMentionedValue() ?? "").isNotEmpty || selectedChannels.length != 0 || selectedGame != null) {
                                AppDialog.showConfirmDialog(
                                    context, "new_post_cancel".tr(), "new_post_cancel_desc".tr(), () async {
                                  Get.back();
                                });
                              }else {
                                Get.back();
                              }
                            },
                            child: Icon(Icons.arrow_back_ios, color:Colors.white)),
                        AppText(
                          text: "new_post".tr(),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),

                    GestureDetector(
                      onTap: () async {
                        if(_node.hasFocus){
                          _node.unfocus();
                        }else{
                          showLoading();
                          await allFileUpload();
                          String content = mentionController!.buildMentionedValue();
                          List<Map<String,dynamic>> channels = selectedChannels.map((e) => e.toJson()).toList();

                          if(widget.post != null){
                            var response = await DioClient.editPosting(
                              widget.post!.id,
                                content,
                                fileModels.map((e) => e.dto!).toList(),
                                channels,
                                selectedGame,
                                selectedBg != 0 ? Constants.bgLists[selectedBg -
                                    1].id : null
                            );
                            PostModel newPost = PostModel.fromJson(response.data);
                            widget.uploadedPost(newPost);
                            Utils.showToast("edited_post".tr());
                          }else {
                            var response = await DioClient.uploadPosting(
                                content,
                                fileModels.map((e) => e.dto!).toList(),
                                channels,
                                selectedGame,
                                selectedBg != 0 ? Constants.bgLists[selectedBg -
                                    1].id : null
                            );
                            PostModel newPost = PostModel.fromJson(response.data);
                            widget.uploadedPost(newPost);
                            Utils.showToast("uploaded_post".tr());
                          }
                          // widget.uploadedPost(PostModel.fromJson(response.data));
                          hideLoading();
                          Get.back();
                        }
                      },
                      child: AppText(
                        text: _node.hasFocus ? "confirm".tr() : "upload_ok".tr(),
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: Get.height*0.015),

              Container(
                height: Get.height*0.5,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                          selectedBg == 0 ? "" : Constants.bgLists[selectedBg-1].imgUrl,
                        ),
                        fit: BoxFit.fill
                    ),
                    color: selectedBg == 0 ? ColorConstants.colorBg1 : HexColor(Constants.bgLists[selectedBg-1].hexColor)
                ),
                child: Column(
                  children: [

                    if(!isKeyboardVisible)
                      Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: SizedBox(
                          width: double.maxFinite,
                          height: 80, // Adjust the height according to your needs
                          child: ListView.builder(
                            itemCount: Constants.bgLists.length+1,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (context, index){
                              return GestureDetector(
                                onTap: (){
                                  setState(() {
                                    selectedBg = index;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 15),
                                  decoration: BoxDecoration(
                                      color: index == 0 ? ColorConstants.colorBg1 : HexColor(Constants.bgLists[index-1].hexColor),
                                      border: Border.all(
                                        color: index == selectedBg ? ColorConstants.colorMain : Color(0xff4f4f4f),
                                        width: 1,
                                      ),
                                    borderRadius: BorderRadius.circular(2)
                                  ),
                                  child: ImageUtils.setGameListNetworkImage(index == 0 ? "" : Constants.bgLists[index-1].imgUrl),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF6B3E54), // First color: 6B3E54
                                        Color(0xFF274A80), // Second color: 274A80
                                      ],
                                    ),
                                  ),
                                  child:
                                  Column(
                                    children: [

                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              top: 0, left: 15, right: 15, bottom: 15),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              color: Colors.black12
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: MentionableTextField(
                                                  focusNode: _node,
                                                  maxLength: 5000,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontFamily: FontConstants.AppFont,
                                                      color: ColorConstants.white
                                                  ),
                                                  decoration: InputDecoration(
                                                      hintText: "new_post_input_content".tr(),
                                                      hintStyle: TextStyle(
                                                          fontSize: 13,
                                                          fontFamily: FontConstants.AppFont,
                                                          color: ColorConstants.halfWhite
                                                      ),
                                                      border: InputBorder.none,
                                                      contentPadding: EdgeInsets.zero
                                                  ),
                                                  onControllerReady: (value) {
                                                    mentionController = value;
                                                    if(widget.post != null){
                                                      mentionController!.text = content;
                                                    }
                                                  },
                                                  onChanged: (changedText){
                                                    print(changedText);
                                                  },
                                                  mentionables: Constants.myFollowings,
                                                  mentionStyle: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: FontConstants.AppFont,
                                                      color: ColorConstants.blue1
                                                  ),
                                                  onMentionablesChanged: (users) {
                                                    if (users.length == 0 &&
                                                        !mentionController!.buildMentionedValue()
                                                            .endsWith("@")) {
                                                      setState(() {
                                                        mentionUsers.clear();
                                                      });
                                                      return;
                                                    }
                                                    mentionUsers.clear();
                                                    for (int i = 0; i < users.length; i++) {
                                                      UserModel model = users[i] as UserModel;
                                                      mentionUsers.add(model);
                                                    }
                                                    List<int> followIdList = mentionUsers.map((
                                                        e) => e.id).toList();
                                                    for (int i = 0; i <
                                                        Constants.myFollowings.length; i++) {
                                                      if (!followIdList.contains(
                                                          Constants.myFollowings[i].id)) {
                                                        mentionUsers.add(
                                                            Constants.myFollowings[i]);
                                                      }
                                                    }
                                                    setState(() {

                                                    });
                                                  },
                                                  inputFormatters: [

                                                  ],
                                                ),
                                              ),

                                              SizedBox(
                                                height: 20,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .spaceEvenly,

                                                  children: [
                                                    AppText(
                                                      text: "HP",
                                                      fontSize: 0.014,
                                                      color: Colors.white,
                                                      fontFamily: FontConstants.AppFont,
                                                      fontWeight: FontWeight.w700,
                                                    ),

                                                    SizedBox(width: 10,),

                                                    Flexible(child: Container(
                                                      height: 4,
                                                      // Adjust the height of the progress indicator
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        // Set borderRadius to make corners rounded
                                                        color: Colors
                                                            .white, // Set background color to white
                                                      ),
                                                      child: LinearProgressIndicator(
                                                        value: mentionController == null ? 1 : 1 - mentionController!.buildMentionedValue().length.toDouble()/5000.0,
                                                        // Specify the value to indicate the progress
                                                        backgroundColor: Colors.transparent,
                                                        // Make the background color of the progress indicator transparent
                                                        valueColor: AlwaysStoppedAnimation<
                                                            Color>(Colors
                                                            .red), // Set value color to red
                                                      ),
                                                    ),)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),


                                    ],
                                  )
                              ),
                            ),

                            if(mentionUsers.isNotEmpty)
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: double.maxFinite,
                                    decoration: BoxDecoration(
                                      color: Color(0xff424451),
                                    ),
                                    constraints: BoxConstraints(
                                        maxHeight: Get.height * 0.2,
                                        minHeight: Get.height * 0.05
                                    ),
                                    child: ListView.builder(
                                        itemCount: mentionUsers.length,
                                        padding: EdgeInsets.only(top: 10, bottom: 10),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          Key key = Key(mentionUsers[index].id.toString());
                                          return Padding(
                                            padding: EdgeInsets.only(left: 10, right: 10),
                                            child: GestureDetector(
                                              onTap: () {
                                                mentionController!.pickMentionable(
                                                    mentionUsers[index]);
                                                setState(() {
                                                  mentionUsers.clear();
                                                });
                                              },
                                              child: UserListItemWidget(key: key,
                                                user: mentionUsers[index],
                                                isShowAction: false,
                                                isMini: true,
                                                deleteUser: () {},),
                                            ),
                                          );
                                        }
                                    ),
                                  ),
                                ),
                              )
                          ],
                        )
                    ),

                    if(fileModels.length != 0)
                      Column(
                        children: [

                          SizedBox(
                              height: isKeyboardVisible ? 0 : Get.height*0.09, // Adjust the height according to your needs
                              child: ListView.builder(
                                  itemCount: fileModels.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context,index){

                                    return  Container(
                                      height: Get.height*0.08,
                                      width: Get.height*0.08,
                                      margin: EdgeInsets.only(right: Get.width*0.03,top: Get.height*0.01),
                                      decoration: BoxDecoration(
                                          color:  Color(0xFFD0CDCD),
                                          borderRadius: BorderRadius.circular(5),
                                          image: DecorationImage(
                                              image: FileImage(
                                                fileModels[index].type == "image" ? fileModels[index].file : fileModels[index].videoThumbnail!,
                                              ),
                                              fit: BoxFit.cover
                                          )
                                      ),
                                      child: ClipRRect( // make sure we apply clip it properly
                                        child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: fileModels[index].isBlur ? 5 : 0, sigmaY: fileModels[index].isBlur ? 5 : 0),
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 5,right: 5,left: 6),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  GestureDetector(
                                                    onTap: (){
                                                      setState(() {
                                                        fileModels[index].isBlur = !fileModels[index].isBlur;
                                                      });
                                                    },
                                                    child: Icon(fileModels[index].isBlur ? Icons.visibility_outlined : Icons.visibility_off_outlined ,color: Color(0xFFe0e0e0),
                                                      size: 18,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){
                                                      setState(() {
                                                        fileModels.removeAt(index);
                                                      });
                                                    },
                                                    child: Icon(Icons.cancel_outlined,color: Color(0xFFe0e0e0), size: 18,),
                                                  )
                                                ],

                                              ),
                                            )
                                        ),
                                      ),
                                    );
                                  })
                          ),
                        ],
                      ),


                  ],
                ),
              ),

              Column(
                children: [
                  SizedBox(height: Get.height*0.01,),
                  Padding(
                    padding:  EdgeInsets.only(right: Get.width*0.04,left: Get.width*0.04,
                        top: Get.height*0.02
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if(fileModels.length < 5) {
                              if (await _promptPermissionSetting()) {
                                AssetEntity? assets = await MyAssetPicker
                                    .pickCamera(
                                    context);
                                if (assets != null) {
                                  procAssets([assets]);
                                }
                              }
                            }else{
                              Utils.showToast("image_uploaded_limit".tr());
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.camera_alt_outlined, color:Colors.white),
                              SizedBox(width: Get.width*0.018,),
                              AppText(
                                text: "camera".tr(),
                                fontSize: 14,
                                fontFamily: FontConstants.AppFont,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Get.height*0.02,),
                        GestureDetector (
                          onTap: () async {
                            if(fileModels.length < 5) {
                              if (await _promptPermissionSetting()) {
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    backgroundColor: Colors.transparent,
                                    constraints: BoxConstraints(
                                      minHeight: 0.8,
                                      maxHeight: Get.height * 0.95,
                                    ),
                                    builder: (BuildContext context) {
                                      return DraggableScrollableSheet(
                                          initialChildSize: 0.5,
                                          minChildSize: 0.4,
                                          maxChildSize: 0.9,
                                          expand: false,
                                          builder: (_, controller) =>
                                              GalleryBottomSheet(
                                                controller: controller,
                                                limitCnt: 5 - fileModels.length,
                                                onTapSend: (results) {
                                                  procAssetsWithGallery(results);
                                                },
                                              )
                                      );
                                    }
                                );
                              }
                            }else{
                              Utils.showToast("image_uploaded_limit".tr());
                            }
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(ImageConstants.imageSquare,height: Get.height*0.03,),
                              SizedBox(width: Get.width*0.018,),
                              AppText(
                                text: "camera_gallery".tr(),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Get.height*0.02,),
                        GestureDetector(
                          onTap: (){
                            Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BottomPostCommunityWidget(
                              selectedChannels: selectedChannels,
                              onSelectChannels: (channels){
                                setState(() {
                                  selectedChannels = channels;
                                });
                              },
                            ),backgroundColor: ColorConstants.colorBg1,isScrollControlled:true);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(ImageConstants.timeLine,height: Get.height*0.03,),
                                  SizedBox(width: Get.width*0.018,),
                                  AppText(
                                    text: "community_tag".tr(),
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: FontConstants.AppFont,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  AppText(
                                    text: "community_tag_count".tr(args: [selectedChannels.length.toString()]),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  SizedBox(width: Get.width*0.018,),

                                  Icon(Icons.arrow_forward_ios,size: Get.height*0.02,
                                    color: Colors.white,
                                  ),

                                ],
                              ),

                            ],
                          ),
                        ),
                        SizedBox(height: Get.height*0.02,),
                        GestureDetector(
                          onTap: (){
                            Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BottomPostGameWidget(
                              selectedGame: selectedGame,
                              onSelectGame: (game){
                                setState(() {
                                  selectedGame = game;
                                });
                              },
                            ),
                                backgroundColor: ColorConstants.colorBg1
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(ImageConstants.gameImage,height: Get.height*0.03,),
                                  SizedBox(width: Get.width*0.018,),
                                  AppText(
                                    text: "game_tag".tr(),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  AppText(
                                    text: "${selectedGame?.title ?? ""}",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  SizedBox(width: Get.width*0.018,),

                                  Icon(Icons.arrow_forward_ios,size: Get.height*0.02,
                                    color: Colors.white,
                                  ),

                                ],
                              ),


                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )
      )
    );
  }
}

