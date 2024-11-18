import 'package:chatting_app/Common/widgets/loader.dart';
import 'package:chatting_app/colors.dart';

import 'package:chatting_app/features/chat/controller/chat_controller.dart';
import 'package:chatting_app/features/chat/model/chat_contact.dart';
import 'package:chatting_app/features/chat/screens/mobile_chat_screen.dart';
import 'package:chatting_app/features/chat/common/common_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ContactsList extends ConsumerWidget {
  final bool status;
  const ContactsList(this.status, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("contact_list");
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: StreamBuilder<List<ChatContact>>(
        stream: ref.watch(chatcontroller).chatContact(status: status),
        builder: (context, snapshot) {
          print("snapshot ${snapshot.data}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No contacts available'),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var chatContact = snapshot.data![index];

              // Replace chatContact.name with uid_getPhoneNumber output
              return FutureBuilder<String?>(
                future: uid_getPhoneNumber(chatContact.contactId),
                builder: (context, nameSnapshot) {
                  var displayName = nameSnapshot.data ?? chatContact.name;
                  print(
                      " chatContact.profilepic chatContact.profilepic ${chatContact.profilepic}");
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          print(
                              " contact list $displayName ${chatContact.contactId}");
                          Navigator.pushNamed(
                            context,
                            MobileChatScreen.routeName,
                            arguments: {
                              'name': displayName,
                              'uid': chatContact.contactId,
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                chatContact.lastmessage,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                chatContact.profilepic,
                              ),
                              radius: 30,
                            ),
                            trailing: Text(
                              DateFormat.Hm().format(chatContact.timetosent),
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
              );
            },
          );
        },
      ),
    );
  }
}
