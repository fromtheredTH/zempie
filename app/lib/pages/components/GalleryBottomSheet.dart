

import 'dart:io';

import 'package:app/Constants/ImageConstants.dart';
import 'package:app/pages/components/app_button.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart' hide Trans;
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';

import '../../Constants/ColorConstants.dart';

class GalleryBottomSheet extends StatefulWidget {
  ScrollController? controller;
  Function(List<Medium>) onTapSend;
  GalleryBottomSheet({Key? key, this.controller, required this.onTapSend}) : super(key: key);

  @override
  State<GalleryBottomSheet> createState() => _GalleryBottomSheet();
}

class _GalleryBottomSheet extends State<GalleryBottomSheet> {
  List<Medium> _media = [];
  late Album album;

  late Future albumFuture;

  final gridController = DragSelectGridViewController();
  final Set<int> selectedIndexes = Set<int>();
  final key = GlobalKey();
  int? startTarget;
  bool isStart = false;
  final Set<int> _trackTaped = Set<int>();

  _detectTapedItem(PointerEvent event) {
    if(!isStart || getSelectedCount() >= 10)
      return;
    final RenderBox box = key.currentContext!.findRenderObject()! as RenderBox;
    final result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        /// temporary variable so that the [is] allows access of [index]
        final target = hit.target;
        print(target);
        if (target is _MediaItem) {
          if(_trackTaped.isNotEmpty && _trackTaped.first != target.index! && _trackTaped.last != target.index!)
          if(startTarget == null){
            startTarget = target.index!;
          }
          _trackTaped.clear();
          if(startTarget! < target.index!) {
            for(int i=startTarget!;i<=target.index!;i++){
              if(!selectedIndexes.contains(i)){
                if(getSelectedCount() < 10){
                  _trackTaped.add(i);
                }else{
                  break;
                }
              }
            }
          }else if(startTarget! > target.index!){
            for(int i=target.index!;i<=startTarget!;i++){
              if(!selectedIndexes.contains(i)){
                if(getSelectedCount() < 10){
                  _trackTaped.add(i);
                }else{
                  break;
                }
              }
            }
          }else{
            _trackTaped.add(target.index!);
          }
          _selectIndex();
        }
      }
    }
  }

  _selectIndex() {
    setState(() {

    });
  }

  int getSelectedCount(){
    Set<int> tempSet = Set<int>();
    tempSet.addAll(selectedIndexes);
    tempSet.addAll(_trackTaped);
    return tempSet.length;
  }

  void _clearSelection(PointerUpEvent event) {
    selectedIndexes.addAll(_trackTaped);
    _trackTaped.clear();
    setState(() {
      isStart = false;
      startTarget = null;
    });
  }

  @override
  void initState() {
    albumFuture = initAsync();
    super.initState();
    gridController.addListener(scheduleRebuild);
  }

  @override
  void dispose() {
    gridController.removeListener(scheduleRebuild);
    super.dispose();
  }

  void scheduleRebuild() => setState(() {});

  Future<List<Medium>> initAsync() async {
    List<Album> albums = await PhotoGallery.listAlbums();
    int maxAlbumCnt = 0;
    int maxAlbumindex = 0;
    for(int i=0;i<albums.length;i++){
      if(albums[i].count > maxAlbumCnt){
        maxAlbumindex = i;
        maxAlbumCnt = albums[i].count;
      }
    }
    album = albums[maxAlbumindex];
    MediaPage mediaPage = await album.listMedia();
    _media.addAll(mediaPage.items);
    return _media;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: ColorConstants.colorSub,
          borderRadius: BorderRadius.only(topRight: Radius.circular(24), topLeft: Radius.circular(24))
      ),
      child: Column(
        children: [
          SizedBox(height: 15,),
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                  color: Color(0xffd9d9d9),
                  borderRadius: BorderRadius.circular(4)
              ),
            ),
          ),
          SizedBox(height: 15),

          Expanded(
              child: FutureBuilder(
                future: albumFuture,
                builder: (context, snapshot){
                  if(snapshot.hasData) {
                    return Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Listener(
                        onPointerDown: _detectTapedItem,
                        onPointerMove: _detectTapedItem,
                        onPointerUp: _clearSelection,
                        child: GridView.builder(
                            controller: widget.controller,
                            key: key,
                            physics: isStart ? NeverScrollableScrollPhysics() : null,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.0,
                              crossAxisSpacing: 5.0,
                              mainAxisSpacing: 5.0,
                            ),
                            itemCount: _media.length,
                            itemBuilder: (context, index) {
                              return MediaItem(
                                  index: index,
                                child: GestureDetector(
                                  onTap: () {
                                    if(selectedIndexes.contains(index)){
                                      selectedIndexes.remove(index);
                                    }else{
                                      if(selectedIndexes.length < 10){
                                        selectedIndexes.add(index);
                                      }
                                    }
                                  },
                                  onLongPressStart: (details){
                                    setState(() {
                                      isStart = true;
                                      startTarget = index;
                                    });
                                  },
                                  child: Container(
                                      color: ColorConstants.gray3,
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Container(
                                              width: double.maxFinite,
                                              height: double.maxFinite,
                                              child: FadeInImage(
                                                fit: BoxFit.cover,
                                                placeholder: MemoryImage(kTransparentImage),
                                                image: ThumbnailProvider(
                                                  mediumId: _media[index].id,
                                                  mediumType:_media[index].mediumType,
                                                  highQuality: true,
                                                ),
                                              ),
                                            )
                                          ),

                                          Positioned(
                                              top: 5,
                                              left: 5,
                                              child: InkWell(
                                                onTap: (){
                                                  if(selectedIndexes.contains(index)){
                                                    selectedIndexes.remove(index);
                                                  }else{
                                                    if(selectedIndexes.length < 10){
                                                      selectedIndexes.add(index);
                                                    }
                                                  }
                                                },
                                                child: Image.asset( selectedIndexes.contains(index) || _trackTaped.contains(index) ? ImageConstants.imageChecked : ImageConstants.imageUnChecked, width: 32, height: 32,),
                                              )
                                          )
                                        ],
                                      )
                                  ),
                                ),
                              );
                            }
                        ),
                      )
                    );
                  }

                  return  Center(
                    child: SizedBox(
                      child: Center(
                          child: CircularProgressIndicator(
                              color: ColorConstants.colorMain)
                      ),
                      height: 10.0,
                      width: 10.0,
                    ),
                  );
                },
              )
          ),

          SizedBox(height: 15,),

          if(getSelectedCount() != 0)
          AppButton(
              text: "send_image".tr(args: ["${getSelectedCount()}"]),
              disabled: getSelectedCount() == 0,
              onTap: (){
                List<Medium> results = [];
                for(int i=0;i<selectedIndexes.length;i++){
                  results.add(_media[selectedIndexes.elementAt(i)]);
                }
                widget.onTapSend(results);
                Get.back();
              }
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 15),
        ],
      )
    );
  }
}

class MediaItem extends SingleChildRenderObjectWidget {
  final int index;

  MediaItem({Widget? child, required this.index, Key? key}) : super(child: child, key: key);

  @override
  _MediaItem createRenderObject(BuildContext context) {
    return _MediaItem()..index = index;
  }

  @override
  void updateRenderObject(BuildContext context, _MediaItem renderObject) {
    renderObject..index = index;
  }
}

class _MediaItem extends RenderProxyBox {
  int? index;
}

class ViewerPage extends StatelessWidget {
  final Medium medium;

  ViewerPage(Medium medium) : medium = medium;

  @override
  Widget build(BuildContext context) {
    DateTime? date = medium.creationDate ?? medium.modifiedDate;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: date != null ? Text(date.toLocal().toString()) : null,
        ),
        body: Container(
          alignment: Alignment.center,
          child: medium.mediumType == MediumType.image
              ? GestureDetector(
            onTap: () async {
              PhotoGallery.deleteMedium(mediumId: medium.id);
            },
            child: FadeInImage(
              fit: BoxFit.cover,
              placeholder: MemoryImage(kTransparentImage),
              image: PhotoProvider(mediumId: medium.id),
            ),
          )
              : VideoProvider(
            mediumId: medium.id,
          ),
        ),
      ),
    );
  }
}

class VideoProvider extends StatefulWidget {
  final String mediumId;

  const VideoProvider({
    required this.mediumId,
  });

  @override
  _VideoProviderState createState() => _VideoProviderState();
}

class _VideoProviderState extends State<VideoProvider> {
  VideoPlayerController? _controller;
  File? _file;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAsync();
    });
    super.initState();
  }

  Future<void> initAsync() async {
    try {
      _file = await PhotoGallery.getFile(mediumId: widget.mediumId);
      _controller = VideoPlayerController.file(_file!);
      _controller?.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    } catch (e) {
      print("Failed : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller == null || !_controller!.value.isInitialized
        ? Container()
        : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
            });
          },
          child: Icon(
            _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ],
    );
  }
}
