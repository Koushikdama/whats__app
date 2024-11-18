// ignore_for_file: file_names

import 'dart:io';
import 'package:chatting_app/User_info/Model/UserModel.dart';

import 'package:chatting_app/User_info/Repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = Provider((ref) {
  print("user controller");
  final authRepository = ref.watch(authRepositoryProvider);

  return Usercontroller(authRepository: authRepository, ref: ref);
});
final userDataAuthprovider = FutureProvider((ref) {
  final authcontroller = ref.watch(authControllerProvider);
  print("authcontroller.getuserData()+++${authcontroller.getuserData()}");
  return authcontroller.getuserData();
});

class Usercontroller {
  final AuthRepository authRepository;
  final ProviderRef ref;

  Usercontroller({
    required this.authRepository,
    required this.ref,
  });
  void saveUserDataToFirebase({
    required BuildContext context,
    required String name,
    required File? profilePic,
    required String description,
    required File? bgimage,
    required String mobilenumber,
  }) {
    print("cantroller called");
    authRepository.saveUserDataToFirebase(
      description: description,
      name: name,
      profilePic: profilePic,
      ref: ref,
      context: context,
      bgimage: bgimage,
      mobilenumber: mobilenumber,
    );
  }

  void saveprivatedetails(String updated, BuildContext context,
      String privatename, File? privateimage, bool status) {
    authRepository.savePrivateDetails(
        updated: updated,
        name: privatename,
        image: privateimage,
        ref: ref,
        context: context,
        isPrivateValue: status);
  }

  void saveuserlocation(BuildContext context, double latitude, double longitude,
      int radius, bool nearby) {
    authRepository.updateLocation(
        nearby: nearby,
        radius: radius,
        latitude: latitude,
        longitude: longitude,
        ref: ref,
        context: context);
  }

  void saveprofiledetails({
    required BuildContext context,
    required String name,
    required String profilePic,
    required String description,
    required String bgimage,
    required String mobilenumber,
  }) {
    authRepository.updateprofile(
      context: context,
      name: name,
      bgimage: bgimage,
      profilePic: profilePic,
      description: description,
      mobilenumber: mobilenumber,
    );
  }

  Future<UserProfile?> getuserData() async {
    UserProfile? user = await authRepository.getCurrentuserData();
    return user;
  }

  Stream<UserProfile> userDataById(String userid) {
    // print("authRepository.userData(userid)${authRepository.userData(userid)}");
    return authRepository.userData(userid);
  }

  void setUserState(bool isonline) {
    authRepository.setUserState(isonline);
  }

  void setprivatestate(bool isprivate) {
    authRepository.setisPrivate(isprivate);
  }

  void setLock(BuildContext context, bool islock, String uid) {
    authRepository.lockStatus(context, islock, uid);
  }

  void updatelock({required BuildContext context, required String password}) {
    authRepository.updatelock(context: context, password: password);
  }

  Future<friendprofile?> getprofiledetails(BuildContext context, String uid) {
    print(
        "controller getprofiledetails call${authRepository.fetchProfileDetails(context, uid)}");
    return authRepository.fetchProfileDetails(context, uid);
  }
  // Stream<UserProfile?> getprofiledetails(String uid) {
  //   // print("controller getprofiledetails call");
  //   print(
  //       "authRepository.fetchProfileDetails(uid);----${authRepository.fetchProfileDetails(uid)}");
  //   return authRepository.fetchProfileDetails(uid);
  // }

  Future<bool> iscorrect(String password) {
    return authRepository.getPasswordAttribute(password);
  }

  void updatebg(String appbar, String body) {
    print("controller bg");
    return authRepository.setbackground(appbar, body);
  }
}
