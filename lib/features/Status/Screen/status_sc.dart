import 'package:chatting_app/features/Status/Controller/status_controller.dart';
import 'package:chatting_app/features/Status/Model/status_model.dart';
import 'package:chatting_app/features/Status/Screen/status_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusContactsScreen extends ConsumerStatefulWidget {
  static const String routeName = '/screen-status-screen';
  const StatusContactsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StatusContactsScreen> createState() => _StatusPageState();
}

class _StatusPageState extends ConsumerState<StatusContactsScreen> {
  final List<Channel> channels = [
    Channel(
        name: 'TV9 Telugu',
        imageUrl: 'https://via.placeholder.com/150',
        isVerified: true),
    Channel(
        name: 'Total Gaming',
        imageUrl: 'https://via.placeholder.com/150',
        isVerified: true),
    Channel(
        name: 'Tenaja',
        imageUrl: 'https://via.placeholder.com/150',
        isVerified: false),
    Channel(
        name: 'TV9 Telugu',
        imageUrl: 'https://via.placeholder.com/150',
        isVerified: true),
    Channel(
        name: 'Total Gaming',
        imageUrl: 'https://via.placeholder.com/150',
        isVerified: true),
    Channel(
        name: 'Tenaja',
        imageUrl: 'https://via.placeholder.com/150',
        isVerified: false),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Status>>(
      future: ref.read(statusControllerProvider).getStatus(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error--: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No statuses available"));
        }

        final statuses = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ListView(
            children: [
              // Status display
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: statuses.map((status) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StatusPlayScreen(
                                  mediaList: status.media,
                                  isCurrentUser: status.uid ==
                                      FirebaseAuth.instance.currentUser!.uid,
                                  userinfo: status,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: SweepGradient(
                                        colors: List.generate(
                                          status.media.length,
                                          (index) => Colors.primaries[index %
                                                  Colors.primaries.length]
                                              .withOpacity(0.8),
                                        ),
                                        stops: List.generate(
                                          status.media.length,
                                          (index) =>
                                              (index + 0.5) /
                                              status.media.length,
                                        ),
                                      ),
                                    ),
                                  ),
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(status.profilePic),
                                    radius: 40,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                status.uid ==
                                        FirebaseAuth.instance.currentUser?.uid
                                    ? "You"
                                    : status.username,
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const Divider(),
              // Channels display
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: channels.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: ChannelCard(channel: channels[index]),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}

class Channel {
  final String name;
  final String imageUrl;
  final bool isVerified;

  Channel(
      {required this.name, required this.imageUrl, required this.isVerified});
}

class ChannelCard extends StatelessWidget {
  final Channel channel;

  const ChannelCard({Key? key, required this.channel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Minimizes overflow issues
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(channel.imageUrl),
                  ),
                  if (channel.isVerified)
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        Icons.private_connectivity_rounded,
                        color: Colors.blue,
                        size: 18,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                channel.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // Avoids overflow
                maxLines: 1,
              ),
              const SizedBox(height: 8), // Controlled space instead of Spacer
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('MESSAGE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
