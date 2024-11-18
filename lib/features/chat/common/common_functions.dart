import 'package:chatting_app/Common/utils/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

Future<String?> uid_getPhoneNumber(String uid) async {
  try {
    // Reference to the Firestore collection where user data is stored
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // Check if the document exists and contains a phoneNumber field
    if (userDoc.exists && userDoc.data() != null) {
      // Extract the phone number
      var name = await getnamefromphone(userDoc.data()?['phoneNumber']);
      print("koushi==${name}");
      return name == "NOT OCCUR" &&
              uid != FirebaseAuth.instance.currentUser!.uid
          ? (userDoc.data()?['phoneNumber'] as String?)
          : uid == FirebaseAuth.instance.currentUser!.uid
              ? "${name}(YOU)"
              : name;
    } else {
      print('User with uid $uid does not exist or has no phone number.');
      return null;
    }
  } catch (e) {
    print('Error fetching phone number: $e');
    return null;
  }
}

// Future<void> sendAndroidNotification() async {
//   try {
//     http.Response response = await http.post(
//       Uri.parse("hhtps://fcm.googleapis.com/fcm/send"),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Authorization': 'key=$messageKey',
//       },
//       body: jsonEncode(
//         <String, dynamic>{
//           'notification': <String, dynamic>{
//             'body': serviceName,
//             'title': 'Nueva Solicitud',
//           },
//           'priority': 'high',
//           'data': <String, dynamic>{
//             'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//             'id': '1',
//             'status': 'done'
//           },
//           'to': authorizedSupplierTokenId,
//           'token': authorizedSupplierTokenId
//         },
//       ),
//     );
//     response;
//   } catch (e) {
//     e;
//   }
// }
