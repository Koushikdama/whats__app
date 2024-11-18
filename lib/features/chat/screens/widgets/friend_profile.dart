import 'dart:math';

import 'package:chatting_app/Common/utils/functions.dart';
import 'package:chatting_app/Common/utils/showAlert.dart';
import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Controller/userController.dart';
import 'package:chatting_app/User_info/Model/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class WhatsappProfilePage extends ConsumerStatefulWidget {
  final String uid;

  const WhatsappProfilePage({super.key, required this.uid});

  @override
  ConsumerState<WhatsappProfilePage> createState() =>
      _WhatsappProfilePageState();
}

Color? appbarColor; // Default AppBar color
Color? startGradientColor; // Default start gradient color
Color? endGradientColor;

class _WhatsappProfilePageState extends ConsumerState<WhatsappProfilePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<friendprofile?>(
          future: ref
              .watch(authControllerProvider)
              .getprofiledetails(context, widget.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Scaffold(
                  body: Center(child: Text('No profile found')));
            }

            final profileDetails = snapshot.data!;
            bool isOccur =
                profileDetails.locksettings.users.contains(widget.uid);
            String password = profileDetails.locksettings.password;
            Color appbarColor = parseColor(profileDetails.appbar);
            List<Color> body = parseGradientColor(profileDetails.body);
            startGradientColor = body[0];
            endGradientColor = body[1];
            print("password====${password} ${appbarColor} ${body}");
            LinearGradient gradient = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: body, // Pass the List<Color> here
            );
            return Container(
              decoration: BoxDecoration(gradient: gradient),
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    delegate: _WhatsappAppbar(
                        MediaQuery.of(context).size.width,
                        profileDetails.profile,
                        profileDetails.name,
                        appbarColor,
                        body),
                    pinned: true,
                  ),
                  SliverToBoxAdapter(
                    child: _ProfileDetailsWithBody(
                      phoneNumber: profileDetails.number,
                      userName: profileDetails.name,
                      description: profileDetails.describes,
                      isLock: isOccur,
                      uid: widget.uid,
                      image: profileDetails.profile,
                      password: profileDetails.locksettings.password,
                      appbar: appbarColor,
                      body: body,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WhatsappAppbar extends SliverPersistentHeaderDelegate {
  final double screenWidth;
  final String image;
  final String name;
  final Color appbar;
  final List<Color> body;
  Tween<double>? profilePicTranslateTween;

  _WhatsappAppbar(
      this.screenWidth, this.image, this.name, this.appbar, this.body) {
    profilePicTranslateTween =
        Tween<double>(begin: screenWidth / 2 - 85, end: 40.0);
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final relativeScroll = min(shrinkOffset, 45) / 45;
    final relativeScroll70px = min(shrinkOffset, 70) / 70;

    return Container(
      color: ColorTween(begin: appbar, end: appbar).transform(relativeScroll),
      child: Container(
        decoration:
            BoxDecoration(gradient: LinearGradient(colors: [appbar, appbar])),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, size: 25),
                color: ColorTween(begin: body[0], end: body[1])
                    .transform(relativeScroll),
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, size: 25),
                color: ColorTween(begin: body[0], end: body[1])
                    .transform(relativeScroll),
              ),
            ),
            Positioned(
              top: 15,
              left: 90,
              child: _displayPhoneNumber(relativeScroll70px, name),
            ),
            Positioned(
              top: 5,
              left: profilePicTranslateTween!.transform(relativeScroll70px),
              child: _displayProfilePicture(relativeScroll70px, image),
            ),
          ],
        ),
      ),
    );
  }

  Widget _displayProfilePicture(double relativeFullScrollOffset, String image) {
    return Transform(
      transform: Matrix4.identity()
        ..scale(3.5 - (2.5 * relativeFullScrollOffset)),
      child: CircleAvatar(
        backgroundImage: NetworkImage(image),
      ),
    );
  }

  Widget _displayPhoneNumber(double relativeFullScrollOffset, String name) {
    if (relativeFullScrollOffset >= 0.8) {
      return Transform(
        transform: Matrix4.identity()
          ..translate(0.0, (relativeFullScrollOffset - 0.8) * 20),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 20 - ((relativeFullScrollOffset - 0.8) * 4),
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  double get maxExtent => 120;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(_WhatsappAppbar oldDelegate) {
    return true;
  }
}

class _ProfileDetailsWithBody extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String userName;
  final Description description; // Ensure Description is defined in UserModel
  final bool isLock;
  final String image;
  final String uid;
  final String password;
  final Color appbar;
  final List<Color> body;

  const _ProfileDetailsWithBody(
      {required this.phoneNumber,
      required this.userName,
      required this.description,
      required this.isLock,
      required this.password,
      required this.image,
      required this.uid,
      required this.appbar,
      required this.body});

  @override
  ConsumerState<_ProfileDetailsWithBody> createState() =>
      _ProfileDetailsWithBodyState();
}

class _ProfileDetailsWithBodyState
    extends ConsumerState<_ProfileDetailsWithBody> {
  late bool _isLock;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _isLock = widget.isLock; // Initialize the state variable
    _obscureText = true;
    setState(() {
      appbarColor = widget.appbar;
      startGradientColor = widget.body[0];
      endGradientColor = widget.body[1];
    });
    // Initialize password visibility
  }

  void setLock(bool status) {
    // print("status: $status");
    ref.read(authControllerProvider).setLock(
        context, status, widget.uid); // Use read instead of watch for actions
  }

  void _toggleChatLock() {
    if (widget.password != "") {
      if (widget.password.isNotEmpty) {
        showAlertDialogpassword(context, (inputPassword) {
          if (inputPassword == widget.password) {
            setState(() {
              _isLock = !_isLock; // Toggle lock state
              setLock(_isLock); // Update the lock state in the backend
            });
          } else {
            showSnackBar(context, 'Incorrect password. Please try again.');
          }
        });
      } else {
        showSnackBar(context, 'Please set a password first');
      }
    } else {
      showSnackBar(context, "please set password first");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 35),
        Text(
          widget.userName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          widget.phoneNumber,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Divider(),
        ListTile(
          title: Text(
            widget.description.descriptio, // Corrected variable name
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
          subtitle: Text(
              DateFormat('dd/MM/yyyy').format(widget.description.dateTime)),
        ),
        const Divider(),
        const SizedBox(height: 30),
        const _ProfileIconButtons(),
        const SizedBox(height: 20),
        _buildChatLockTile(),
        const Divider(),
        _buildNotificationTile("Disappearing messages", Icons.message),
        _buildNotificationTile("Mute Notifications", Icons.mic_off),
        _buildNotificationTile("Media visibility", Icons.save),
        const Divider(),
        _buildNotificationTile("BLOCK", Icons.block, text: Colors.greenAccent),
        const Divider(),
        const SizedBox(height: 550),
      ],
    );
  }

  ListTile _buildChatLockTile() {
    return ListTile(
      title: const Text("Chat Lock"),
      leading: const Icon(Icons.lock),
      trailing: Switch(
        value: _isLock,
        onChanged: (value) {
          _toggleChatLock(); // Call to toggle chat lock
        },
      ),
    );
  }

  ListTile _buildNotificationTile(String title, IconData icon,
      {Color text = Colors.white}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: text),
      ),
      leading: Icon(icon),
      onTap: () {},
    );
  }

  Future<void> showAlertDialogPassword(
      BuildContext context, Function(String) onPasswordSubmitted) async {
    // Use StatefulBuilder to manage the dialog state
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        String password = '';
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            obscureText: _obscureText,
            onChanged: (value) {
              password = value;
            },
            decoration: InputDecoration(
              hintText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText; // Toggle visibility
                  });
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onPasswordSubmitted(password);
                Navigator.of(context).pop(); // Close dialog after submitting
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileIconButtons extends StatelessWidget {
  const _ProfileIconButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(context, Icons.videocam, 'Video Call'),
        _buildIconButton(context, Icons.call, 'Voice Call'),
      ],
    );
  }

  Column _buildIconButton(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: appbarColor,
          child: IconButton(
            onPressed: () {
              // Implement the onPressed functionality
            },
            icon: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}
