import 'dart:io';

import 'package:appchat/common/repositories/common_firebase_storage_repository.dart';
import 'package:appchat/models/user_model.dart';
import 'package:appchat/screens/mobile_layout_screen.dart';
import 'package:appchat/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/group.dart' as model;

final groupRepositoryProvider = Provider(
  (ref) => GroupRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
  ),
);

class GroupRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;
  GroupRepository({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  Future<model.Group?> getCurrentGroupData(String groupId) async {
    var groupData =
        await firestore.collection('groups').doc(groupId).get();
    model.Group? group;
    if (groupData.data() != null) {
      group = model.Group.fromMap(groupData.data()!);
    }
    return group; 
  }

  void createGroup(BuildContext context, String name, File profilePic,
      List<Contact> selectedContact) async {
    try {
      List<String> uids = [];
      for (int i = 0; i < selectedContact.length; i++) {
        var userCollection = await firestore
            .collection('user')
            .where(
              'phoneNumber',
              isEqualTo: selectedContact[i].phones[0].number.replaceAll(
                    ' ',
                    '',
                  ),
            )
            .get();

        if (userCollection.docs.isNotEmpty && userCollection.docs[0].exists) {
          uids.add(userCollection.docs[0].data()['uid']);
        }
      }
      var groupId = const Uuid().v1();

      String profileUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'group/$groupId',
            profilePic,
          );   
      model.Group group = model.Group(
        senderId: auth.currentUser!.uid,
        name: name,
        groupId: groupId,
        lastMessage: '',
        groupPic: profileUrl,
        membersUid: [auth.currentUser!.uid, ...uids],
        timeSent: DateTime.now(),
      );

      await firestore.collection('groups').doc(groupId).set(group.toMap());
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context: context, content: e.toString());
    }
  }

  void updateGroup(
    BuildContext context, 
    String groupId, 
    String name, 
    File? profilePic,
    List<Contact> selectedContact) async {
  try {
    List<String> uids = [];
    for (int i = 0; i < selectedContact.length; i++) {
      var userCollection = await firestore
          .collection('user')
          .where(
            'phoneNumber',
            isEqualTo: selectedContact[i].phones[0].number.replaceAll(
              ' ',
              '',
            ),
          )
          .get();

      if (userCollection.docs.isNotEmpty && userCollection.docs[0].exists) {
        uids.add(userCollection.docs[0].data()['uid']);
      }
    }

    final model.Group? groupData = await getCurrentGroupData(groupId);
    String profileUrl = 'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png'; // Giá trị mặc định là chuỗi trống

    // Nếu có ảnh mới được chọn, hãy cập nhật profileUrl và lưu trữ ảnh mới
    if (profilePic != null) {
      profileUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'group/$groupId',
            profilePic,
          );
    } else {      
      profileUrl = groupData!.groupPic;
    }

    List<String> membersUid = [auth.currentUser!.uid, ...uids] + groupData!.membersUid;
    

    model.Group group = model.Group(
      senderId: auth.currentUser!.uid,
      name: name,
      groupId: groupId,
      lastMessage: groupData.lastMessage,
      groupPic: profileUrl,
      membersUid: membersUid.toSet().toList(),
      timeSent: DateTime.now(),
    );

    await firestore.collection('groups').doc(groupId).update(group.toMap());
  } catch (e) {
    // ignore: use_build_context_synchronously
    showSnackBar(context: context, content: e.toString());
  }
}

  void addUserGroup(
    BuildContext context, 
    String groupId, 
    String name, 
    File? profilePic,
    List<UserModel> user) async {
  try {
    List<String> uids = [];
    for (int i = 0; i < user.length; i++) {
      uids.add(user[i].uid);
    }
    
    final model.Group? groupData = await getCurrentGroupData(groupId);
    String profileUrl = 'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png'; // Giá trị mặc định là chuỗi trống
    if (profilePic != null) {
      profileUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'group/$groupId',
            profilePic,
          );
    } else {      
      profileUrl = groupData!.groupPic;
    }

    List<String> membersUid = [auth.currentUser!.uid, ...uids] + groupData!.membersUid;
    

    model.Group group = model.Group(
      senderId: auth.currentUser!.uid,
      name: name,
      groupId: groupId,
      lastMessage: groupData.lastMessage,
      groupPic: profileUrl,
      membersUid: membersUid.toSet().toList(),
      timeSent: groupData.timeSent,
    );

    await firestore.collection('groups').doc(groupId).update(group.toMap());
  } catch (e) {
    // ignore: use_build_context_synchronously
    showSnackBar(context: context, content: e.toString());
  }
}

  void leaveGroup(
    BuildContext context,
    String groupId,
  ) async {
    try{

      final model.Group? groupData = await getCurrentGroupData(groupId);
      var listMem = groupData!.membersUid;
      if(listMem.isNotEmpty){
        for(int i = 0; i < listMem.length; i++){
          if(listMem[i] == auth.currentUser!.uid){
            listMem.removeAt(i);
          }
        }
      }

      model.Group group = model.Group(
      senderId: auth.currentUser!.uid,
      name: groupData.name,
      groupId: groupId,
      lastMessage: groupData.lastMessage,
      groupPic: groupData.groupPic,
      membersUid: listMem,
      timeSent: DateTime.now(),
    );  
      await firestore.collection('groups').doc(groupId).update(group.toMap());
    
      Navigator.pushAndRemoveUntil(
        context, 
         MaterialPageRoute(
          builder: (context) => const MobileLayoutScreen(),
        ), 
        (route) => false);
    } catch(e) {
       showSnackBar(context: context, content: e.toString());
    }
  }

  void deleteGroup(
    BuildContext context,
    String groupId,
  ) async {
    try{
      await firestore.collection('groups').doc(groupId).delete();
      await ref
      .read(commonFirebaseStorageRepositoryProvider)
      .deleteFileFromFirebase('group/$groupId');
      
      Navigator.pushAndRemoveUntil(
        context, 
         MaterialPageRoute(
          builder: (context) => const MobileLayoutScreen(),
        ), 
        (route) => false);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

}