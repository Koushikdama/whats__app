import 'dart:io';
import 'package:chatting_app/Common/utils/Colors.dart';
import 'package:chatting_app/Common/utils/showAlert.dart';
import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Controller/userController.dart';
import 'package:chatting_app/User_info/Screen/settings.dart';
import 'package:chatting_app/auth/select_contacts/screens/select_contact_screen.dart';
import 'package:chatting_app/colors.dart';
import 'package:chatting_app/features/Group/screens/create_group.dart';
import 'package:chatting_app/features/Status/Screen/Conform_status.dart';
import 'package:chatting_app/features/Status/Screen/status_sc.dart';
import 'package:chatting_app/features/chat/controller/chat_controller.dart';
import 'package:chatting_app/features/chat/screens/contacts_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  const MobileLayoutScreen({super.key});
  static const String routeName = "/starting-page";

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late bool status = false; // Initialize status
  late TabController tabBarController;
  Color appBarColor = Colors.yellow; // Default AppBar color
  Color startGradientColor = Colors.black; // Default start gradient color
  Color endGradientColor = Colors.black; // Default end gradient color

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tabBarController = TabController(length: 3, vsync: this);
    _loadUserTheme();
  }

  @override
  void dispose() {
    tabBarController.dispose(); // Dispose the TabController properly
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final authController =
        ref.read(authControllerProvider); // Read auth controller once
    switch (state) {
      case AppLifecycleState.resumed:
        authController.setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        authController.setUserState(false);
        setState(() {
          status = false;
        });
        break;
      default:
        authController.setUserState(false);
        break;
    }
  }

  void change(BuildContext context) {
    // Check the current status before toggling
    if (!status) {
      showAlertDialogpassword(context, (String password) async {
        if (password.isNotEmpty) {
          // If password is not empty, perform the necessary actions
          bool isCorrect =
              await ref.watch(authControllerProvider).iscorrect(password);

          if (isCorrect) {
            // Use the password as needed
            ref.read(chatcontroller).chatContact(status: !status);
            ref.read(authControllerProvider).setprivatestate(!status);

            setState(() {
              status = !status; // Change the status to true
            });
          } else {
            showSnackBar(context, "Incorrect password.");
          }
        } else {
          // Handle the case when the password is empty (user clicked cancel)
          // print("User canceled the operation or did not enter a password.");
        }
      });
    } else {
      // If status is true, just toggle the status without showing the dialog
      ref.read(chatcontroller).chatContact(status: status);
      ref.read(authControllerProvider).setprivatestate(!status);
      setState(() {
        status = !status; // Toggle the status
      });
    }
  }

  void _loadUserTheme() async {
    UserTheme? userTheme = await fetchUserTheme();
    if (userTheme != null) {
      setState(() {
        appBarColor = userTheme.appBarColor;
        startGradientColor = userTheme.bodyColor;
        endGradientColor = userTheme.endBodyColor;
      });
      // Use the colors in your app
      print("AppBar Color: ${userTheme.appBarColor}");
      print("Body Color: ${userTheme.bodyColor}");
      print("End Body Color: ${userTheme.endBodyColor}");
    } else {
      print('Failed to load user theme');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [startGradientColor, endGradientColor])),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: appBarColor,
            centerTitle: false,
            title: InkWell(
              onDoubleTap: () => change(context),
              child: Text(
                'WhatsApp ',
                style: TextStyle(
                  fontSize: 20,
                  color: status
                      ? tabColor
                      : Colors.white70, // Change color based on status
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white70),
                onPressed: () {},
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text("Create Group"),
                    onTap: () {
                      Navigator.pushNamed(context, CreateGroupScreen.routeName);
                    },
                  ),
                  PopupMenuItem(
                    child: const Text("Settings"),
                    onTap: () {
                      Navigator.pushNamed(context, SettingsScreen.routeName);
                    },
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              controller: tabBarController,
              indicatorColor: tabColor,
              indicatorWeight: 5,
              labelColor: tabColor,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(
                  text: 'CHATS',
                ),
                Tab(
                  text: 'STATUS',
                ),
                Tab(
                  text: 'CALLS',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: tabBarController,
            children: [
              ContactsList(status),
              const StatusContactsScreen(),
              const Text("CALLS"),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (tabBarController.index == 0) {
                Navigator.pushNamed(context, SelectContactPage.routeName);
              } else {
                File? pickedImage = await pickImageFromGallery(context);
                if (pickedImage != null) {
                  Navigator.pushNamed(
                    context,
                    ConfirmStatusScreen.routeName,
                    arguments: pickedImage,
                  );
                }
              }
            },
            backgroundColor: tabColor,
            child: const Icon(
              Icons.comment,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
