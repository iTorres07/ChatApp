import 'dart:async';
import 'dart:io';

import 'package:bubble/bubble.dart';
import 'package:chat_app_1/features/group/domain/entities/group_entity.dart';
import 'package:chat_app_1/features/group/domain/entities/single_chat_entity.dart';
import 'package:chat_app_1/features/group/domain/entities/text_message_entity.dart';
import 'package:chat_app_1/features/group/presentation/cubits/chat/chat_cubit.dart';
import 'package:chat_app_1/features/group/presentation/cubits/group/group_cubit.dart';
import 'package:chat_app_1/features/storage/domain/usecases/upload_audio_usecase.dart';
import 'package:chat_app_1/features/storage/domain/usecases/upload_image_usecase.dart';
import 'package:chat_app_1/features/storage/domain/usecases/upload_video_usecase.dart';
import 'package:chat_app_1/global/common/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_app_1/features/injection_container.dart' as di;
import 'package:intl/intl.dart';

class SingleChatPage extends StatefulWidget {
  final SingleChatEntity singleChatEntity;

  const SingleChatPage({Key? key, required this.singleChatEntity})
      : super(key: key);

  @override
  State<SingleChatPage> createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> {
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  File? _image;
  File? _audio;
  File? _video;
  File? _selectedImage;
  File? _selectedVideo;
  File? _selectedAudio;

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
          Container(
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
                    name,
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
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  _sendMessageTextField() {
    return Row(
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
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      color: Colors.grey[500],
                      onPressed: _getImage,
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam),
                      color: Colors.grey[500],
                      onPressed: _getVideo,
                    ),
                    IconButton(
                      icon: const Icon(Icons.audiotrack),
                      color: Colors.grey[500],
                      onPressed: _getAudio,
                    ),
                  ],
                ),
                const SizedBox(
                  width: 15,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        InkWell(
          onTap: () {
            if (_messageController.text.isEmpty &&
                _audio.toString().isEmpty &&
                _video.toString().isEmpty &&
                _image.toString().isEmpty) {
            } else {
              _sendMessage();
            }
          },
          child: Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: Icon(
              _messageController.text.isEmpty ? Icons.send : Icons.send,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  void _sendMessage() {
    if (_audio.toString().isEmpty &&
        _video.toString().isEmpty &&
        _image.toString().isEmpty) {
      BlocProvider.of<ChatCubit>(context)
          .sendTextMessage(
              textMessageEntity: TextMessageEntity(
                  time: Timestamp.now(),
                  content: _messageController.text,
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
    if (_audio.toString().isNotEmpty) {
      // Subir archivo de audio y enviar mensaje
      di.sl<UploadAudioUseCase>().call(file: _selectedAudio!).then((audioUrl) {
        BlocProvider.of<ChatCubit>(context)
            .sendTextMessage(
          textMessageEntity: TextMessageEntity(
            time: Timestamp.now(),
            content: _messageController.text,
            senderName: widget.singleChatEntity.username,
            senderId: widget.singleChatEntity.uid,
            type: "AUDIO",
            audioUrl: audioUrl,
          ),
          channelId: widget.singleChatEntity.groupId,
        )
            .then((value) {
          BlocProvider.of<GroupCubit>(context).updateGroup(
            groupEntity: GroupEntity(
              groupId: widget.singleChatEntity.groupId,
              lastMessage: _messageController.text,
              createAt: Timestamp.now(),
            ),
          );
          _clear();
        });
      });
    }
    if (_image.toString().isNotEmpty) {
      // Subir imagen y enviar mensaje
      di.sl<UploadImageUseCase>().call(file: _selectedImage!).then((imageUrl) {
        BlocProvider.of<ChatCubit>(context)
            .sendTextMessage(
          textMessageEntity: TextMessageEntity(
            time: Timestamp.now(),
            content: _messageController.text,
            senderName: widget.singleChatEntity.username,
            senderId: widget.singleChatEntity.uid,
            type: "IMAGE",
            imageUrl: imageUrl,
          ),
          channelId: widget.singleChatEntity.groupId,
        )
            .then((value) {
          BlocProvider.of<GroupCubit>(context).updateGroup(
            groupEntity: GroupEntity(
              groupId: widget.singleChatEntity.groupId,
              lastMessage: _messageController.text,
              createAt: Timestamp.now(),
            ),
          );
          _clear();
        });
      });
    }
    if (_video.toString().isNotEmpty) {
      di.sl<UploadVideoUseCase>().call(file: _selectedVideo!).then((videoUrl) {
        BlocProvider.of<ChatCubit>(context)
            .sendTextMessage(
          textMessageEntity: TextMessageEntity(
            time: Timestamp.now(),
            content: _messageController.text,
            senderName: widget.singleChatEntity.username,
            senderId: widget.singleChatEntity.uid,
            type: "VIDEO",
            videoUrl: videoUrl,
          ),
          channelId: widget.singleChatEntity.groupId,
        )
            .then((value) {
          BlocProvider.of<GroupCubit>(context).updateGroup(
            groupEntity: GroupEntity(
              groupId: widget.singleChatEntity.groupId,
              lastMessage: _messageController.text,
              createAt: Timestamp.now(),
            ),
          );
          _clear();
        });
      });
    }
  }

  void _clear() {
    setState(() {
      _messageController.clear();
    });
  }

  _messageListWidget(List<TextMessageEntity> messages) {
    if (_scrollController.hasClients) {
      Timer(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
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
          );
        }
      },
    ));
  }

  Future<void> _getImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
      );

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    } catch (e) {
      toast("error $e");
    }
  }

  Future<void> _getAudio() async {
    try {
      final pickedAudio = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav'], // Extensiones permitidas
      );

      setState(() {
        if (pickedAudio != null) {
          _audio = File(pickedAudio as String);
        } else {
          print('No audio selected.');
        }
      });
    } catch (e) {
      toast("error $e");
    }
  }

  Future<void> _getVideo() async {
    try {
      final pickedVideo =
          await ImagePicker().pickVideo(source: ImageSource.gallery);

      setState(() {
        if (pickedVideo != null) {
          _video = File(pickedVideo.path);
        } else {
          print('No video selected.');
        }
      });
    } catch (e) {
      toast("error $e");
    }
  }
}
