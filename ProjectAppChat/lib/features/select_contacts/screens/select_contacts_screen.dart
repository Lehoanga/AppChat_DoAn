import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/error.dart';
import '../../../common/widgets/loader.dart';
import '../controller/select_contact_controller.dart';

class SelectContactsScreen extends ConsumerWidget {
  static const String routeName = '/select-contact';
  const SelectContactsScreen({Key? key}) : super(key: key);

  void selectContact(
      WidgetRef ref, Contact selectedContact, BuildContext context) {
    ref
        .read(selectContactControllerProvider)
        .selectContact(selectedContact, context);
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(      
      body: ref.watch(getContactsProvider).when(
        data: (contactList) => ListView.builder(
          itemCount: contactList.length,
          itemBuilder: (context, index) {
            final contact = contactList[index];
            return InkWell(
              onTap: () => selectContact(ref, contact, context),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        contact.phones[0].number,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  leading: contact.photo == null
                      ? const CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                          ),
                          radius: 30,
                        )
                      : CircleAvatar(
                          backgroundImage: MemoryImage(contact.photo!),
                          radius: 30,
                        ),
                ),
              ),
            );
          }
        ),
        error: (err, trace) => ErrorScreen(error: err.toString()),
        loading: () => const Loader(),
      ),
    );
  }
}