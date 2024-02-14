import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:app/global/app_colors.dart';
import 'package:app/helpers/common_util.dart';
import 'package:app/pages/base/base_state.dart';
import 'package:app/pages/base/page_layout.dart';
import 'package:app/pages/components/dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ImageViewer extends StatefulWidget {
  final List<String> images;
  final int selected;
  final bool isVideo;
  final String title;

  ImageViewer(
      {super.key, required this.images, this.selected = 0, required this.isVideo, required this.title});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
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
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '';
  }

  void onInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      backgroundColor: appColorGrey2,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context2, setState) {
          return Wrap(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Container(
                        width: 120,
                        margin: const EdgeInsets.only(left: 30),
                        child: Text(
                          'kind'.tr(),
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      const Text(
                        'PNG',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 120,
                        margin: const EdgeInsets.only(left: 30),
                        child: Text(
                          'size'.tr(),
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      Text(
                        sizeStr(),
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                      )
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 120,
                        margin: const EdgeInsets.only(left: 30),
                        child: Text(
                          'dimension'.tr(),
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      Text(
                        '$width X $height',
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ],
          );
        });
      },
    );
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

  void onDownload() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context2, setState) {
          return Wrap(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 70,
                      height: 6,
                      decoration: BoxDecoration(color: appColorGrey2, borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: 27),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      download(widget.images, 0);
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Center(
                        child: Text(
                          'download_all'.tr(),
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      download([widget.images[selectedImage]], 0);
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Center(
                        child: Text(
                          'download_one'.tr(),
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
        onBack: onBackPressed,
        isLoading: false,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Column(
            children: [
              SizedBox(
                height: 64,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onBackPressed,
                      child: Container(
                          width: 44,
                          height: 64,
                          margin: const EdgeInsets.only(left: 10),
                          child: Center(
                            child: Image.asset("assets/image/ic_back_w.png", width: 11, height: 19),
                          )),
                    ),
                    Text(
                      widget.title,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
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
                          height: 60,
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
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.images[index],
                                      fit: BoxFit.fill,
                                      placeholder: (context, url) => CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                );
                              },
                              itemCount: widget.isVideo ? 0 : widget.images.length)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${widget.images.length}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            '장 중 ',
                            style: TextStyle(color: Colors.white, fontSize: 8),
                          ),
                          Text(
                            '${selectedImage + 1}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            '번',
                            style: TextStyle(color: Colors.white, fontSize: 8),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: !widget.isVideo,
                      child: GestureDetector(
                        onTap: onDownload,
                        child: Image.asset('assets/image/ic_download.png', width: 40, height: 40),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        AppDialog.showConfirmDialog(context, "", "delete_content".tr(), () {
                          Navigator.pop(context, "delete");
                        });
                      },
                      child: Image.asset('assets/image/ic_delete.png', width: 40, height: 40),
                    ),
                    Visibility(
                      visible: !widget.isVideo,
                      child: GestureDetector(
                        onTap: onInfo,
                        child: Image.asset('assets/image/ic_info.png', width: 40, height: 40),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
