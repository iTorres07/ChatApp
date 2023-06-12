import 'dart:async';

import 'package:bubble/bubble.dart';
import 'package:chat_app_1/features/group/domain/entities/group_entity.dart';
import 'package:chat_app_1/features/group/domain/entities/single_chat_entity.dart';
import 'package:chat_app_1/features/group/domain/entities/text_message_entity.dart';
import 'package:chat_app_1/features/group/presentation/cubits/chat/chat_cubit.dart';
import 'package:chat_app_1/features/group/presentation/cubits/group/group_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:intl/intl.dart';

class SingleChatPage extends StatefulWidget {
  final SingleChatEntity singleChatEntity;

  const SingleChatPage({Key? key, required this.singleChatEntity})
      : super(key: key);

  @override
  State<SingleChatPage> createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> {
  File? _selectedImage;
  File? _selectedVideo;
  File? _selectedAudio;

  VideoPlayerController? _videoPlayerController;

  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;
  TextEditingController _messageController = TextEditingController();

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    BlocProvider.of<ChatCubit>(context)
        .getMessages(channelId: widget.singleChatEntity.groupId);
    _messageController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.singleChatEntity.groupName}"),
      ),
      body: Stack(
        children: [
          SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Image.asset(
                "assets/background_wallpaper.png",
                fit: BoxFit.cover,
              )),
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, chatState) {
              if (chatState is ChatLoaded) {
                final messages = chatState.messages;
                return Column(
                  children: [
                    _messageListWidget(messages),
                    _sendMessageTextField(),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  Widget _messageLayout({
    required String text,
    required String time,
    required Color color,
    required TextAlign align,
    required CrossAxisAlignment boxAlign,
    required CrossAxisAlignment crossAlign,
    required String name,
    required TextAlign alignName,
    required BubbleNip nip,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.90,
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(3),
            child: Bubble(
              color: color,
              nip: nip,
              child: Column(
                crossAxisAlignment: crossAlign,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$name",
                    textAlign: alignName,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    text,
                    textAlign: align,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    time,
                    textAlign: align,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(
                        .4,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  _sendMessageTextField() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(80)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.2),
                      offset: const Offset(0.0, 0.50),
                      spreadRadius: 1,
                      blurRadius: 1,
                    )
                  ]),
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 60),
                      child: Scrollbar(
                        child: TextField(
                          style: const TextStyle(fontSize: 14),
                          controller: _messageController,
                          maxLines: null,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Type a message"),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            color: Colors.green,
          ),
          IconButton(
            onPressed: _pickVideo,
            icon: const Icon(Icons.videocam),
            color: Colors.green,
          ),
          IconButton(
            onPressed: _pickAudio,
            icon: const Icon(Icons.audiotrack),
            color: Colors.green,
          ),
          InkWell(
            onTap: () {
              if (_selectedImage != null) {
                // Enviar imagen
                _sendImageMessage();
              } else if (_selectedVideo != null) {
                // Enviar video
                _sendVideoMessage();
              } else if (_selectedAudio != null) {
                // Enviar audio
                _sendAudioMessage();
              } else if (_messageController.text.isNotEmpty) {
                // Enviar mensaje de texto
                _sendTextMessage();
              }
            },
            child: Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: Icon(
                _messageController.text.isEmpty &&
                        _selectedAudio.toString().isEmpty &&
                        _selectedImage.toString().isEmpty &&
                        _selectedVideo.toString().isEmpty
                    ? Icons.mic
                    : Icons.send,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _clear() {
    setState(() {
      _messageController.clear();
      _selectedImage = null;
      _selectedVideo = null;
      _selectedAudio = null;
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
    });
  }

  _messageListWidget(List<TextMessageEntity> messages) {
    if (_scrollController.hasClients) {
      Timer(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      });
    }

    return Expanded(
      child: ListView.builder(
        itemCount: messages.length,
        controller: _scrollController,
        itemBuilder: (BuildContext context, int index) {
          final singleMessage = messages[index];

          if (singleMessage.senderId == widget.singleChatEntity.uid) {
            return _messageLayout(
              name: "Me",
              alignName: TextAlign.end,
              color: Colors.lightGreen,
              time: DateFormat('hh:mm a').format(singleMessage.time!.toDate()),
              align: TextAlign.left,
              nip: BubbleNip.rightTop,
              boxAlign: CrossAxisAlignment.start,
              crossAlign: CrossAxisAlignment.end,
              text: singleMessage.content!,
              content: _buildMessageContent(singleMessage),
            );
          } else {
            return _messageLayout(
              color: Colors.white,
              nip: BubbleNip.leftTop,
              name: "${singleMessage.senderName}",
              alignName: TextAlign.end,
              time: DateFormat('hh:mm a').format(singleMessage.time!.toDate()),
              align: TextAlign.left,
              boxAlign: CrossAxisAlignment.start,
              crossAlign: CrossAxisAlignment.start,
              text: singleMessage.content!,
              content: _buildMessageContent(singleMessage),
            );
          }
        },
      ),
    );
  }

  Widget _buildMessageContent(TextMessageEntity message) {
    if (message.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: message.imageUrl!,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else if (message.videoUrl != null) {
      return _buildVideoPlayer(message.videoUrl!);
    } else if (message.audioUrl != null) {
      return _buildAudioPlayer(message.audioUrl!);
    } else {
      return Text(message.content!);
    }
  }

  Widget _buildVideoPlayer(String videoUrl) {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        child: VideoPlayer(_videoPlayerController!),
      );
    } else {
      return GestureDetector(
        onTap: () {
          _videoPlayerController = VideoPlayerController.network(videoUrl)
            ..initialize().then((_) {
              setState(() {
                _videoPlayerController!.play();
              });
            });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 500,
              height: 500,
              color: Colors.black,
            ),
            const Icon(Icons.play_arrow, color: Colors.white, size: 60),
          ],
        ),
      );
    }
  }

  Widget _buildAudioPlayer(String audioUrl) {
    final audioPlayer = AudioPlayer();

    return IconButton(
      onPressed: () {
        audioPlayer.play(UrlSource(audioUrl));
      },
      icon: const Icon(Icons.play_arrow),
    );
  }

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedVideo = await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      setState(() {
        _selectedVideo = File(pickedVideo.path);
        _videoPlayerController = VideoPlayerController.file(_selectedVideo!)
          ..initialize();
      });
    }
  }

  Future<void> _pickAudio() async {
    final pickedAudio = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'], // Extensiones permitidas
    );

    if (pickedAudio != null) {
      setState(() {
        _selectedAudio = File(pickedAudio.files.single.name);
      });
    }
  }

  Future<void> _sendImageMessage() async {
    final ref = _storage
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = ref.putFile(_selectedImage!);

    await uploadTask.whenComplete(() => null);

    final imageUrl = await ref.getDownloadURL();

    BlocProvider.of<ChatCubit>(context)
        .sendTextMessage(
            textMessageEntity: TextMessageEntity(
                time: Timestamp.now(),
                content: imageUrl,
                senderName: widget.singleChatEntity.username,
                senderId: widget.singleChatEntity.uid,
                type: "TEXT"),
            channelId: widget.singleChatEntity.groupId)
        .then((value) {
      BlocProvider.of<GroupCubit>(context).updateGroup(
          groupEntity: GroupEntity(
        groupId: widget.singleChatEntity.groupId,
        lastMessage: _messageController.text,
        createAt: Timestamp.now(),
      ));
      _clear();
    });

    // Limpiar la selección de archivos
    _clear();
  }

  Future<void> _sendVideoMessage() async {
    final ref = _storage
        .ref()
        .child('videos/${DateTime.now().millisecondsSinceEpoch}.mp4');
    final uploadTask = ref.putFile(_selectedVideo!);

    await uploadTask.whenComplete(() => null);

    final videoUrl = await ref.getDownloadURL();

    BlocProvider.of<ChatCubit>(context)
        .sendTextMessage(
            textMessageEntity: TextMessageEntity(
                time: Timestamp.now(),
                content: videoUrl,
                senderName: widget.singleChatEntity.username,
                senderId: widget.singleChatEntity.uid,
                type: "VIDEO"),
            channelId: widget.singleChatEntity.groupId)
        .then((value) {
      BlocProvider.of<GroupCubit>(context).updateGroup(
          groupEntity: GroupEntity(
        groupId: widget.singleChatEntity.groupId,
        lastMessage: _messageController.text,
        createAt: Timestamp.now(),
      ));
      _clear();
    });
  }

  Future<void> _sendAudioMessage() async {
    final ref = _storage
        .ref()
        .child('audios/${DateTime.now().millisecondsSinceEpoch}.m4a');
    final uploadTask = ref.putFile(_selectedAudio!);

    await uploadTask.whenComplete(() => null);

    final audioUrl = await ref.getDownloadURL();

    BlocProvider.of<ChatCubit>(context)
        .sendTextMessage(
            textMessageEntity: TextMessageEntity(
                time: Timestamp.now(),
                content: audioUrl,
                senderName: widget.singleChatEntity.username,
                senderId: widget.singleChatEntity.uid,
                type: "AUDIO"),
            channelId: widget.singleChatEntity.groupId)
        .then((value) {
      BlocProvider.of<GroupCubit>(context).updateGroup(
          groupEntity: GroupEntity(
        groupId: widget.singleChatEntity.groupId,
        lastMessage: _messageController.text,
        createAt: Timestamp.now(),
      ));
      _clear();
    });
  }

  Future<void> _sendTextMessage() async {
    final messageContent = _messageController.text;

    BlocProvider.of<ChatCubit>(context)
        .sendTextMessage(
            textMessageEntity: TextMessageEntity(
                time: Timestamp.now(),
                content: messageContent,
                senderName: widget.singleChatEntity.username,
                senderId: widget.singleChatEntity.uid,
                type: "TEXT"),
            channelId: widget.singleChatEntity.groupId)
        .then((value) {
      BlocProvider.of<GroupCubit>(context).updateGroup(
          groupEntity: GroupEntity(
        groupId: widget.singleChatEntity.groupId,
        lastMessage: _messageController.text,
        createAt: Timestamp.now(),
      ));
      _clear();
    });
  }
}
