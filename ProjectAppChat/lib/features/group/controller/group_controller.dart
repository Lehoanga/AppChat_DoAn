
import 'dart:io';

import 'package:appchat/features/group/repository/group_repository.dart';
import 'package:appchat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupControllerProvider = Provider((ref) {
  final groupRepository = ref.read(groupRepositoryProvider);
  return GroupController(
    groupRepository: groupRepository,
    ref: ref,
  );
});

class GroupController {
  final GroupRepository groupRepository;
  final ProviderRef ref;
  GroupController({
    required this.groupRepository,
    required this.ref,
  });

  void createGroup(BuildContext context, String name, File profilePic,
      List<Contact> selectedContact) {
    groupRepository.createGroup(context, name, profilePic, selectedContact);
  }

  void EditGroup(BuildContext context, String groupId, String name, File? profilePic,
      List<Contact> selectedContact) {
    groupRepository.updateGroup(context, groupId, name, profilePic, selectedContact);
  }

  void AddUserGroup(BuildContext context, String groupId, String name, File? profilePic,
      List<UserModel> user) {
    groupRepository.addUserGroup(context, groupId, name, profilePic, user);
  }

  void leaveGroup(BuildContext context, String groupId){
    groupRepository.leaveGroup(context, groupId);
  }

  void deleteGroup(BuildContext context, String groupId){
    groupRepository.deleteGroup(context, groupId);
  }
}