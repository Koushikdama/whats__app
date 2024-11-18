import 'dart:io';
import 'package:chatting_app/User_info/Controller/userController.dart';
import 'package:chatting_app/features/Status/Model/status_model.dart';
import 'package:chatting_app/features/Status/Repository/status_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final statusControllerProvider = Provider((ref) {
  final statusRepository = ref.read(statusRepositoryProvider);
  return StatusController(
    statusRepository: statusRepository,
    ref: ref,
  );
});

class StatusController {
  final StatusRepository statusRepository;
  // ignore: deprecated_member_use
  final ProviderRef ref;
  StatusController({
    required this.statusRepository,
    required this.ref,
  });

  void addStatus(
      File file, BuildContext context, String caption, List<String> tagusers) {
    ref.watch(userDataAuthprovider).whenData((value) {
      print("controller");
      statusRepository.uploadStatus(
          username: value!.firstName,
          profilePic: value.profile,
          phoneNumber: value.phoneNumber,
          statusImage: file,
          context: context,
          caption: caption,
          tagusers: tagusers);
    });
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statuses = await statusRepository.getStatus(context);
    return statuses;
  }

  Future<void> updatedseen(String uid, int index) async {
    await statusRepository.addViewerToMedia(mediaIndex: index, userId: uid);
  }
}
