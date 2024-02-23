import 'dart:io';

import 'package:appchat/colors.dart';
import 'package:appchat/features/auth/controller/auth_controller.dart';
import 'package:appchat/features/auth/repository/auth_repository.dart';
import 'package:appchat/models/user_model.dart';
import 'package:appchat/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditUserInformation extends ConsumerStatefulWidget {
  static const String routeName = '/edit-user-information';
  const EditUserInformation({
    Key? key, 
    }) : super(key: key);

  @override
  ConsumerState<EditUserInformation> createState() => _EditUserInformationState();
}

class _EditUserInformationState extends ConsumerState<EditUserInformation> {
  final TextEditingController nameController = TextEditingController();
  File? image;

  late Future<UserModel?> userDataFuture;

  void initState() {
    super.initState();
    // Set default name from user data
    userDataFuture = _getDefaultUserData();
  }

  Future<UserModel?> _getDefaultUserData() async {
    return ref.read(authRepositoryProvider).getCurrentUserData();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void storeUserData() async {
    String name = nameController.text.trim();

    if (name.isNotEmpty) {
      ref.read(authControllerProvider).saveUserDataToFirebase(
            context,
            name,
            image,
            'none'
      );
    }
  }  
  

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text('Information'),
      ),
      body: SafeArea(
        child: Center(
          child: FutureBuilder<UserModel?>(
            future: userDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Or another loading indicator
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                // Set default values after getting user data
                final currentUserData = snapshot.data;
                if (currentUserData != null) {
                  nameController.text = currentUserData.name;
                }

                return Column(
                  children: [
                    const SizedBox(height: 40,),
                    Stack(
                      children: [
                        image == null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(
                            currentUserData!.profilePic,
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
                    Row(
                      children: [
                        Container(
                          width: size.width * 0.85,
                          padding: const EdgeInsets.all(20),
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your name',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: storeUserData,
                          icon: const Icon(
                            Icons.done,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(authControllerProvider).signOut(context);
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tabColor,
                        minimumSize: const Size(double.minPositive, 50),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: blackColor,
                        ),
                        ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
