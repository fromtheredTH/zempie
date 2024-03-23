
import 'package:app/Constants/ColorConstants.dart';
import 'package:app/Constants/ImageUtils.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:app/pages/screens/discover/discoverPostingListScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:html/parser.dart';

import '../../Constants/ImageConstants.dart';
import '../../global/DioClient.dart';
import '../../models/PostModel.dart';
import '../screens/profile/profile_screen.dart';

class DiscoverWidget extends StatefulWidget {
  DiscoverWidget({super.key, required this.post});
  PostModel post;

  @override
  State<DiscoverWidget> createState() {
    // TODO: implement createState
    return _DiscoverWidget();
  }
}

class _DiscoverWidget extends State<DiscoverWidget> {

  late PostModel post;
  String? image;
  late String contents;

  @override
  void initState() {
    post = widget.post;
    contents = post.contents;
    // 특정 태그 처리
    contents = contents.replaceAll("</p>", "</p>\n");
    contents = contents.replaceAll("<br>", "<br>\n");
    contents = contents.replaceAll("<hr>", "<hr>\n");
    contents = contents.replaceAll("<strong>", "<strong>\n\n");
    contents = contents.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
    if(post.attachmentFiles.isNotEmpty){
      image = post.attachmentFiles[0].url;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        Get.to(DiscsoverPostingListScreen(post: post));
      },
      child: Padding(
        padding:  EdgeInsets.only(
          right: Get.width*0.02,
          left: Get.width*0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: Get.width * 0.4 * 1.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Same as the BoxDecoration's borderRadius
                    child: ImageUtils.setPostNetworkImage(
                      image ?? "",
                      contents,
                      Get.width,
                      Get.height*0.38,
                    ),
                  ),
                  if(post.contents.isNotEmpty && image != null && image!.isNotEmpty)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: Get.height*0.07,
                        width: Get.width,
                        decoration: BoxDecoration(
                            color: ColorConstants.halfBlack
                        ),
                        child: Padding(
                          padding:  EdgeInsets.all(Get.height*0.01),
                          child: Center(
                            child: AppText(
                              text: contents,
                              fontSize: 13,
                              maxLine: 2,
                              overflow: TextOverflow.ellipsis,
                              color: ColorConstants.white,
                            ),
                          )
                        ),
                      ),
                    )
                ],
              ),
            ),
            SizedBox(height: Get.height*0.015,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Get.to(ProfileScreen(user: post.user));
                          },
                          child:
                          ImageUtils.ProfileImage(post.user.picture, 24, 24),
                        ),
                        SizedBox(width: Get.width*0.01,),
                        Expanded(
                            child: GestureDetector(
                              onTap: (){
                                Get.to(ProfileScreen(user: post.user));
                              },
                              child:
                              AppText(
                                text: "${post.user.nickname}",
                                fontSize: 12,
                                overflow: TextOverflow.ellipsis,
                                color: ColorConstants.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ),

                        SizedBox(width: 5,)

                      ],
                    ),
                ),

                Row(
                  children: [
                    GestureDetector(
                        onTap: () async {
                          setState(() {
                            post.liked = !post.liked;
                          });
                          if(post.liked){
                            post.likeCount = post.likeCount + 1;
                            try{
                              var response = await DioClient.likePost(post.id);
                            }catch(e){
                              setState(() {
                                post.liked = !post.liked;
                                post.likeCount = post.likeCount - 1;
                              });
                            }
                          }else{
                            post.likeCount = post.likeCount - 1;
                            try{
                              var response = await DioClient.unLikePost(post.id);
                            }catch(e){
                              setState(() {
                                post.liked = !post.liked;
                                post.likeCount = post.likeCount + 1;
                              });
                            }
                          }
                        },
                        child: Image.asset(post.liked ? ImageConstants.heart : ImageConstants.unHeart, width: 24, height: 24,)
                    ),
                    SizedBox(width: Get.width*0.01,),
                    AppText(
                      text: "${post.likeCount}",
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}