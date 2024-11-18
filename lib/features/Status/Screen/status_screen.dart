import 'dart:async';
import 'package:chatting_app/Common/utils/functions.dart';
import 'package:chatting_app/features/Status/Controller/status_controller.dart';
import 'package:chatting_app/features/Status/Model/status_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class StatusPlayScreen extends ConsumerStatefulWidget {
  static const String routeName = '/play-status-screen';
  final List<Media> mediaList;
  final bool isCurrentUser;
  final Status userinfo;

  StatusPlayScreen({
    required this.mediaList,
    required this.isCurrentUser,
    required this.userinfo,
  });

  @override
  _StatusPlayScreenState createState() => _StatusPlayScreenState();
}

class _StatusPlayScreenState extends ConsumerState<StatusPlayScreen> {
  int currentIndex = 0;
  int showcurrentIndex = 0;
  bool isPlaying = true;
  bool captionInCenter = false;
  late Timer timer;
  double progress = 0;
  bool showSlideBox = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    int lastIndex = currentIndex; // Track the last seen index

    timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        // Check if the currentIndex has changed
        if (currentIndex == lastIndex) {
          ref
              .watch(statusControllerProvider)
              .updatedseen(widget.userinfo.uid, currentIndex);
          lastIndex++; // Update the last seen index
        }

        // Update progress for the media
        progress += 0.01;
        if (progress >= 1) {
          progress = 0;
          nextMedia();
        }
      });
    });
  }

  void pauseTimer() {
    timer.cancel();
    setState(() {
      isPlaying = false;
    });
  }

  void resumeTimer() {
    startTimer();
    setState(() {
      isPlaying = true;
    });
  }

  void nextMedia() {
    if (currentIndex < widget.mediaList.length - 1) {
      setState(() {
        currentIndex++;
        progress = 0;
        captionInCenter = false;
      });
    } else {
      Navigator.pop(context); // End of status
    }
  }

  void previousMedia() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        progress = 0;
        captionInCenter = false;
      });
    }
  }

  void toggleSlideBox() {
    setState(() {
      showSlideBox = !showSlideBox;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMedia = widget.mediaList[currentIndex];
    final uploadTime = DateFormat('hh:mm').format(currentMedia.uploadAt);

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onDoubleTap: () {
              isPlaying ? pauseTimer() : resumeTimer();
            },
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < -20) {
                toggleSlideBox();
              }
            },
            onTapDown: (details) {
              final width = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < width / 2) {
                previousMedia();
              } else {
                nextMedia();
              }
            },
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(3),
                  image: DecorationImage(
                    image: NetworkImage(currentMedia.mediaUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: currentMedia.mediaType == "text"
                    ? Center(
                        child: Text(
                          currentMedia.mediaType,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 24),
                        ),
                      )
                    : currentMedia.mediaType == "video"
                        ? const Center(
                            child: Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 100,
                            ),
                          )
                        : Container(),
              ),
            ),
          ),

          // Profile section showing who uploaded the status and upload time
          Positioned(
            top: 40,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.userinfo.profilePic),
                      radius: 20,
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        widget.userinfo.username,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
                Text(
                  ' $uploadTime',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Exit icon to close the screen
          Positioned(
            top: 40,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Caption for the media, with animated positioning
          AnimatedPositioned(
            bottom:
                captionInCenter ? MediaQuery.of(context).size.height / 2 : 150,
            left: 10,
            right: 10,
            duration: const Duration(milliseconds: 500),
            child: Center(
              child: Text(
                currentMedia.caption,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

          // Progress bars at the top for each media item
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Row(
              children: widget.mediaList.map((media) {
                int index = widget.mediaList.indexOf(media);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: LinearProgressIndicator(
                      value: index == currentIndex
                          ? progress
                          : (index < currentIndex ? 1 : 0),
                      backgroundColor: Colors.grey,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Reply text field for non-current user with sender icon
          if (!widget.isCurrentUser)
            Positioned(
              bottom: 50,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(currentMedia.mediaUrl),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Reply...",
                        hintStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onTap: () {
                        setState(() {
                          captionInCenter = true;
                        });
                      },
                      onSubmitted: (reply) {
                        pauseTimer();
                        setState(() {
                          captionInCenter = false;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        captionInCenter = false;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Slideable box for current user
          if (widget.isCurrentUser)
            Positioned(
              bottom: 50,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.keyboard_arrow_up,
                    size: 40, color: Colors.white),
                onPressed: toggleSlideBox,
              ),
            ),

          if (showSlideBox)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                color: Colors.black54,
                child: Center(
                  child: ListView.builder(
                    itemCount: widget.userinfo.media[currentIndex].viewers
                        .length, // Number of users
                    itemBuilder: (context, index) {
                      var userdata =
                          widget.userinfo.media[currentIndex].viewers[index];

                      if (currentIndex == showcurrentIndex) {
                        print(
                            "if @@@@@@@@@@@@@@@@@userdata${userdata.username}");
                        showcurrentIndex++;
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            userdata.profile,
                          ),
                        ),
                        title: Text(
                            userdata.username), // Sample name for each user
                        subtitle: Text(convertTimestampToDateString(
                            userdata.viewedAt,
                            test: "status")), // Sample time
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
