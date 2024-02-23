import 'package:appchat/features/call/controller/call_controller.dart';
import 'package:appchat/features/call/screens/call_invitation.dart';
import 'package:appchat/models/call.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CallPickupScreen extends ConsumerWidget {
  final Widget scaffold;
  const CallPickupScreen({
    Key? key,
    required this.scaffold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ref.watch(callControllerProvider).callStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          Call call =
              Call.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          if (!call.hasDialled) {            
            return Scaffold(
              body: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Incoming Call',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 50),
                    call.isGroupChat 
                    ? CircleAvatar(                      
                      backgroundImage: NetworkImage(call.receiverPic),
                      radius: 60,
                    )                
                    : CircleAvatar(                      
                      backgroundImage: NetworkImage(call.callerPic),
                      radius: 60,
                    ),   
                    const SizedBox(height: 50),
                    Text(
                      call.isGroupChat 
                      ? call.receiverName
                      : call.callerName,                      
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 75),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            call.isGroupChat 
                            ? ref.read(callControllerProvider).endGroupCall(
                              call.callerId, 
                              call.receiverId, 
                              context,
                            )
                            : ref.read(callControllerProvider).endCall(
                              call.callerId, 
                              call.receiverId, 
                              context,
                            );                            
                          },
                          icon: const Icon(Icons.call_end,
                              color: Colors.redAccent),
                        ),
                        const SizedBox(width: 25),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallInvitatuinPage(
                                  channelId: call.callId,
                                  call: call,
                                  isGroupChat: call.isGroupChat,
                                  isVideoCall: call.isVideoCall,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.call,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        }
        return scaffold;
      },
    );
  }
}