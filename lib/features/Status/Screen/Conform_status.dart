import 'dart:io';
import 'package:chatting_app/features/Status/Common/get_coordinate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatting_app/colors.dart';
import 'package:chatting_app/features/Status/Controller/status_controller.dart';

// Provider for managing the visibility of the sliding panel
final panelVisibilityProvider = StateProvider<bool>((ref) => false);

// Provider for managing the list of selected user IDs
final selectedUserIdsProvider = StateProvider<List<String>>((ref) => []);
final selectedUserNamesProvider = StateProvider<List<Map<String, String>>>(
    (ref) => []); // Storing selected user info

class ConfirmStatusScreen extends ConsumerStatefulWidget {
  static const String routeName = '/confirm-status-screen';
  final File file;

  const ConfirmStatusScreen({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  _ConfirmStatusScreenState createState() => _ConfirmStatusScreenState();
}

class _ConfirmStatusScreenState extends ConsumerState<ConfirmStatusScreen> {
  // Initialize the TextEditingController and other state variables
  final TextEditingController _text = TextEditingController();

  // Declare the users list as a state variable
  List<Map<String, dynamic>> users = [];
  List<String> tagusers = [];
  // Toggle the visibility of the user selection panel
  void togglePanelVisibility(WidgetRef ref, bool isPanelVisible) {
    ref.read(panelVisibilityProvider.notifier).state = !isPanelVisible;
  }

  // Add status function
  void addStatus(
    WidgetRef ref,
    BuildContext context,
    String caption,
  ) {
    // if (tagusers.isNotEmpty) {
    //   for (String user in tagusers) {
    //     ref
    //         .read(chatcontroller)
    //         .sendMessage(context, "STATUS POSTED", user, ref);
    //   }
    // }
    print("taguser${tagusers}");

    ref
        .read(statusControllerProvider)
        .addStatus(widget.file, context, caption, tagusers);
    setState(() {
      ref.read(selectedUserIdsProvider.notifier).state = [];
      ref.read(selectedUserNamesProvider.notifier).state = [];
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    // Fetch the friend details asynchronously
    fetchFriendDetails().then((fetchedUsers) {
      setState(() {
        users = fetchedUsers; // Update the users list with fetched data
      });
    });
  }

  void toggleUserSelection(String userId) {
    print("users selected users${users}");
    final selectedUserIds = ref.read(selectedUserIdsProvider);
    final selectedUserNames = ref.read(selectedUserNamesProvider);
    final updatedList = List<String>.from(selectedUserIds);
    final updatedNames = List<Map<String, String>>.from(selectedUserNames);

    // Toggle the user selection
    if (updatedList.contains(userId)) {
      updatedList.remove(userId);
      updatedNames.removeWhere(
          (user) => user['id'] == userId); // Remove user from the list
    } else {
      updatedList.add(userId);

      // Convert dynamic Map<String, dynamic> to Map<String, String> before adding
      final user = users.firstWhere((user) => user['id'] == userId);
      updatedNames.add({
        'id': user['id']?.toString() ?? '',
        'profile': user['profile']?.toString() ?? '',
        'name': user['NAME']?.toString() ?? '',
      }); // Add selected user with proper type conversion
    }

    ref.read(selectedUserIdsProvider.notifier).state = updatedList;
    ref.read(selectedUserNamesProvider.notifier).state =
        updatedNames; // Update selected user info
  }

  void showlist() {
    setState(() {
      tagusers.addAll(ref.read(selectedUserIdsProvider).toSet().toList());
    });
    print(
        "updated list ${ref.read(selectedUserIdsProvider)} %%%%% ${tagusers}");
    togglePanelVisibility(ref, ref.watch(panelVisibilityProvider));
  }

  @override
  void dispose() {
    super.dispose();
    _text.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive design using MediaQuery
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final isPanelVisible = ref.watch(panelVisibilityProvider);
    final selectedUserIds = ref.watch(selectedUserIdsProvider);
    final selectedUserNames = ref.watch(selectedUserNamesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text('Confirm Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tag, color: Colors.white),
            onPressed: () => togglePanelVisibility(ref, isPanelVisible),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Post image displayed in full screen with square shape and margin
          Center(
            child: Container(
              margin: const EdgeInsets.only(
                  left: 9, right: 9, top: 10), // Adding space around the image
              width: screenWidth - 20, // Full width minus margins
              height: screenWidth -
                  0.01, // Keeping the height equal to width to maintain a square shape
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    10), // Optional: add rounded corners to the image
                child: Image.file(
                  widget.file,
                  fit: BoxFit.cover, // Ensure the image covers the square space
                ),
              ),
            ),
          ),
          // Display panel if visible
          if (isPanelVisible) ...[
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: screenHeight * 0.4, // 40% height
                color: Colors.white,
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    bool isSelected = selectedUserIds.contains(user['id']);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user['profile']!),
                      ),
                      title: Text(user['NAME']!),
                      trailing: IconButton(
                        icon: Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected ? Colors.green : Colors.grey,
                        ),
                        onPressed: () => toggleUserSelection(user['id']!),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          // Display selected users' names and profiles on the post
          Positioned(
            bottom: screenHeight * 0.2, // Adjust position above the caption
            left: 20,
            right: 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: selectedUserNames.isNotEmpty
                  ? Wrap(
                      spacing: 10,
                      runSpacing:
                          10, // Ensures the users are spaced vertically if necessary
                      children: selectedUserNames.map((user) {
                        return Row(
                          children: isPanelVisible == false
                              ? [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        NetworkImage(user['profile']!),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    user['name']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ]
                              : [],
                        );
                      }).toList(),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          // Transparent TextField for Caption
          Positioned(
            bottom: screenHeight * 0.05, // Adjust position for caption
            left: 20,
            right: 20,
            child: Visibility(
              visible: !isPanelVisible, // Only show when panel is not visible
              child: TextField(
                controller: _text,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Add a caption...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.done, color: Colors.white),
        onPressed: isPanelVisible
            ? () => showlist()
            : () => addStatus(
                ref, context, _text.text.trim() == "" ? "" : _text.text),
        backgroundColor: tabColor,
      ),
    );
  }
}
