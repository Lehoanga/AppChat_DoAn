import 'package:appchat/features/auth/repository/auth_repository.dart';
import 'package:appchat/features/call/controller/call_controller.dart';
import 'package:appchat/models/call.dart';
import 'package:appchat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../../config/zego_config.dart';

// ignore: must_be_immutable
class CallInvitatuinPage extends ConsumerStatefulWidget {
  static const String routeName = '/video-call-screens';
  bool isGroupChat;
  Call call;
  bool isVideoCall;
  CallInvitatuinPage({
    required this.isGroupChat,
    Key? key, 
    required String channelId, 
    required this.call, 
    required this.isVideoCall,
    }) : super(key: key);

  @override
  ConsumerState<CallInvitatuinPage> createState() => _CallInvitatuinPageState();
}

class _CallInvitatuinPageState extends ConsumerState<CallInvitatuinPage> {
  

  late Future<UserModel?> userDataFuture;

  void initState() {
    super.initState();
    // Set default name from user data
    userDataFuture = _getDefaultUserData();
  }

  Future<UserModel?> _getDefaultUserData() async {
    return ref.read(authRepositoryProvider).getCurrentUserData();
  }  
  

  void onCallEnd(BuildContext context) {
    ref.read(callControllerProvider).endCall(
      widget.call.callerId, 
      widget.call.receiverId, 
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      body: SafeArea(
        child: Center(
          child: FutureBuilder<UserModel?>(
            future: userDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Or another loading indicator
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                // Set default values after getting user data
                final currentUserData = snapshot.data;    
                return widget.isGroupChat 
                  ? ZegoUIKitPrebuiltCall(
                      appID: ZegoConfig.appId, 
                      appSign: ZegoConfig.appSign, 
                      callID: widget.call.callId, 
                      userID: currentUserData!.uid, 
                      userName: currentUserData.name,
                      config: widget.isVideoCall 
                      ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                      : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
                        ..onOnlySelfInRoom = (context) 
                        { onCallEnd(context);
                          Navigator.of(context).pop();}, 
                    )
                  : ZegoUIKitPrebuiltCall(
                      appID: ZegoConfig.appId, 
                      appSign: ZegoConfig.appSign,  
                      callID: widget.call.callId, 
                      userID: currentUserData!.uid, 
                      userName: currentUserData.name,
                      config: widget.isVideoCall 
                      ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                      : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall() 
                        ..onOnlySelfInRoom = (context) 
                        { onCallEnd(context);
                          Navigator.of(context).pop();
                          },   
                        
                    );  
              }
            },            
          ),
        ),
      ),
    );
  }
}
