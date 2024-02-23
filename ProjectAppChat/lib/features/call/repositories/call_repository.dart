import 'dart:convert';

import 'package:appchat/features/call/screens/call_invitation.dart';
import 'package:appchat/models/call.dart';
import 'package:appchat/models/group.dart' as model;
import 'package:appchat/models/user_model.dart';
import 'package:appchat/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final callRepositoryProvider = Provider(
  (ref) => CallRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class CallRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  CallRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream =>
      firestore.collection('call').doc(auth.currentUser!.uid).snapshots();

  Future<String> getUserTokenByID(String uid) async {
    var userData = await firestore.collection('user').doc(uid).get();

    if (userData.exists) {
      return UserModel.fromMap(userData.data()!).token;
    } else {
      return '';
    }
  } 
  
  void makeCall(
    Call senderCallData,
    BuildContext context,
    Call receiverCallData,
    bool isVideoCall,
  ) async {
    try {
      await firestore
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      await firestore
          .collection('call')
          .doc(senderCallData.receiverId)
          .set(receiverCallData.toMap());
      
      String token = await getUserTokenByID(senderCallData.receiverId);
      sendAndroidNotification(token, '${senderCallData.callerName} đang gọi', senderCallData.callerName);

      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallInvitatuinPage(
            channelId: senderCallData.callId,
            call: senderCallData,
            isGroupChat: false,
            isVideoCall: isVideoCall,
          ),
        ),
      );    


    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void makeGroupCall(
    Call senderCallData,
    BuildContext context,
    Call receiverCallData,
    bool isVideoCall,
  ) async {
    try {
      await firestore
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());

      var groupSnapshot = await firestore
          .collection('groups')
          .doc(senderCallData.receiverId)
          .get();
      model.Group group = model.Group.fromMap(groupSnapshot.data()!);

      for (var id in group.membersUid) {
        await firestore
            .collection('call')
            .doc(id)
            .set(receiverCallData.toMap());
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallInvitatuinPage(
            channelId: senderCallData.callId,
            call: senderCallData,
            isGroupChat: true,
            isVideoCall: isVideoCall,
          ),
        ),
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void endCall(
    String callerId,
    String receiverId,
    BuildContext context,
  ) async {
    try {
      await firestore.collection('call').doc(callerId).delete();
      await firestore.collection('call').doc(receiverId).delete();
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void endGroupCall(
    String callerId,
    String receiverId,
    BuildContext context,
  ) async {
    try {
      await firestore.collection('call').doc(callerId).delete();
      var groupSnapshot =
          await firestore.collection('groups').doc(receiverId).get();
      model.Group group = model.Group.fromMap(groupSnapshot.data()!);
      for (var id in group.membersUid) {
        await firestore.collection('call').doc(id).delete();
      }
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
          'Authorization': 'key=AAAAUdGRgjg:APA91bFLaXs40z4F-BWZIBHtEJoD1g9RLVc6KG9zQPztXwvvWRYRzQFEuHmg4yd4hoghA6Vhk7UqBia3pSfqrMYGowgNE_TxowpjPvKfxA7EZS2apl7Jm8B7ltGQRaHXNaYmiS_rH5On',
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