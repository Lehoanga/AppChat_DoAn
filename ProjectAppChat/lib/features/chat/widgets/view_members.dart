import 'package:appchat/colors.dart';
import 'package:appchat/features/chat/screens/mobile_chat_screen.dart';
import 'package:appchat/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/group.dart' as model;

class ViewMembers extends ConsumerStatefulWidget {
  static const String routeName = '/view-members';
  final String groupId;
  final String uid;
  const ViewMembers({
    super.key, 
    required this.groupId, 
    required this.uid
    });

  @override
  ConsumerState<ViewMembers> createState() => _ViewMembersState();
}

class _ViewMembersState extends ConsumerState<ViewMembers> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Số lượng tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('View members'),
          bottom: TabBar(
            indicatorColor: tabColor,
            indicatorWeight: 4,
            labelColor: tabColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: 'Members'),
              Tab(text: 'Admin'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FirstPage(groupId: widget.groupId, uid: widget.uid),
            SecondPage(uid: widget.uid),
          ],
        ),
      ),
    );
  }
}

class FirstPage extends StatefulWidget {
  final String groupId;
  final String uid;
  FirstPage({
    required this.groupId,
    required this.uid,
  });

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  model.Group? group;
  List<UserModel> users = [];
  Future<model.Group?> getCurrentGroupData(String groupId) async {
    var groupData =
        await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
    model.Group? group;
    if (groupData.data() != null) {
      group = model.Group.fromMap(groupData.data()!);
    }
    return group; 
  } 

  Future<List<UserModel>> getUsersData(List<String> userIds) async {
    List<UserModel> users = [];
    for (String userId in userIds) {
      var userData = await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .get();

      if (userData.exists) {
        UserModel user = UserModel.fromMap(userData.data()!);
        users.add(user);
      }
    }
    return users;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _removeUserFromGroup(UserModel user, model.Group group) async {
    List<String> updatedMembers = List.from(group.membersUid);
    updatedMembers.remove(user.uid);

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(group.groupId)
        .update({'membersUid': updatedMembers});

    await _loadData();
  }

  Future<void> _loadData() async {
    group = await getCurrentGroupData(widget.groupId);
    if (group != null) {
      users = await getUsersData(group!.membersUid);
    }
    setState(() {}); // Trigger a rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(    
      body: Center(
        child: FutureBuilder<model.Group?>(
          future: getCurrentGroupData(widget.groupId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Text('No Data');
            } else {
              model.Group group = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [                
                  Expanded(
                    child: Container(                    
                      padding: EdgeInsets.all(8.0),
                      child: FutureBuilder<List<UserModel>>(
                        future: getUsersData(group.membersUid),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (userSnapshot.hasError) {
                            return Text('Error: ${userSnapshot.error}');
                          } else if (!userSnapshot.hasData ||
                              userSnapshot.data == null) {
                            return Text('No Data');
                          } else {
                            List<UserModel> users = userSnapshot.data!;
                            return ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                if (users[index].uid == widget.uid) {
                                  return SizedBox.shrink(); // Skip this ListTile if UID doesn't match
                                }
                                return ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          users[index].name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text( 
                                          users[index].gmail == 'null' ? users[index].phoneNumber : users[index].gmail,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(users[index].profilePic),
                                    radius: 25,
                                  ), 
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.arrow_circle_right_outlined,
                                          color: Colors.blueAccent,
                                        ),
                                        onPressed: (){
                                          Navigator.pushNamed(
                                            context,
                                            MobileChatScreen.routeName,
                                            arguments: {
                                              'name': users[index].name,
                                              'uid': users[index].uid,
                                              'isGroupChat': false,
                                              'profilePic': users[index].profilePic,
                                              'senderId': widget.uid,
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () {
                                          _removeUserFromGroup(users[index], group);
                                        },
                                      ),                                      
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}



class SecondPage extends StatelessWidget {
  final String uid;
  SecondPage({required this.uid});

  Stream<UserModel> userData(String userId) {
    return FirebaseFirestore.instance.collection('user').doc(userId).snapshots().map(
          (event) => UserModel.fromMap(
            event.data()!,
          ),
        );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(    
    body: Center(
      child: StreamBuilder<UserModel>(
        stream: userData(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Text('No Data');
          } else {
            UserModel user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user.profilePic),
                        radius: 25,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              user.gmail == 'null' ? user.phoneNumber : user.gmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_circle_right_outlined,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            MobileChatScreen.routeName,
                            arguments: {
                              'name': user.name,
                              'uid': user.uid,
                              'isGroupChat': false,
                              'profilePic': user.profilePic,
                              'senderId': uid,
                            },
                          );
                        },
                      ),                      
                    ],
                  ),
                    ],              
                  ),
                  SizedBox(height: 16),
                  
                ],
              ),
            );
          }
        },
      ),
    ),
  );
}

}