import 'dart:io';

import 'package:chatting_app/Common/Screen/Error.dart';
import 'package:chatting_app/User_info/Screen/settings.dart';
import 'package:chatting_app/User_info/Screen/widget/chat_settings.dart';
import 'package:chatting_app/User_info/Screen/widget/nearby_settings.dart';
import 'package:chatting_app/User_info/Screen/widget/private_Screen.dart';
import 'package:chatting_app/User_info/Screen/user_details.dart';
import 'package:chatting_app/User_info/Screen/widget/selected_colors.dart';
import 'package:chatting_app/auth/select_contacts/screens/select_contact_screen.dart';
import 'package:chatting_app/features/Group/screens/create_group.dart';
import 'package:chatting_app/features/Status/Model/status_model.dart';
import 'package:chatting_app/features/Status/Screen/Conform_status.dart';
import 'package:chatting_app/features/Status/Screen/status_sc.dart';
import 'package:chatting_app/features/Status/Screen/status_screen.dart';
import 'package:chatting_app/features/chat/screens/mobile_chat_screen.dart';
import 'package:chatting_app/screens/mobile_layout_screen.dart';

import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case UserDetails.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;

      return MaterialPageRoute(
          builder: (context) => UserDetails(
              name: arguments["name"],
              description: arguments["description"],
              profileIMG: arguments["profileimage"],
              backgroundIMG: arguments["backgroundimage"],
              mobilenumber: arguments["mobilenumber"]));
    case PrivateSetting.routeName:

      // print("ssss${ststus}");
      final arguments = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (context) => PrivateSetting(
                privatename: arguments['privateName'],
                privateimage: arguments['privateImage'],
                isprivate: arguments['status'],
              ));
    case SelectContactPage.routeName:
      return MaterialPageRoute(builder: (context) => const SelectContactPage());
    case ConfirmStatusScreen.routeName:
      final file = settings.arguments as File;
      return MaterialPageRoute(
        builder: (context) => ConfirmStatusScreen(
          file: file,
        ),
      );

    case StatusPlayScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => StatusContactsScreen(),
      );
    case MobileLayoutScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const MobileLayoutScreen());
    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      return MaterialPageRoute(
          builder: (context) => MobileChatScreen(
                name: name,
                uid: uid,
              ));
    case NearbySettings.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final bool value = arguments['nearby'];
      final String radius = arguments['radius'];
      return MaterialPageRoute(
          builder: (context) => NearbySettings(
                ison: value,
                limint: radius,
              ));
    case CreateGroupScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const CreateGroupScreen(),
      );
    case ColorPickerScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final String Appbar = arguments['Appbar'];
      final String body = arguments['start'];
      return MaterialPageRoute(
        builder: (context) =>
            ColorPickerScreen(appbar: Appbar, background: body),
      );
    case SettingsScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      );
    case PasswordScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => PasswordScreen(
          password: arguments['passwod'],
        ),
      );

    default:
      return MaterialPageRoute(
          builder: (context) => ErrorScreen(
                error: "NO PAGE OCCUR",
              ));
  }
}
