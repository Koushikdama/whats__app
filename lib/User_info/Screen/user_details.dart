// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatting_app/Common/Repository/commonFirebase.dart';
import 'package:chatting_app/Common/utils/showAlert.dart';
import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Controller/userController.dart';
import 'package:chatting_app/User_info/Model/UserModel.dart';

// ignore: must_be_immutable
class UserDetails extends ConsumerStatefulWidget {
  static const routeName = "/user-details-screen";
  String name;
  String description;
  String profileIMG;
  String backgroundIMG;
  String mobilenumber;

  UserDetails({
    required this.name,
    required this.description,
    required this.profileIMG,
    required this.backgroundIMG,
    required this.mobilenumber,
  });

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends ConsumerState<UserDetails> {
  bool isShowEmojiContainer = false;
  bool isRecording = false;
  FocusNode focusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  File? profileImage;
  File? backgroundImage;
  Color color = Colors.grey;
  Country? country;
  String profileurl = "";
  String backgroundurl = "";

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _descriptionController.addListener(() => setState(() {}));
    _phoneNumberController.addListener(() => setState(() {}));
    backgroundurl = widget.backgroundIMG;
    profileurl = widget.profileIMG;
    _nameController.text = widget.name;
    _descriptionController.text = widget.description;
    _phoneNumberController.text = widget.mobilenumber;
  }

  Future<UserProfile?> fetchUserData(String uid) async {
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

  void pickercountry() {
    showCountryPicker(
      context: context,
      onSelect: (Country country) {
        setState(() {
          this.country = country;
        });
      },
    );
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  Future<void> selectImage(String type) async {
    File? selectedImage = await pickImageFromGallery(context);
    if (selectedImage != null) {
      setState(() {
        if (type == "PROFILE") {
          profileurl = "";
          profileImage = selectedImage;
        } else if (type == "BACKGROUND_IMAGE") {
          backgroundurl = "";
          backgroundImage = selectedImage;
          color = Colors.white70;
        }
      });
    } else {
      showSnackBar(context, "Image selection canceled or failed.");
    }
  }

  void savedata(BuildContext context) async {
    // Check if profileImage and backgroundImage are not null
    if (profileImage == null && profileurl == "") {
      showSnackBar(context, "Please select a profile image.");
      return;
    }

    if (backgroundImage == null && backgroundurl == "") {
      showSnackBar(context, "Please select a background image.");
      return;
    }

    try {
      String profileurl = profileImage != null
          ? await ref
              .watch(commonFirebaseStorageRepositoryProvider)
              .storeFileToFirebase(
                  'profilePic/${FirebaseAuth.instance.currentUser!.uid}',
                  profileImage!)
          : backgroundurl;

      String bgurl = backgroundImage != null
          ? await ref
              .watch(commonFirebaseStorageRepositoryProvider)
              .storeFileToFirebase(
                  'profilePic/${FirebaseAuth.instance.currentUser!.uid}',
                  backgroundImage!)
          : backgroundurl;

      // Check if text fields are not empty
      if (_nameController.text.trim().isNotEmpty &&
          _descriptionController.text.trim().isNotEmpty &&
          _phoneNumberController.text.trim().isNotEmpty) {
        ref.watch(authControllerProvider).saveprofiledetails(
            context: context,
            name: _nameController.text,
            profilePic: profileurl,
            description: _descriptionController.text,
            bgimage: bgurl,
            mobilenumber: _phoneNumberController.text);
      } else {
        showSnackBar(context, "Please fill in all fields correctly.");
      }
    } catch (e) {
      showSnackBar(context, "Error uploading images: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        actions: [
          IconButton(
            onPressed: () => savedata(context),
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: backgroundImage != null || backgroundurl != ""
              ? DecorationImage(
                  image: backgroundurl == ""
                      ? FileImage(backgroundImage!)
                      : NetworkImage(backgroundurl),
                  fit: BoxFit.cover,
                )
              : null,
          color: backgroundImage == null && backgroundurl == ""
              ? Theme.of(context).scaffoldBackgroundColor
              : null,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          profileImage == null && profileurl == ""
                              ? GestureDetector(
                                  onTap: () => selectImage("PROFILE"),
                                  child: CircleAvatar(
                                    radius: screenWidth * 0.15,
                                    backgroundImage: const AssetImage(
                                        "assets/images/empty_image.jpg"),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () =>
                                      showAlertDialog(context, profileImage!),
                                  child: CircleAvatar(
                                    radius: screenWidth * 0.15,
                                    backgroundImage: profileurl == ""
                                        ? FileImage(profileImage!)
                                        : NetworkImage(profileurl),
                                  ),
                                ),
                          Positioned(
                            left: 70,
                            bottom: -10,
                            child: IconButton(
                              onPressed: () => selectImage("PROFILE"),
                              icon: const Icon(Icons.add_a_photo),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name (max 30 characters)',
                        border: const OutlineInputBorder(),
                        counterText: '${_nameController.text.length}/30',
                        suffix: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.emoji_emotions_outlined),
                        ),
                      ),
                      maxLength: 30,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (max 30 characters)',
                        border: const OutlineInputBorder(),
                        counterText: '${_descriptionController.text.length}/30',
                        suffix: IconButton(
                          onPressed: toggleEmojiKeyboardContainer,
                          icon: const Icon(Icons.emoji_emotions_outlined),
                        ),
                      ),
                      maxLength: 30,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number (10 digits)',
                        border: const OutlineInputBorder(),
                        counterText: '${_phoneNumberController.text.length}/10',
                        prefixIcon: IconButton(
                          onPressed: pickercountry,
                          icon: country != null
                              ? Text("+${country!.phoneCode}")
                              : const Text("+91"),
                        ),
                      ),
                      maxLength: 10,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number.';
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return 'Please enter numbers only.';
                        }
                        if (value.length != 10) {
                          return 'Please enter a valid 10-digit phone number.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          "Select background image",
                          style: TextStyle(color: Colors.black38, fontSize: 15),
                        ),
                        SizedBox(width: screenWidth * 0.25),
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: screenWidth * 0.1,
                              backgroundImage: backgroundurl == ""
                                  ? backgroundImage != null
                                      ? FileImage(backgroundImage!)
                                      : const AssetImage(
                                          "assets/images/empty_image.jpg")
                                  : NetworkImage(backgroundurl),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () =>
                                    selectImage("BACKGROUND_IMAGE"),
                                icon: const Icon(Icons.add_a_photo),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    isShowEmojiContainer
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: EmojiPicker(
                              onEmojiSelected: ((category, emoji) {
                                setState(() {
                                  _descriptionController.text =
                                      _descriptionController.text + emoji.emoji;
                                });
                              }),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
