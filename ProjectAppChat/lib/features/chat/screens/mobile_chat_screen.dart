import 'package:appchat/common/widgets/loader.dart';
import 'package:appchat/features/auth/controller/auth_controller.dart';
import 'package:appchat/features/call/controller/call_controller.dart';
import 'package:appchat/features/call/screens/call_pickup_screen.dart';
import 'package:appchat/features/chat/widgets/setting_group_chat.dart';
import 'package:appchat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:appchat/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/bottom_chat_field.dart';
import '../widgets/chat_list.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  final bool isGroupChat;
  final String profilePic;
  final String senderId;
  const MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.isGroupChat,
    required this.profilePic,
    required this.senderId,
    }) : super(key: key);  

  void makeCall(WidgetRef ref, BuildContext context, bool isVideoCall) {
    ref.read(callControllerProvider).makeCall(
      context, 
      name, 
      uid, 
      profilePic, 
      isGroupChat,
      isVideoCall,
    );
  } 

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallPickupScreen(
      scaffold: Scaffold(
          appBar: AppBar(
            backgroundColor: appBarColor,
            title: isGroupChat 
              ? Text(name)
              : StreamBuilder<UserModel>(
                  stream: ref.read(authControllerProvider).userDataById(uid),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Loader();
                    }
                    return Column(
                        children: [
                          Text(name,),
                          Text(
                            snapshot.data!.isOnline ? 'online': 'offline',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                            ),
                        ],
                      );
                  }
                ),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () => makeCall(ref, context, true),
                icon: const Icon(Icons.video_call),
              ),
              IconButton(
                onPressed: () => makeCall(ref, context, false),
                icon: const Icon(Icons.call),
              ),
              isGroupChat
              ? IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context, 
                      SettingGroupChat.routeName,
                      arguments: {
                        'isGroupChat': isGroupChat,
                        'uid': uid,
                        'name' : name,
                        'profilePic' : profilePic,
                        'senderId' : senderId,
                      },
                    );
                  },
                  icon: const Icon(Icons.settings),
                )
              : PopupMenuButton(itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text(
                  'Block!'
                ),
                onTap: (){},         
              ),              
            ])
            ],
          ),
          body: Column(
            children: [              
              Expanded(
                child: ChatList(
                  recieverUserId: uid,
                  isGroupChat : isGroupChat,
                ),
              ),
              BottomChatField(
                recieverUserId: uid,
                isGroupChat : isGroupChat,
              ),
            ],
          ),
        ),
    ); 
  }
}



