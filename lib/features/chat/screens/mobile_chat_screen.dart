import 'package:chatting_app/Common/utils/functions.dart';
import 'package:chatting_app/Common/widgets/loader.dart';
import 'package:chatting_app/User_info/Controller/userController.dart';
import 'package:chatting_app/User_info/Model/UserModel.dart';

import 'package:chatting_app/features/chat/screens/widgets/friend_profile.dart';

import 'package:chatting_app/features/chat/screens/widgets/bottom_chat_field.dart';
import 'package:chatting_app/widgets/chat_list.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = "/mobilechat-screen";
  final String name;
  final String uid;

  const MobileChatScreen({super.key, required this.name, required this.uid});

  @override
  build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<UserProfile>(
            stream: ref.read(authControllerProvider).userDataById(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              final appbar = parseColor(snapshot.data!.bg.Appbar);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WhatsappProfilePage(
                        uid: uid,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(snapshot.data!.profile),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (name.length > 9) ? 13.0 : null,
                    ),
                    maxLines: 1, // Restricts to one line
                    overflow: TextOverflow
                        .ellipsis, // Shows "..." if text is too long
                    softWrap: false,
                  ),
                  subtitle:
                      Text(snapshot.data!.inOnline ? "online " : "offline"),
                ),
              );
            }),
        centerTitle: false,
        backgroundColor: appbarColor,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.video_call,
              color: Colors.white70,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.call,
              color: Colors.white70,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(
              receiverId: uid,
            ),
          ),
          BottomChatField(
            recieverUserId: uid,
          ),
        ],
      ),
    );
  }
}
