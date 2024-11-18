import 'package:chatting_app/Common/utils/functions.dart';
import 'package:chatting_app/User_info/Model/UserModel.dart';
import 'package:chatting_app/User_info/Screen/user_details.dart';
import 'package:chatting_app/User_info/Screen/widget/chat_settings.dart';
import 'package:chatting_app/User_info/Screen/widget/nearby_settings.dart';
import 'package:chatting_app/User_info/Screen/widget/private_Screen.dart';
import 'package:chatting_app/User_info/Screen/widget/selected_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  static const routeName = "/settings-page-screen";
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late UserProfile obj;

  Future<UserProfile?> fetchUserData(String uid) async {
    print("functiin call");
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder<UserProfile?>(
        future: fetchUserData(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching data
            return Scaffold(
              appBar: AppBar(
                title: const Text('Settings'),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            // Handle error scenario
            return Scaffold(
              appBar: AppBar(
                title: const Text('Settings'),
              ),
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else if (snapshot.hasData) {
            print("snapshot.data${snapshot.data}");
            // If the data is available, extract it
            UserProfile? userProfile = snapshot.data;
            List<Color> gradientColors =
                parseGradientColor(userProfile!.bg.body);
            final Color startGradientColor =
                gradientColors[0]; // Default gradient start color
            final Color endGradientColor = gradientColors[1];
            final Color appbar = parseColor(userProfile.bg.Appbar);

            return Scaffold(
              appBar: AppBar(
                backgroundColor: appbar,
                title: const Text('Settings'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                ],
              ),
              body: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [startGradientColor, endGradientColor])),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InkWell(
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: CircleAvatar(
                                    radius: screenWidth * 0.20,
                                    backgroundImage: NetworkImage(
                                        userProfile?.profile ??
                                            "assets/images/empty_image.jpg"),
                                  ),
                                ),
                                // Positioned(
                                //   left: 100,
                                //   bottom: -10,
                                //   child: IconButton(
                                //     // onPressed: () => selectImage("PROFILE"),
                                //     onPressed: () {},
                                //     icon: const Icon(Icons.add_a_photo),
                                //   ),
                                // ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userProfile?.firstName ?? 'HELLO WORLD',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  userProfile?.describes.descriptio ?? "",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                                Text(
                                  userProfile?.phoneNumber ?? 'MOBILE NUMBER',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const Spacer(),
                          ],
                        ),
                        onTap: () {},
                      ),
                    ),
                    const Divider(),
                    ListTile(
                        leading: const Icon(Icons.vpn_key),
                        title: const Text('Account'),
                        subtitle:
                            const Text('Security notifications, change number'),
                        onTap: () {
                          Navigator.pushNamed(context, UserDetails.routeName,
                              arguments: {
                                "name": userProfile?.firstName,
                                "description":
                                    userProfile?.describes.descriptio,
                                "profileimage": userProfile?.profile,
                                "backgroundimage": userProfile?.bgImage,
                                "mobilenumber": userProfile?.phoneNumber
                              });
                        }),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Privacy'),
                      subtitle:
                          const Text('Block contacts, disappearing messages'),
                      onTap: () {
                        Navigator.pushNamed(context, PrivateSetting.routeName,
                            arguments: {
                              "status": userProfile?.privateSettings.isPrivate,
                              'privateImage':
                                  userProfile?.privateSettings.privateImage,
                              "privateName":
                                  userProfile?.privateSettings.privateName
                            });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Near Dost '),
                      subtitle: const Text('Create, edit, profile photo'),
                      onTap: () {
                        Navigator.pushNamed(context, NearbySettings.routeName,
                            arguments: {
                              "nearby": userProfile?.nearbyCoordinates.nearby,
                              "radius": '50'
                            });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.favorite),
                      title: const Text('Favorites'),
                      subtitle: const Text('Add, reorder, remove'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.chat),
                      title: const Text('Chats'),
                      subtitle: const Text('Theme, wallpapers, chat history'),
                      onTap: () {
                        Navigator.pushNamed(context, PasswordScreen.routeName,
                            arguments: {
                              "passwod": userProfile?.lockSettings.password
                            });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Notifications'),
                      subtitle: const Text('Message, group & call tones'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.data_usage),
                      title: const Text('BACKGRAOUND COLORS'),
                      subtitle: const Text('Network usage, auto-download'),
                      onTap: () {
                        Navigator.pushNamed(
                            context, ColorPickerScreen.routeName,
                            arguments: {
                              "Appbar": userProfile?.bg.Appbar,
                              "start": userProfile?.bg.body,
                            });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('App language'),
                      subtitle: const Text('English (device\'s language)'),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            );
          }
          // If there's no data or no error, show an empty state
          return Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
            ),
            body: const Center(child: Text('No user data found.')),
          );
        });
  }
}
