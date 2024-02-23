import 'package:appchat/common/widgets/loader.dart';
import 'package:appchat/features/chat/controller/chat_controller.dart';
import 'package:appchat/models/chat_contact.dart';
import 'package:appchat/utils/my_date_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:appchat/colors.dart';
import 'package:appchat/features/chat/screens/mobile_chat_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ContactsList extends ConsumerWidget {
  final String search;
  const ContactsList({Key? key, required this.search}) : super(key: key);

  String formatTimeSent(DateTime timeSent) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime messageDate = DateTime(timeSent.year, timeSent.month, timeSent.day);

    if (messageDate == today) {
      return DateFormat.Hm().format(timeSent);
    } else {
      return DateFormat.Md().format(timeSent);
    }
  }

  String formatString(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    int timestamp = dateTime.millisecondsSinceEpoch;
    print(timestamp);

    return timestamp.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String groupSenderId = '';
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: [
          StreamBuilder<List<ChatContact>>(
            stream: ref.watch(chatControllerProvider).getChatContactsList(search),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }             
              
              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var chatContactData = snapshot.data![index];
                    if(chatContactData.isGroupChat == true){
                      FirebaseFirestore.instance.collection('groups').doc(chatContactData.contactId).get().then((doc) {
                        var groupData = doc.data();
                        groupSenderId = groupData?['senderId'];
                      }).catchError((error) {
                        print("Error getting document: $error");
                      });                      
                    }
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              MobileChatScreen.routeName,
                              arguments: {
                                'name': chatContactData.name,
                                'uid': chatContactData.contactId,
                                'isGroupChat': chatContactData.isGroupChat,
                                'profilePic': chatContactData.profilePic,
                                'senderId': groupSenderId,
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              title: Text(
                                chatContactData.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  chatContactData.lastMessage,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  chatContactData.profilePic,
                                ),
                                radius: 30,
                              ),
                              trailing: Text(
                              MyDateUtil.getLastMessageTime(context: context, time: formatString(chatContactData.timeSent.toString())),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Divider(color: dividerColor, indent: 85),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
