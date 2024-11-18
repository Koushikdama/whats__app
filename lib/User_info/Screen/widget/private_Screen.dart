import 'dart:io';
import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Controller/userController.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivateSetting extends ConsumerStatefulWidget {
  static const routeName = "/user-private-screen";
  final String privateimage; // Image URL from Firebase
  final String privatename;
  final bool isprivate;

  const PrivateSetting({
    required this.privateimage,
    required this.privatename,
    required this.isprivate,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PrivateSettingsState createState() => _PrivateSettingsState();
}

class _PrivateSettingsState extends ConsumerState<PrivateSetting> {
  final TextEditingController _nameController = TextEditingController();
  String _nameError = ''; // To hold error messages for name validation
  File? _privateProfileImage; // To hold the selected profile image
  bool _isPrivate = false; // State variable for the switch
  FocusNode focusNode = FocusNode();
  bool isShowEmojiContainer = false;
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.privatename;
    _isPrivate = widget.isprivate; // Initialize from widget
  }

  @override
  void dispose() {
    _nameController.dispose(); // Dispose the controller
    super.dispose();
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

  Future<void> selectImage() async {
    File? selectedImage = await pickImageFromGallery(context);
    if (selectedImage != null) {
      setState(() {
        _privateProfileImage = selectedImage; // Update profile image
      });
    } else {
      showSnackBar(context, "Image selection canceled or failed.");
    }
  }

  void savedata() async {
    String privateName = _nameController.text;
    File? privateImage =
        _privateProfileImage; // Use the selected image if available
    ref.read(authControllerProvider).saveprivatedetails(
        'privatesettings', context, privateName, privateImage, _isPrivate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Private Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              if (_nameController.text.isEmpty) {
                setState(() {
                  _nameError = 'Please enter a private name.';
                });
              } else if (_nameController.text.length > 30) {
                setState(() {
                  _nameError = 'Name cannot exceed 30 characters.';
                });
              } else {
                savedata();
                //Navigator.pop(context); // Navigate back to the previous screen
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Private Setting'),
              leading: Switch(
                value: _isPrivate,
                onChanged: (bool value) {
                  setState(() {
                    _isPrivate = value; // Update the switch state
                  });
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _privateProfileImage != null
                          ? FileImage(_privateProfileImage!)
                          : (widget.privateimage.isNotEmpty
                              ? NetworkImage(widget.privateimage)
                              : const AssetImage(
                                  'assets/animation/ch.e.s.s.jpeg',
                                ) as ImageProvider<Object>),
                    ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        onPressed: selectImage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        labelText: 'Private Name',
                        border: const OutlineInputBorder(),
                        errorText: _nameError.isEmpty ? null : _nameError,
                        suffixIcon: IconButton(
                            onPressed: toggleEmojiKeyboardContainer,
                            icon: const Icon(Icons.emoji_emotions_outlined))),
                    maxLength: 30,
                    onChanged: (value) {
                      setState(() {
                        _nameError = ''; // Clear error when user types
                      });
                    },
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_nameController.text.length}/30',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  // Implement 'See Seen' functionality here
                },
                child: const Text('See Seen'),
              ),
            ),
            isShowEmojiContainer
                ? SizedBox(
                    height: 310,
                    child: EmojiPicker(
                      onEmojiSelected: ((category, emoji) {
                        setState(() {
                          _nameController.text =
                              _nameController.text + emoji.emoji;
                        });
                      }),
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
