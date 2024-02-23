import 'package:appchat/colors.dart';
import 'package:appchat/common/widgets/loader.dart';
import 'package:appchat/features/chat/controller/chat_controller.dart';
import 'package:appchat/features/chat/screens/mobile_chat_screen.dart';
import 'package:appchat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchContactsScreen extends ConsumerWidget {
  final String search;
  const SearchContactsScreen({Key? key, required this.search}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isGroupChat = false;
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: [
          StreamBuilder<List<UserModel>>(
            stream: ref.watch(chatControllerProvider).getContactsList(search),
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
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            if(chatContactData.gmail == '' && chatContactData.phoneNumber == 'null' && chatContactData.token == ''){
                              isGroupChat == true;
                            }
                            Navigator.pushNamed(
                              context,
                              MobileChatScreen.routeName,
                              arguments: {
                                'name': chatContactData.name,
                                'uid': chatContactData.uid,
                                'isGroupChat': isGroupChat,
                                'profilePic': chatContactData.profilePic,
                                'senderId': ''
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: ListTile(
                              title: Text(
                                chatContactData.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  chatContactData.gmail == 'null' 
                                  ? chatContactData.phoneNumber
                                  : chatContactData.gmail,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  chatContactData.profilePic,
                                ),
                                radius: 30,
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