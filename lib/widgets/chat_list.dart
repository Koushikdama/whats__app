import 'package:chatting_app/Common/Providers/messsage_reply_provider.dart';
import 'package:chatting_app/Common/enums/message_enmu.dart';

import 'package:chatting_app/Common/utils/functions.dart';
import 'package:chatting_app/features/chat/controller/chat_controller.dart';
import 'package:chatting_app/features/chat/repository/chat_repository.dart';
import 'package:chatting_app/features/chat/screens/widgets/my_message_card.dart';
import 'package:chatting_app/features/chat/screens/widgets/sender_message_card.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting

class ChatList extends ConsumerStatefulWidget {
  final String receiverId;
  const ChatList({super.key, required this.receiverId});

  @override
  ConsumerState<ChatList> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  void onMessageSwipe(
    String message,
    bool isMe,
    MessageEnum messageEnum,
  ) {
    ref.read(messageReplyProvider.notifier).update(
          (state) => MessageReply(
            message,
            isMe,
            messageEnum,
          ),
        );
  }

  MessageEnum messageEnumFromString(String value) {
    return MessageEnum.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => MessageEnum.text);
  }

  void updateonline(String uid, bool status) {
    ref.read(chatcontroller).updateonline(uid, status);
  }

  @override
  void initState() {
    super.initState();
    updateonline(widget.receiverId, true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        updateonline(widget.receiverId, false);
      },
      canPop: true,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: ref.watch(chatcontroller).contactmessages(widget.receiverId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No messages yet.'));
          }

          final dayChats = snapshot.data!;
          print("dayChats ${dayChats}");
          // Ensure that the current user is authenticated
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) {
            return const Center(child: Text('User not authenticated.'));
          }

          // Scroll to the latest message when the screen is loaded
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (messageController.hasClients) {
              messageController
                  .jumpTo(messageController.position.maxScrollExtent);
            }
          });

          return ListView.builder(
            controller: messageController,
            itemCount: dayChats.length,
            itemBuilder: (context, index) {
              final dayChat = dayChats[index];
              final List<dynamic> messages = dayChat['messages'] ?? [];

              // Ensure messages exist before building the list
              if (messages.isEmpty) {
                return const Center(child: Text('No messages in this chat.'));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header for the day
                  Center(
                      child: TextButton(
                          onPressed: () => updateChatIsVanish(
                              currentUser.uid,
                              widget.receiverId,
                              convertTimestampToDateString(dayChat['date']),
                              !dayChat['isvanish']),
                          child: Text(getDate(dayChat['date'])))),

                  // Message List for the particular day
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (context, messageIndex) {
                      final message = messages[messageIndex];
                      final bool isMe = message['senderId'] ==
                          FirebaseAuth.instance.currentUser!.uid;
                      final String formattedTime = DateFormat('hh:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              message['timeSent']));

                      if (!dayChat['isvanish']) {
                        if (!message['isSeen'] &&
                            widget.receiverId ==
                                FirebaseAuth.instance.currentUser!.uid) {
                          ref.watch(chatcontroller).setSeen(
                              context, widget.receiverId, message['messageId']);
                        }

                        if (isMe) {
                          return MyMessageCard(
                            message: message['text'],
                            date: formattedTime.toString(),
                            type: messageEnumFromString(message['type']),
                            repliedMessageType: messageEnumFromString(
                                message['repliedMessageType']),
                            username: message['repliedTo'],
                            repliedText: message['repliedMessage'],
                            onLeftSwipe: () => onMessageSwipe(
                              message['text'],
                              true,
                              message['type'],
                            ),
                          );
                        }
                        return SenderMessageCard(
                          message: message['text'],
                          date: formattedTime.toString(),
                          type: messageEnumFromString(message['type']),
                          repliedMessageType: messageEnumFromString(
                              message['repliedMessageType']),
                          username: message['repliedTo'],
                          repliedText: message['repliedMessage'],
                          onrightswip: () => onMessageSwipe(
                            message['text'],
                            false,
                            message['type'],
                          ),
                        );
                      }
                      return const SizedBox
                          .shrink(); // If message is vanished, don't show anything
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
