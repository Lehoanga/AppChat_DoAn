import 'dart:convert';
import 'dart:io';

import 'package:appchat/common/enums/message_enum.dart';
import 'package:appchat/common/providers/message_reply_provider.dart';
import 'package:appchat/common/repositories/common_firebase_storage_repository.dart';
import 'package:appchat/config/cloud_messaging.dart';
import 'package:appchat/models/chat_contact.dart';
import 'package:appchat/models/group.dart';
import 'package:appchat/models/message.dart';
import 'package:appchat/models/user_model.dart';
import 'package:appchat/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<List<ChatContact>> getChatContactsList(String search) {
  return firestore
      .collection('user')
      .doc(auth.currentUser!.uid)
      .collection('chats')
      .snapshots()
      .asyncMap((event) async {
        List<ChatContact> contacts = [];

        for (var document in event.docs) {
          var chatContact = ChatContact.fromMap(document.data());
          var userData = await firestore
              .collection('user')
              .doc(chatContact.contactId)
              .get();
          var user = UserModel.fromMap(userData.data()!);

          if (search != '') {
            if (user.name.toLowerCase() == search.toLowerCase() ||
                user.phoneNumber == search ||
                user.gmail == search) {
              contacts.add(
                ChatContact(
                  name: user.name,
                  profilePic: user.profilePic,
                  contactId: chatContact.contactId,
                  timeSent: chatContact.timeSent,
                  lastMessage: chatContact.lastMessage,
                  isGroupChat: false,
                ),
              );
            }
          } else {
            contacts.add(
              ChatContact(
                name: user.name,
                profilePic: user.profilePic,
                contactId: chatContact.contactId,
                timeSent: chatContact.timeSent,
                lastMessage: chatContact.lastMessage,
                isGroupChat: false,
              ),
            );
          }
        }

        // Fetch groups
        var groupSnapshot = await firestore.collection('groups').get();
        List<ChatContact> contactsGroup = [];

        for (var document in groupSnapshot.docs) {
          var group = Group.fromMap(document.data());
          
          if (group.membersUid.contains(auth.currentUser!.uid)) {
            if (search != '') {
              if (group.name.toLowerCase() == search.toLowerCase()) {
                contactsGroup.add(
                  ChatContact(
                    name: group.name,
                    profilePic: group.groupPic,
                    contactId: group.groupId,
                    timeSent: group.timeSent,
                    lastMessage: group.lastMessage,
                    isGroupChat: true,
                  ),
                );
              }
            } else {
              contactsGroup.add(
                ChatContact(
                  name: group.name,
                  profilePic: group.groupPic,
                  contactId: group.groupId,
                  timeSent: group.timeSent,
                  lastMessage: group.lastMessage,
                  isGroupChat: true,
                ),
              );
            }
          }
        }

        // Combine individual and group contacts
        contacts.addAll(contactsGroup);
        contacts.sort((a, b) => b.timeSent.compareTo(a.timeSent));
        return contacts;
      });
  }

  Stream<List<ChatContact>> getChatContacts(String search) {
    return firestore
        .collection('user')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await firestore
            .collection('user')
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromMap(userData.data()!);
        if(search!=''){
          if(user.name.toLowerCase() == search.toLowerCase() || user.phoneNumber == search || user.gmail == search){
            contacts.add(
            ChatContact(
              name: user.name,
              profilePic: user.profilePic,
              contactId: chatContact.contactId,
              timeSent: chatContact.timeSent,
              lastMessage: chatContact.lastMessage,
              isGroupChat: false,
              ),
            );  
          }
        } else{
          contacts.add(
          ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
            isGroupChat: false,
          ),
        );  
        }
        
      }
      return contacts;
    });    
  }

  Stream<List<UserModel>> getContactsList(String search) {
  return firestore
      .collection('user')
      .snapshots()
      .asyncMap((event) async {
        List<UserModel> listUser = [];

        for (var document in event.docs) {
          var contact = UserModel.fromMap(document.data());          
          if (search != '') {
            if (contact.name.toLowerCase().contains(search.toLowerCase()) ||
                contact.phoneNumber.contains(search) ||
                contact.gmail.toLowerCase().contains(search.toLowerCase())) {
              listUser.add(
                UserModel(
                  uid: contact.uid,
                  name: contact.name,
                  profilePic: contact.profilePic, 
                  isOnline: contact.isOnline, 
                  phoneNumber: contact.phoneNumber, 
                  gmail: contact.gmail, 
                  groupId: contact.groupId, 
                  token: contact.token,                  
                ),
              );
            }
          } 
        }
        return listUser;
      });
  }

  Stream<List<Group>> getChatGroups(String search) {
    return firestore.collection('groups').snapshots().map((event) {
      List<Group> groups = [];
      for (var document in event.docs) {
        var group = Group.fromMap(document.data());        
        if (group.membersUid.contains(auth.currentUser!.uid)) {
          if(search!=''){
            if(group.name.toLowerCase() == search.toLowerCase()){
              groups.add(group);
            }
          }else{
            groups.add(group);
          }
        }
      }
      return groups;
    });
  }

  Stream<List<Message>> getChatStream(String recieverUserId) {
    return firestore
        .collection('user')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  Stream<List<Message>> getGroupChatStream(String groudId) {
    return firestore
        .collection('groups')
        .doc(groudId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  void _saveDataToContactsSubcollection(
    UserModel senderUserData,
    UserModel? recieverUserData,
    String text,
    DateTime timeSent,
    String recieverUserId,
    bool isGroupChat,
  ) async {
    if (isGroupChat) {
      await firestore.collection('groups').doc(recieverUserId).update({
        'lastMessage': text,
        'timeSent': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
// users -> reciever user id => chats -> current user id -> set data
      var recieverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
        isGroupChat: isGroupChat,
      );
      await firestore
          .collection('user')
          .doc(recieverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .set(
            recieverChatContact.toMap(),
          );
      // users -> current user id  => chats -> reciever user id -> set data
      var senderChatContact = ChatContact(
        name: recieverUserData!.name,
        profilePic: recieverUserData.profilePic,
        contactId: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
        isGroupChat: isGroupChat,
      );
      await firestore
          .collection('user')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .set(
            senderChatContact.toMap(),
          );
    }
  }

  void _saveMessageToMessageSubcollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUsername,
    required String? recieverUserName,
    required bool isGroupChat,
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      recieverid: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUsername
              : recieverUserName ?? '',
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
    );
    if (isGroupChat) {
      // groups -> group id -> chat -> message
      await firestore
          .collection('groups')
          .doc(recieverUserId)
          .collection('chats')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    } else {
      // users -> sender id -> reciever id -> messages -> message id -> store message
      await firestore
          .collection('user')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );
      // users -> reciever id  -> sender id -> messages -> message id -> store message
      await firestore
          .collection('user')
          .doc(recieverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    }
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('user').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUser,
        recieverUserData,
        text,
        timeSent,
        recieverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageType: MessageEnum.text,
        messageId: messageId,
        username: senderUser.name,
        messageReply: messageReply,
        recieverUserName: recieverUserData?.name,
        senderUsername: senderUser.name,
        isGroupChat: isGroupChat,
      );

      sendAndroidNotification(recieverUserData!.token, text, senderUser.name);
    } catch (e) {
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String recieverUserId,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
            file,
          );

      UserModel? recieverUserData;
      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('user').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
        default:
          contactMsg = 'GIF';
      }
      _saveDataToContactsSubcollection(
        senderUserData,
        recieverUserData,
        contactMsg,
        timeSent,
        recieverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.name,
        messageType: messageEnum,
        messageReply: messageReply,
        recieverUserName: recieverUserData?.name,
        senderUsername: senderUserData.name,
        isGroupChat: isGroupChat,
      );

      sendAndroidNotification(recieverUserData!.token, 'Đã gửi $contactMsg', senderUserData.name);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendGIFMessage({
    required BuildContext context,
    required String gifUrl,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('user').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUser,
        recieverUserData,
        'GIF',
        timeSent,
        recieverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: gifUrl,
        timeSent: timeSent,
        messageType: MessageEnum.gif,
        messageId: messageId,
        username: senderUser.name,
        messageReply: messageReply,
        recieverUserName: recieverUserData?.name,
        senderUsername: senderUser.name,
        isGroupChat: isGroupChat,
      );
       sendAndroidNotification(recieverUserData!.token, "Đã gửi GIF", senderUser.name);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) async {
    try {
      await firestore
          .collection('user')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await firestore
          .collection('user')
          .doc(recieverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<void> sendAndroidNotification(String token, String message, String name) async {
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': CloudMessConfig.Authorization,
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': message,
              'title': name,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': token,
          },
        ),
      );
      response;
    } catch (e) {
      e;
    }
  }
}