import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:app/Constants/ColorConstants.dart';
import 'package:app/Constants/ImageConstants.dart';
import 'package:app/global/app_colors.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/pages/base/base_state.dart';
import 'package:app/pages/base/page_layout.dart';
import 'package:app/pages/components/app_text.dart';
import 'package:app/pages/components/dialog.dart';
import 'package:app/pages/components/item/item_user_name.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart' hide Trans;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../models/dto/user_dto.dart';
import '../../models/res/btn_bottom_sheet_model.dart';
import 'BtnBottomSheetWidget.dart';

class ImageViewer extends StatefulWidget {
  final List<String> images;
  final int selected;
  final bool isVideo;
  final UserDto? user;

  ImageViewer(
      {super.key, required this.images, this.selected = 0, required this.isVideo, required this.user});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends BaseState<ImageViewer> {
  final ReceivePort _port = ReceivePort();

  int selectedImage = 0;
  PageController? pageController;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  int width = 0;
  int height = 0;
  int size = 0;

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      // String id = data[0];
      // DownloadTaskStatus status = data[1];
      // int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);

    pageController = PageController(initialPage: widget.selected);
    selectedImage = widget.selected;
    if (widget.isVideo) {
      initVideo();
    }
  }

  @override
  void dispose() {
    chewieController?.dispose();
    videoPlayerController?.dispose();
    pageController?.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    debugPrint('Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  Future<void> initVideo() async {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.images[0]));

    await videoPlayerController!.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: true,
      looping: true,
    );
    setState(() {});
  }

  Future<bool> onBackPressed() async {
    Navigator.pop(context);
    return false;
  }

  String sizeStr() {
    if (size < 1024) {
      return '${size}byte';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)}kb';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}mb';
    }
    return '';
  }

  Future<void> download(List<String> files, int idx) async {
    if (idx == files.length) return;

    String file_path = files[idx];
    String original_file_name = files[idx].split(Platform.pathSeparator).last;
    print("$file_path,$original_file_name");

    PermissionStatus? photos;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        photos = await Permission.storage.request();
      } else {
        photos = await Permission.photos.request();
      }
    } else if (Platform.isIOS) {
      photos = await Permission.photos.request();
    }
    debugPrint(photos?.toString());

    //file download
    String? dir;
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      dir = directory?.path;
    } else {
      dir = (await getApplicationDocumentsDirectory()).absolute.path; //path provider로 저장할 경로 가져오기
    }
    debugPrint(dir);
    if (dir == null) return;

    try {
      await FlutterDownloader.enqueue(
        url: file_path, // file url
        savedDir: dir, // 저장할 dir
        fileName: original_file_name, // 파일명
        showNotification: true, // show download progress in status bar (for Android)
        openFileFromNotification: true, // click on notification to open downloaded file (for Android)
        saveInPublicStorage: true, // 동일한 파일 있을 경우 덮어쓰기 없으면 오류발생함!
      );

      debugPrint("파일 다운로드 완료");
    } catch (e) {
      debugPrint("eerror :::: $e");
    }
    download(files, idx + 1);
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
        onBack: onBackPressed,
        isLoading: false,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: ColorConstants.colorBg1,
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: onBackPressed,
                        child: Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(left: 10),
                            child: Center(
                              child: Image.asset(ImageConstants.backWhite, width: 24, height: 24),
                            )
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                          child: UserNameWidget(user: widget.user)
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: PhotoViewGallery.builder(
                    scrollPhysics: const BouncingScrollPhysics(),
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions.customChild(
                          initialScale: 1.0,
                          maxScale: widget.isVideo ? 1.0 : 3.0,
                          minScale: 1.0,
                          heroAttributes: PhotoViewHeroAttributes(tag: widget.images[index]),
                          child: widget.isVideo
                              ? (chewieController != null
                              ? Chewie(
                            controller: chewieController!,
                          )
                              : Container())
                              : CachedNetworkImage(
                            imageUrl: widget.images[index],
                            imageBuilder: (context, imageProvider) {
                              imageProvider
                                  .resolve(const ImageConfiguration())
                                  .addListener(ImageStreamListener((image, synchronousCall) {
                                width = image.image.width;
                                height = image.image.height;
                                size = image.sizeBytes;
                              }));
                              return Image(image: imageProvider);
                            },
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                                child:
                                SizedBox(width: 40, height: 40, child: CircularProgressIndicator())),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ));
                    },
                    itemCount: widget.images.length,
                    loadingBuilder: (context, event) => Center(
                      child: SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          value:
                          event == null ? 0 : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                        ),
                      ),
                    ),
                    backgroundDecoration: const BoxDecoration(),
                    pageController: pageController,
                    onPageChanged: (value) {
                      if (selectedImage != value) {
                        selectedImage = value;
                        // catController.scrollToIndex(value);
                        setState(() {});
                      }
                    },
                  ),
                ),
                Visibility(
                  visible: !widget.isVideo,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        SizedBox(
                            height: Get.width * 0.28,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedImage = index;
                                        pageController?.jumpToPage(selectedImage);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: index == selectedImage ? ColorConstants.colorMain :Colors.transparent,
                                            width: 1
                                          )
                                        ),
                                        padding: EdgeInsets.all(1),
                                        child: CachedNetworkImage(
                                          imageUrl: widget.images[index],
                                          fit: BoxFit.fill,
                                          placeholder: (context, url) => CircularProgressIndicator(),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                          width: Get.width * 0.28,
                                          height: Get.width * 0.28,
                                        ),
                                      )
                                    ),
                                  );
                                },
                                itemCount: widget.isVideo ? 0 : widget.images.length)),
                        const SizedBox(height: 20),
                        Center(
                         child: AppText(
                           text: "${selectedImage + 1} / ${widget.images.length}",
                           fontSize: 13,
                         ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: !widget.isVideo,
                        child: GestureDetector(
                          onTap: (){
                            List<BtnBottomSheetModel> items = [];
                            items.add(BtnBottomSheetModel("", "download_all".tr(), 0));
                            items.add(BtnBottomSheetModel("", "download_one".tr(), 1));
                            Get.bottomSheet(enterBottomSheetDuration: Duration(milliseconds: 100), exitBottomSheetDuration: Duration(milliseconds: 100),BtnBottomSheetWidget(
                              btnItems: items,
                              onTapItem: (index){
                                if(index == 0){
                                  download(widget.images, 0);
                                }else {
                                  download([widget.images[selectedImage]], 0);
                                }
                              },
                            ));
                          },
                          child: Image.asset(ImageConstants.imgDownload, width: 32, height: 32),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          AppDialog.showConfirmDialog(context, "delete".tr(), "delete_content".tr(), () {
                            Navigator.pop(context, "delete");
                          });
                        },
                        child: Image.asset(ImageConstants.deleteIcon, width: 32, height: 32),
                      ),
                      Visibility(
                        visible: !widget.isVideo,
                        child: GestureDetector(
                          onTap: (){
                            AppDialog.showImaegInfoDialog(context, "PNG", sizeStr(), width, height);
                          },
                          child: Image.asset(ImageConstants.imgInfo, width: 32, height: 32),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        )
    );
  }
}
