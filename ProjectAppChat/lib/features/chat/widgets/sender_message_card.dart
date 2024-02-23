import 'package:appchat/features/chat/widgets/display_text_image_gif.dart';
import 'package:appchat/models/user_model.dart';
import 'package:appchat/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:appchat/colors.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:dio/dio.dart';

import '../../../common/enums/message_enum.dart';

class SenderMessageCard extends StatelessWidget {
  const SenderMessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.type, 
    required this.onRightSwipe, 
    required this.repliedText, 
    required this.username, 
    required this.repliedMessageType,
    required this.nameChat, 
    required this.isGroupChat, 
    required this.ishowName,
    
  }) : super(key: key);
  final String message;
  final String date;
  final MessageEnum type;
  final VoidCallback onRightSwipe;
  final String repliedText;
  final String username;
  final MessageEnum repliedMessageType;
  final String nameChat;
  final bool isGroupChat;
  final bool ishowName;
  
  Future<String?> getUserNameByID(String uid) async {
    var userData = await FirebaseFirestore.instance.collection('user').doc(uid).get();

    if (userData.exists) {
      return UserModel.fromMap(userData.data()!).name;
    } else {
      return null;
    }
  }

  _saveNetworkImage(String url) async {
    var response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes)
    );
    
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 60,);
    print(result);
  }

   _saveNetworkVideoFile(String url) async {
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/temp.mp4";
    String fileUrl =
        url;
    await Dio().download(fileUrl, savePath, onReceiveProgress: (count, total) {
      print((count / total * 100).toStringAsFixed(0) + "%");
    });
    final result = await ImageGallerySaver.saveFile(savePath);
    print(result);
  }


  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;
    return GestureDetector(
      onLongPress: ()
       {
        type == MessageEnum.gif 
        ? {}
        :
        showBottomModal(context, message, type,);
      },
    child: FutureBuilder<String?>(
      future: getUserNameByID(nameChat),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // You can replace this with a loading indicator.
        }
      final nameShow = snapshot.data ?? 'Unknown User';
    
    return SwipeTo(
      onRightSwipe: onRightSwipe,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
            minWidth: 110,
          ),
          child: Column(
            children: [
              isGroupChat 
                ? ishowName 
                  ? 
                    const SizedBox()
                  : 
                 SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),  // Adjust the top padding as needed
                      child: Text(
                        nameShow,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
              Container(
                constraints: BoxConstraints(
                  minWidth: 100,
                ),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  color: senderMessageColor,
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                  child: Stack(
                    children: [
                      Padding(
                        padding: type == MessageEnum.text 
                        ? const EdgeInsets.only(
                            left: 10,
                            right: 30,
                            top: 5,
                            bottom: 20,
                          )
                        : const EdgeInsets.only(
                            left: 5,
                            top: 5,
                            right: 5,
                            bottom: 25,
                        ),
                        child: Column(
                          children: [
                            if (isReplying) ...[
                              Text(
                                username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: backgroundColor.withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(
                                      5,
                                    ),
                                  ),
                                ),
                                child: DisplayTextImageGIF(
                                  message: repliedText,
                                  type: repliedMessageType,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            DisplayTextImageGIF(
                              message: message,
                              type: type,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 10,
                        child: Text(
                          date,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }));
}
void showBottomModal(BuildContext context, String message, MessageEnum type) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [   
              type == MessageEnum.text 
              ?  
              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: message));
                  showSnackBar(context: context, content: 'Copied successfully');
                  Navigator.pop(context); 
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [                    
                    Text('Copy'),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey,
                      child: IconButton(
                        icon: Icon(
                          Icons.copy,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ) 
              : type == MessageEnum.video 
              ? 
              InkWell(
                onTap: () {
                 _saveNetworkVideoFile(message);
                 Navigator.pop(context);
                 showSnackBar(context: context, content: 'Complete download');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [                    
                    Text('Download video'),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey,
                      child: IconButton(
                        icon: Icon(
                          Icons.download,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              )
              : type == MessageEnum.image ?
              InkWell(
                onTap: () {
                 _saveNetworkImage(message);
                 Navigator.pop(context);
                 showSnackBar(context: context, content: 'Complete download');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [                    
                    Text('Download image'),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey,
                      child: IconButton(
                        icon: Icon(
                          Icons.download,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              )
              : SizedBox(),        
            ],
          ),
        );
      },
    );
  }
}
