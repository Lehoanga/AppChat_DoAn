import 'dart:io';

import 'package:appchat/common/enums/message_enum.dart';
import 'package:appchat/common/providers/message_reply_provider.dart';
import 'package:appchat/models/chat_contact.dart';
import 'package:appchat/models/group.dart';
import 'package:appchat/models/message.dart';
import 'package:appchat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controller/auth_controller.dart';
import '../repositories/chat_repository.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(
    chatRepository: chatRepository,
    ref: ref,
  );
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;
  ChatController({
    required this.chatRepository,
    required this.ref,
  });

  Stream<List<ChatContact>> getChatContactsList(String search){
    return chatRepository.getChatContactsList(search);
  }
  Stream<List<UserModel>> getContactsList(String search){
    return chatRepository.getContactsList(search);
  }

  Stream<List<ChatContact>> chatContact(String search){
    return chatRepository.getChatContacts(search);
  }

  Stream<List<Group>> chatGroups(String search) {
    return chatRepository.getChatGroups(search);
  }

  Stream<List<Message>> chatStream(String recieverUserId){
    return chatRepository.getChatStream(recieverUserId);
  }

  Stream<List<Message>> groupChatStream(String groupId) {
    return chatRepository.getGroupChatStream(groupId);
  }

  void sendTextMessage(
    BuildContext context,
    String text,
    String recieverUserId,
    bool isGroupChat,
  ) {    
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
      (value) => chatRepository.sendTextMessage(
        context: context,
        text: text,
        recieverUserId: recieverUserId,
        senderUser: value!,        
        messageReply: messageReply,
        isGroupChat: isGroupChat,
      ),
    ); 
    ref.read(messageReplyProvider.state).update((state) => null);  
  }

  void sendfileMessage(
    BuildContext context,
    File file,
    String recieverUserId,
    MessageEnum messageEnum,
    bool isGroupChat,
  ) {    
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
      (value) => chatRepository.sendFileMessage(
        context: context,
        file: file,
        recieverUserId: recieverUserId,
        senderUserData: value!,
        messageEnum: messageEnum,
        ref: ref,
        messageReply: messageReply,      
        isGroupChat: isGroupChat, 
      ),
    );   
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void sendGIFMessage(
    BuildContext context, 
    String gifUrl, 
    String recieverUserId,
    bool isGroupChat,
  ){

    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    String newgifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
      (value) => chatRepository.sendGIFMessage(
        context: context, 
        gifUrl: newgifUrl, 
        recieverUserId: recieverUserId, 
        senderUser: value!,
        messageReply: messageReply,
        isGroupChat: isGroupChat,
      )
    );
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ){
    chatRepository.setChatMessageSeen(context, recieverUserId, messageId);
  }

}