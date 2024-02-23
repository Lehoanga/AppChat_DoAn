import 'package:appchat/common/widgets/error.dart';
import 'package:appchat/common/widgets/loader.dart';
import 'package:appchat/models/group.dart' as model;
import 'package:appchat/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedGroupContacts = StateProvider<List<UserModel>>((ref) => []);

class AddContactsGroup extends ConsumerStatefulWidget {
  final String uid;
  final String search;
  const AddContactsGroup({required this.uid, required this.search, Key? key}) : super(key: key);

  @override
  ConsumerState<AddContactsGroup> createState() =>
      _AddContactsGroupState();
}

class _AddContactsGroupState extends ConsumerState<AddContactsGroup> {
  List<String> selectedContactsUserIds = [];

  void selectContact(UserModel user) {
    if (selectedContactsUserIds.contains(user.uid)) {
      selectedContactsUserIds.remove(user.uid);
    } else {
      selectedContactsUserIds.add(user.uid);
    }
    setState(() {});
    ref
        // ignore: deprecated_member_use
        .read(selectedGroupContacts.state)
        .update((state) => [...state, user]);
  }

  Future<model.Group?> getCurrentGroupData(String groupId) async {
    var groupData =
        await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
    model.Group? group;
    if (groupData.data() != null) {
      group = model.Group.fromMap(groupData.data()!);
    }
    return group; 
  } 

  @override
Widget build(BuildContext context) {
  return FutureBuilder<model.Group?>(
    future: getCurrentGroupData(widget.uid),
    builder: (context, groupSnapshot) {
      if (groupSnapshot.connectionState == ConnectionState.waiting) {
        return Loader();
      }

      if (groupSnapshot.hasError) {
        return ErrorScreen(error: groupSnapshot.error.toString());
      }

      var groupData = groupSnapshot.data;
      List<String> members = groupData!.membersUid;

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorScreen(error: snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loader();
          }
          
          List<UserModel> userList = snapshot.data!.docs
            .map((document) => UserModel.fromMap(document.data() as Map<String, dynamic>))
            .where((user) => !members.contains(user.uid))
            .toList();

          if (widget.search != '') {
            userList = userList.where((user) => user.name.toLowerCase().contains(widget.search.toLowerCase())).toList();   
          }

          final userDataList = userList;
          
          return Expanded(
            child: Column(
              children: [                    
                Expanded(
                  child: ListView.builder(
                    itemCount: userDataList.length,
                    itemBuilder: (context, index) {
                      final user = userDataList[index];
                      return InkWell(
                        onTap: () => selectContact(user),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user.profilePic),
                              radius: 25,
                            ),
                            trailing: selectedContactsUserIds.contains(user.uid)
                                ? IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.done),
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

}
