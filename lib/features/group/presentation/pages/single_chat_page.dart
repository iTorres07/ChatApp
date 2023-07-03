import 'dart:async';

import 'package:bubble/bubble.dart';
import 'package:chat_app_1/features/group/domain/entities/group_entity.dart';
import 'package:chat_app_1/features/group/domain/entities/single_chat_entity.dart';
import 'package:chat_app_1/features/group/domain/entities/text_message_entity.dart';
import 'package:chat_app_1/features/group/presentation/cubits/chat/chat_cubit.dart';
import 'package:chat_app_1/features/group/presentation/cubits/group/group_cubit.dart';
import 'package:chat_app_1/features/group/presentation/pages/pdf_viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:network_image/network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  File? _selectedPdf;

  bool showMediaButtons = false;
  late SharedPreferences _preferences;
  VideoPlayerController? _videoPlayerController;

  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;
  final TextEditingController _messageController = TextEditingController();

  late ScrollController _scrollController;

  @override
  void initState() {
    _initSharedPreferences();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    BlocProvider.of<ChatCubit>(context)
        .getMessages(channelId: widget.singleChatEntity.groupId);
    _messageController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  void _initSharedPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    final double savedPosition = _preferences.getDouble('scroll_position') ?? 0;
    _scrollController = ScrollController(initialScrollOffset: savedPosition);
  }

  void _saveScrollPosition() {
    if (_scrollController.hasClients) {
      _preferences.setDouble(
          'scroll_position', _scrollController.position.pixels);
    }
  }

  void _handleScroll() {
    _saveScrollPosition();
  }

  @override
  void dispose() {
    _saveScrollPosition();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.singleChatEntity.groupName),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(
              "assets/background_wallpaper.png",
              fit: BoxFit.cover,
            ),
          ),
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, chatState) {
              if (chatState is ChatLoaded) {
                final messages = chatState.messages;
                return _messageListWidget(messages);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _sendMessageTextField(context),
          ),
        ],
      ),
    );
  }

  Widget _messageLayout({
    required String name,
    required TextAlign alignName,
    required Color color,
    required TextAlign align,
    required BubbleNip nip,
    required CrossAxisAlignment boxAlign,
    required CrossAxisAlignment crossAlign,
    required String text,
    required String time,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: boxAlign,
        children: [
          Row(
            mainAxisAlignment: boxAlign == CrossAxisAlignment.start
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: crossAlign,
                  children: [
                    Text(
                      name,
                      textAlign: alignName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    content,
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            time,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  _sendMessageTextField(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: showMediaButtons ? 90.0 * fem : 271.0 * fem,
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
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 60),
                        child: Scrollbar(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
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
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: showMediaButtons
                  ? AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: showMediaButtons ? 1.0 : 0.0,
                      child: Row(
                        children: [
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
                          IconButton(
                            onPressed: _pickPdf,
                            icon: const Icon(Icons.picture_as_pdf),
                            color: Colors.green,
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
            ),
            IconButton(
              icon: const Icon(Icons.attach_file),
              color: Colors.green,
              onPressed: () {
                setState(() {
                  showMediaButtons = !showMediaButtons;
                });
              },
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
                } else if (_selectedPdf != null) {
                  _sendPdfMessage();
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
                          _selectedVideo.toString().isEmpty &&
                          _selectedPdf.toString().isEmpty
                      ? Icons.mic
                      : Icons.send,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _clear() {
    setState(() {
      _selectedImage = null;
      _selectedVideo = null;
      _selectedAudio = null;
      _selectedPdf = null;
      _messageController.clear();
    });
  }

  Widget _messageListWidget(List<TextMessageEntity> messages) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 55.0),
        child: ListView.builder(
          itemCount: messages.length,
          controller: _scrollController,
          reverse: false,
          itemBuilder: (BuildContext context, int index) {
            final singleMessage = messages[index];

            if (singleMessage.senderId == widget.singleChatEntity.uid) {
              return Container(
                alignment: Alignment.centerRight,
                child: _messageLayout(
                  name: "Me",
                  alignName: TextAlign.end,
                  color: Colors.lightGreen,
                  align: TextAlign.right,
                  nip: BubbleNip.rightTop,
                  boxAlign: CrossAxisAlignment.end,
                  crossAlign: CrossAxisAlignment.end,
                  text: singleMessage.content!,
                  time: DateFormat('hh:mm a')
                      .format(singleMessage.time!.toDate()),
                  content: _buildMessageContent(singleMessage),
                ),
              );
            } else {
              return Container(
                alignment: Alignment.centerLeft,
                child: _messageLayout(
                  color: Colors.white,
                  nip: BubbleNip.leftTop,
                  name: "${singleMessage.senderName}",
                  alignName: TextAlign.start,
                  time: DateFormat('hh:mm a')
                      .format(singleMessage.time!.toDate()),
                  align: TextAlign.left,
                  boxAlign: CrossAxisAlignment.start,
                  crossAlign: CrossAxisAlignment.start,
                  text: singleMessage.content!,
                  content: _buildMessageContent(singleMessage),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMessageContent(TextMessageEntity message) {
    if (message.content!.contains(".png") ||
        message.content!.contains(".jpg")) {
      var imageUrl = message.content;
      return NetworkImageWidget(
        borderRadiusImageFile: 50,
        imageFileBoxFit: BoxFit.cover,
        placeHolderBoxFit: BoxFit.cover,
        networkImageBoxFit: BoxFit.cover,
        imageUrl: imageUrl,
        progressIndicatorBuilder: Center(
          child: CircularProgressIndicator(),
        ),
        placeHolder: "assets/profile_default.png",
      );
    } else if (message.content!.contains(".mp4")) {
      return _buildVideoPlayer(message.content!);
    } else if (message.content!.contains(".m4a")) {
      return _buildAudioPlayer(message.content!);
    } else if (message.content!.contains(".pdf")) {
      return _buildPdfViewer(message.content!);
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
              width: 300,
              height: 300,
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

  Widget _buildPdfViewer(String pdfUrl) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewer(pdfUrl),
          ),
        );
      },
      icon: const Icon(Icons.picture_as_pdf),
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
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null) {
      setState(() {
        _selectedAudio = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickPdf() async {
    FilePickerResult? pdf = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (pdf != null) {
      setState(() {
        _selectedPdf = File(pdf.files.single.path!);
      });
    }
  }

  Future<void> _sendImageMessage() async {
    if (_selectedImage != null) {
      final ref = _storage
          .ref()
          .child('chat_images/${DateTime.now().toIso8601String()}');
      await ref.putFile(_selectedImage!);
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
    }
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

  Future<void> _sendPdfMessage() async {
    final ref = _storage
        .ref()
        .child('pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf');
    print('ref:${ref}');
    final uploadTask = ref.putFile(_selectedPdf!);

    await uploadTask.whenComplete(() => null);

    final pdfUrl = await ref.getDownloadURL();

    print('pdf cargado${ref}');

    BlocProvider.of<ChatCubit>(context)
        .sendTextMessage(
            textMessageEntity: TextMessageEntity(
                time: Timestamp.now(),
                content: pdfUrl,
                senderName: widget.singleChatEntity.username,
                senderId: widget.singleChatEntity.uid,
                type: "PDF"),
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
