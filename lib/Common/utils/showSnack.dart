import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String text) {
  // print("showsnack ${text}");
  try {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  } catch (e) {
    print(e.toString());
  }
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final PickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (PickedImage != null) {
      image = File(PickedImage.path);
    }
  } catch (e) {
    showSnackBar(context, e.toString());
  }
  return image;
}

Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? image;
  try {
    final PickedImage =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (PickedImage != null) {
      image = File(PickedImage.path);
    }
  } catch (e) {
    showSnackBar(context, e.toString());
  }
  return image;
}
// pickedGIF(BuildContext context) async {
//   // VMk483Lr52LZYERr5SApBKUZdJzbMSWW
//   GiphyGif? gif;
//   try {
//     gif = await Giphy.getGif(
//         context: context, apiKey: "VMk483Lr52LZYERr5SApBKUZdJzbMSWW");
//   } catch (e) {
//     showSnackBar(context, e.toString());
//   }
//   return gif;
// }
