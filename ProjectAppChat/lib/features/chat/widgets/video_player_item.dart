import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late CachedVideoPlayerController videoPlayerController;
  bool isPlay = false;

  @override
  void initState() {
    super.initState();
    videoPlayerController = 
      CachedVideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value){
        videoPlayerController.setVolume(1);
      });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          CachedVideoPlayer(videoPlayerController),
          Align(
            alignment: Alignment.center,
            child: IconButton(
              onPressed: (){
                if(isPlay){
                  videoPlayerController.pause();
                } else {
                  videoPlayerController.play();
                }

                setState(() {
                  isPlay = !isPlay;
                });
              }, 
              icon: Icon(
                isPlay ? Icons.pause_circle : Icons.play_circle, 
                color: isPlay ? Colors.white.withOpacity(0.4) : Colors.white,
              ),
            ),
          ),
           Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              onPressed: () {
                videoPlayerController.seekTo(Duration.zero);
                videoPlayerController.play();
                setState(() {
                  isPlay = true;
                });
              },
              icon: Icon(
                Icons.replay,
                size: 18,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}