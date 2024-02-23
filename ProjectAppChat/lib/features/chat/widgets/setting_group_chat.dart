import 'dart:io';

import 'package:appchat/colors.dart';
import 'package:appchat/features/auth/repository/auth_repository.dart';
import 'package:appchat/features/call/controller/call_controller.dart';
import 'package:appchat/features/chat/widgets/view_members.dart';
import 'package:appchat/features/group/controller/group_controller.dart';
import 'package:appchat/features/group/widgets/add_user_group.dart';
import 'package:appchat/models/user_model.dart';
import 'package:appchat/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingGroupChat extends ConsumerStatefulWidget {
  static const String routeName = '/setting-group';
  final String name;
  final String uid;
  final bool isGroupChat;
  final String profilePic;
  final String senderId;
  const SettingGroupChat({
    Key? key,
    required this.name,
    required this.uid,
    required this.isGroupChat,
    required this.profilePic,
    required this.senderId,
    }) : super(key: key);

  @override
  ConsumerState<SettingGroupChat> createState() => _SettingGroupChatState();
}

class _SettingGroupChatState extends ConsumerState<SettingGroupChat> {
  final TextEditingController groupNameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  File? image; 
  bool isMe = false; 

  late Future<UserModel?> userDataFuture;

  void initState() {
    super.initState();
    // Set default name from user data
    userDataFuture = _getDefaultUserData();
    groupNameController.text = widget.name;
    searchController;
  }

  Future<UserModel?> _getDefaultUserData() async {
    return ref.read(authRepositoryProvider).getCurrentUserData();
  }


  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void editGroup() {
    if (groupNameController.text.trim().isNotEmpty) {
      ref.read(groupControllerProvider).AddUserGroup(
            context,
            widget.uid,
            groupNameController.text.trim(),            
            image,
            ref.read(selectedGroupContacts),
          );
      ref.read(selectedGroupContacts.state).update((state) => []);
      Navigator.pop(context);
    }
  }

  void leaveGroup(){
    ref.read(groupControllerProvider).leaveGroup(context, widget.uid);
  }

  void deleteGroup(){
    ref.read(groupControllerProvider).deleteGroup(context, widget.uid);
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  void makeCall(WidgetRef ref, BuildContext context, bool isVideoCall) {
    ref.read(callControllerProvider).makeCall(
      context, 
      widget.name, 
      widget.uid, 
      widget.profilePic, 
      widget.isGroupChat,
      isVideoCall,
    );
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Center(
        child: FutureBuilder<UserModel?>(
          future: userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final currentUserData = snapshot.data;
              if(currentUserData!.uid == widget.senderId){
                isMe = true;
              }
              return Column(
                children: [
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      image == null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                widget.profilePic,
                              ),
                              radius: 64,
                            )
                          : CircleAvatar(
                              backgroundImage: FileImage(
                                image!,
                              ),
                              radius: 64,
                            ),
                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(
                            Icons.add_a_photo,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: groupNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Group Name',
                      ),
                    ),
                  ),
                  const SizedBox(height: 15), 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.blueAccent,
                            child: IconButton(
                              icon: Icon(
                                Icons.phone,
                                color: Colors.white,
                              ),
                              onPressed: () => makeCall(ref, context, false),
                            ),
                          ),
                          const SizedBox(height: 5), // Adjust the spacing as needed
                          const Text(
                            'Call Audio',
                            style: TextStyle(
                              fontSize: 12, // Adjust the font size as needed
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.blueAccent,
                            child: IconButton(
                              icon: Icon(
                                Icons.video_call,
                                color: Colors.white,
                              ),
                              onPressed: () => makeCall(ref, context, true),
                            ),
                          ),
                          const SizedBox(height: 5), // Adjust the spacing as needed
                          const Text(
                            'Video Call',
                            style: TextStyle(
                              fontSize: 12, // Adjust the font size as needed
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: tabColor,
                            child: IconButton(
                              icon: Icon(
                                Icons.group_add_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: MediaQuery.of(context).size.height * 0.8, 
                                      child: Column(
                                        children: [
                                          SizedBox(height: 14,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [                                            
                                              ElevatedButton(
                                                child:  const Text(
                                                  'Save',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all<Color>(tabColor),
                                                ),
                                                onPressed: editGroup,
                                              ),
                                              SizedBox(width: 18,),
                                              ElevatedButton(
                                                child: Text(
                                                  'Close',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
                                                ),
                                                onPressed: (){
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20,),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: TextField(
                                              controller: searchController,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                                labelText: 'Search',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                prefixIcon: Icon(Icons.search),
                                              ),
                                            ),
                                          ),                                          
                                          SizedBox(height: 10,),
                                          AddContactsGroup(uid: widget.uid, search: searchController.text,),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },

                            ),
                          ),
                          const SizedBox(height: 5), // Adjust the spacing as needed
                          const Text(
                            'Add User',
                            style: TextStyle(
                              fontSize: 12, // Adjust the font size as needed
                            ),
                          ),
                        ],
                      ),
                      if (isMe)
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.redAccent,
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: Colors.white,
                                ),
                                onPressed: deleteGroup,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Delete Group',
                              style: TextStyle(
                                fontSize: 12,
                              )
                            ),
                          ],
                        ),
                        if (!isMe)
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.redAccent,
                              child: IconButton(
                                icon: Icon(
                                  Icons.exit_to_app,
                                  color: Colors.white,
                                ),
                                onPressed: leaveGroup,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Leave Group',
                              style: TextStyle(
                                fontSize: 12,
                              )
                            ),
                          ],
                        )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'customize',
                              style: TextStyle(
                                color: Colors.white54
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context, 
                              ViewMembers.routeName,
                              arguments: {
                                'groupId': widget.uid,
                                'uid': currentUserData.uid,
                              }
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('View members'),
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.grey,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.group,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        )

                      ],
                    ),
                  ),
                   // const SelectContactsGroup(),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: editGroup,
        backgroundColor: tabColor,
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}