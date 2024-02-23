import 'package:appchat/features/chat/screens/mobile_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_model.dart';
import '../../../utils/utils.dart';

final selectContactsRepositoryProvider = Provider(
  (ref) => SelectContactRepository(
    firestore: FirebaseFirestore.instance,
  ),
);

class SelectContactRepository {
  final FirebaseFirestore firestore;

  SelectContactRepository({
    required this.firestore,
  });

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    List<String> phone = [];
    List<Contact> contactsList = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }

      var userCollection = await firestore.collection('user').get();
      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        if(userData.phoneNumber != 'null'){
          phone.add(userData.phoneNumber);
        }       
      }

      for (var docs in contacts){
      String phoneNumber = docs.phones[0].number.replaceAll(
          ' ',
          '',
        );
      if(phone.contains(phoneNumber)){
        contactsList.add(docs);
      }
    }
    } catch (e) {
      debugPrint(e.toString());
    }    
    return contactsList;
  }

  void selectContact(Contact selectedContact, BuildContext context) async {
    try {
      var userCollection = await firestore.collection('user').get();
      bool isFound = false;

      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNum = selectedContact.phones[0].number.replaceAll(
          ' ',
          '',
        );
        if (selectedPhoneNum == userData.phoneNumber) {
          isFound = true;
          // ignore: use_build_context_synchronously
          Navigator.pushNamed(
            context,
            MobileChatScreen.routeName,
            arguments: {
              'name': userData.name,
              'uid': userData.uid,
              'isGroupChat': false,
              'profilePic': userData.profilePic,
              'senderId' : '',
            },
          );
        }
      }

      if (!isFound) { 
        // ignore: use_build_context_synchronously
        showSnackBar(
          context: context,
          content: 'This number does not exist on this app.',
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context: context, content: e.toString());
    }
  }
}