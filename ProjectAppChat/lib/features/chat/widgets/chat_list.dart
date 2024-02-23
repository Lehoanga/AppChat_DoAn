import 'package:appchat/common/enums/message_enum.dart';
import 'package:appchat/common/providers/message_reply_provider.dart';
import 'package:appchat/common/widgets/loader.dart';
import 'package:appchat/features/chat/controller/chat_controller.dart';
import 'package:appchat/features/chat/widgets/sender_message_card.dart';
import 'package:appchat/models/message.dart';
import 'package:appchat/utils/my_date_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'my_message_card.dart';

class ChatList extends ConsumerStatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;
  const ChatList({
    Key? key,
    required this.recieverUserId,
    required this.isGroupChat,
    }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  void onMessageSwipe(
    String message,
    bool isMe,
    MessageEnum messageEnum,
  ) {
    // ignore: deprecated_member_use
    ref.read(messageReplyProvider.state).update(
          (state) => MessageReply(
            message,
            isMe,
            messageEnum,
          ),
    );
  }  

   String formatString(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    int timestamp = dateTime.millisecondsSinceEpoch;
    print(timestamp);

    return timestamp.toString();
  }

 @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: widget.isGroupChat  
        ? ref.read(chatControllerProvider).groupChatStream(widget.recieverUserId)
        : ref.read(chatControllerProvider).chatStream(widget.recieverUserId),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Loader();
        }

        SchedulerBinding.instance.addPostFrameCallback((_) {
          messageController.jumpTo(messageController.position.maxScrollExtent);
        });

        return ListView.builder(
          controller: messageController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final messageData = snapshot.data![index];
            var timeSent = MyDateUtil.getLastMessageTime(context: context, time: formatString(messageData.timeSent.toString()));
            
            
            if(!messageData.isSeen 
              && messageData.recieverid == FirebaseAuth.instance.currentUser!.uid){
              ref
                .read(chatControllerProvider)
                .setChatMessageSeen(
                  context, 
                  widget.recieverUserId, 
                  messageData.messageId
                );
            }
            if (messageData.senderId == FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(
                message: messageData.text,
                date: timeSent,
                type: messageData.type,
                repliedText: messageData.repliedMessage,
                username: messageData.repliedTo,
                repliedMessageType: messageData.repliedMessageType,
                onLeftSwipe: () => onMessageSwipe(
                    messageData.text,
                    true,
                    messageData.type,
                  ),
                isSeen: messageData.isSeen,
              );
            }
            return SenderMessageCard(
              message: messageData.text,
              date: timeSent,
              type: messageData.type,
              username: messageData.repliedTo,
              repliedText: messageData.repliedMessage,
              repliedMessageType: messageData.repliedMessageType,
              nameChat: messageData.senderId,
              ishowName: (index > 0 && messageData.senderId == snapshot.data![index - 1].senderId)
                ? true
                : false,
              isGroupChat: widget.isGroupChat,
              onRightSwipe: () => onMessageSwipe(
                  messageData.text,
                  false,
                  messageData.type,
              ),
            );
          },
        );
      }
    );
  }
}
