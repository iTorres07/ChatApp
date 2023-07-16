import 'dart:async';
import 'package:bubble/bubble.dart';
import 'package:chat_app_1/features/group/domain/entities/group_entity.dart';
import 'package:chat_app_1/features/group/domain/entities/single_chat_entity.dart';
import 'package:chat_app_1/features/group/domain/entities/text_message_entity.dart';
import 'package:chat_app_1/features/group/presentation/cubits/chat/chat_cubit.dart';
import 'package:chat_app_1/features/group/presentation/cubits/group/group_cubit.dart';
import 'package:chat_app_1/features/group/presentation/pages/image_viewer.dart';
import 'package:chat_app_1/features/group/presentation/pages/location_page.dart';
import 'package:chat_app_1/features/group/presentation/pages/pdf_viewer.dart';
import 'package:chat_app_1/features/group/presentation/pages/video_viewer.dart';
import 'package:chat_app_1/global/theme/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:network_image/network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// ignore: constant_identifier_names
const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoiZW1pdG9ycmVzNyIsImEiOiJjbGs0cHRhNWUwanRtM2Z0ankzeHpmYzNqIn0.zEXm5ezAjAChGtywsygrqg';

class SingleChatPage extends StatefulWidget {
  final SingleChatEntity singleChatEntity;

  const SingleChatPage({Key? key, required this.singleChatEntity})
      : super(key: key);

  @override
  State<SingleChatPage> createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> {
  String? myPosition;
  String? newPosition;
  File? _selectedImage;
  File? _selectedVideo;
  File? _selectedAudio;
  File? _selectedPdf;
  LatLng? _selectedPoint;

  bool showMediaButtons = false;
  bool sending = false;
  bool playing = false;
  bool ignoreStateChanges = false;
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
    _scrollController.addListener(() {
      if (!ignoreStateChanges) {
        _handleScroll;
      }
    });

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

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  getCurrentLocation() async {
    Position position = await determinePosition();
    myPosition = '${position.latitude}, ${position.longitude}';
    return myPosition;
  }

  @override
  void dispose() {
    _saveScrollPosition();
    _scrollController.dispose();
    _messageController.dispose();
    myPosition = null;
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
                child: name == ""
                    ? Column(
                        crossAxisAlignment: crossAlign,
                        children: [
                          content,
                        ],
                      )
                    : Column(
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
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: showMediaButtons ? 60.0 * fem : 271.0 * fem,
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
                    ],
                  ),
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
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: showMediaButtons ? 1.0 : 0.0,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          color: Colors.black87,
                        ),
                        IconButton(
                          onPressed: _pickVideo,
                          icon: const Icon(Icons.videocam),
                          color: Colors.black87,
                        ),
                        IconButton(
                          onPressed: _pickAudio,
                          icon: const Icon(Icons.audiotrack),
                          color: Colors.black87,
                        ),
                        IconButton(
                          onPressed: _pickPdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          color: Colors.black87,
                        ),
                        IconButton(
                          onPressed: _pickLocation,
                          icon: const Icon(Icons.place),
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.attach_file),
                color: Colors.blue,
                iconSize: 30,
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
                  } else if (_messageController.text.isEmpty) {
                    _pickAudio();
                  }
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: sending
                      ? Transform.scale(
                          scale: 0.5,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _messageController.text.isEmpty ||
                                  _selectedAudio.toString().isEmpty ||
                                  _selectedImage.toString().isEmpty ||
                                  _selectedVideo.toString().isEmpty ||
                                  _selectedPdf.toString().isEmpty
                              ? Icons.mic
                              : Icons.send,
                          color: Colors.white,
                        ),
                ),
              ),
            ],
          ),
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
        padding: const EdgeInsets.only(bottom: 60.0),
        child: ListView.builder(
          itemCount: messages.length,
          controller: _scrollController,
          reverse: false,
          itemBuilder: (BuildContext context, int index) {
            final singleMessage = messages[index];

            if (singleMessage.senderId == widget.singleChatEntity.uid) {
              return GestureDetector(
                onLongPress: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: const Text('¿Que desea realizar?'),
                          actions: [
                            TextButton(
                              child: const Text('Cerrar'),
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Eliminar'),
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });
                },
                child: Container(
                  alignment: Alignment.centerRight,
                  child: _messageLayout(
                    name: "",
                    alignName: TextAlign.end,
                    color: Colors.lightBlue,
                    align: TextAlign.right,
                    nip: BubbleNip.rightTop,
                    boxAlign: CrossAxisAlignment.end,
                    crossAlign: CrossAxisAlignment.end,
                    text: singleMessage.content!,
                    time: DateFormat('hh:mm a')
                        .format(singleMessage.time!.toDate()),
                    content: _buildMessageContent(singleMessage),
                  ),
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
    if (message.type == 'IMAGE') {
      var imageUrl = message.content;
      return GestureDetector(
        child: NetworkImageWidget(
          borderRadiusNetworkImage: 10,
          imageFileBoxFit: BoxFit.cover,
          placeHolderBoxFit: BoxFit.cover,
          networkImageBoxFit: BoxFit.cover,
          imageUrl: imageUrl,
          progressIndicatorBuilder: const Center(
            child: CircularProgressIndicator(),
          ),
          placeHolder: "assets/profile_default.png",
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewer(imageUrl!),
            ),
          );
        },
      );
    } else if (message.content!.contains(".mp4")) {
      return _buildVideoPlayer(message.content!);
    } else if (message.content!.contains(".m4a")) {
      return _buildAudioPlayer(message.content!);
    } else if (message.content!.contains(".pdf")) {
      return _buildPdfViewer(message.content!);
    } else if (message.type == 'LOCATION') {
      return _buildLocationViewer(message.content!);
    } else {
      return Text(message.content!);
    }
  }

  Widget _buildVideoPlayer(String videoUrl) {
    return GestureDetector(
      onTap: () {
        // ignore: deprecated_member_use
        _videoPlayerController = VideoPlayerController.network(videoUrl)
          ..initialize().then((_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoViewer(_videoPlayerController!),
              ),
            );
          });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              width: 300,
              height: 300,
              color: Colors.black,
            ),
          ),
          const Icon(Icons.play_arrow, color: Colors.white, size: 60),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(String audioUrl) {
    final audioPlayer = AudioPlayer();

    return IconButton(
      onPressed: () {
        playing = !playing;

        if (playing) {
          audioPlayer.play(audioUrl);
        } else {
          audioPlayer.pause();
        }
      },
      icon: playing ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
      iconSize: 30,
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
      iconSize: 30,
    );
  }

  Widget _buildLocationViewer(String location) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationPage(
              location,
            ),
          ),
        );
      },
      icon: const Icon(Icons.place),
      iconSize: 30,
    );
  }

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        showMediaButtons = !showMediaButtons;
      });
      _sendImageMessage();
    }
  }

  Future<void> _pickVideo() async {
    final pickedVideo = await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      setState(() {
        _selectedVideo = File(pickedVideo.path);
        _videoPlayerController = VideoPlayerController.file(_selectedVideo!)
          ..initialize();
        showMediaButtons = !showMediaButtons;
      });
      _sendVideoMessage();
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null) {
      setState(() {
        _selectedAudio = File(result.files.single.path!);
        showMediaButtons = !showMediaButtons;
      });
      _sendAudioMessage();
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
        showMediaButtons = !showMediaButtons;
      });
      _sendPdfMessage();
    }
  }

  Future<void> _pickLocation() async {
    myPosition = await getCurrentLocation();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ubicación'),
          content: const Text('¿Que quieres envíar?'),
          actions: [
            TextButton(
              child: const Text('Enviar mi ubicación actual'),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  showMediaButtons = !showMediaButtons;
                });
                _sendLocationMessage();
              },
            ),
            TextButton(
              child: const Text('Seleccionar una ubicación'),
              onPressed: () async {
                Navigator.of(context).pop();
                List<String> coordinates = myPosition!.split(',');
                double latitude = double.parse(coordinates[0]);
                double longitude = double.parse(coordinates[1]);
                _selectedPoint = LatLng(latitude, longitude);
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return Column(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    child: Icon(
                                      Icons.close,
                                      size: 30.0,
                                      color: greenColor,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  const Text(
                                    'Seleccione la ubicación',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                  GestureDetector(
                                    child: Icon(
                                      Icons.send,
                                      size: 30.0,
                                      color: greenColor,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        newPosition =
                                            '${_selectedPoint!.latitude},${_selectedPoint!.longitude}';
                                        showMediaButtons = !showMediaButtons;
                                      });
                                      _sendLocationMessage();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SizedBox(
                                    height: 300,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: SizedBox(
                                        height: 600,
                                        child: FlutterMap(
                                          options: MapOptions(
                                            center: _selectedPoint,
                                            minZoom: 5,
                                            maxZoom: 25,
                                            zoom: 12,
                                            enableScrollWheel: true,
                                            onTap: (tapPosition, point) {
                                              setState(() {
                                                _selectedPoint = LatLng(
                                                  point.latitude,
                                                  point.longitude,
                                                );
                                              });
                                            },
                                          ),
                                          nonRotatedChildren: [
                                            TileLayer(
                                              urlTemplate:
                                                  'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                                              additionalOptions: const {
                                                'accessToken':
                                                    MAPBOX_ACCESS_TOKEN,
                                                'id': 'mapbox/streets-v12'
                                              },
                                            ),
                                            MarkerLayer(
                                              markers: [
                                                Marker(
                                                  point: _selectedPoint!,
                                                  builder: (context) {
                                                    return const Icon(
                                                      Icons.place,
                                                      color: Colors.red,
                                                      size: 40,
                                                    );
                                                  },
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendImageMessage() async {
    sending = true;
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
                  type: "IMAGE"),
              channelId: widget.singleChatEntity.groupId)
          .then((value) {
        BlocProvider.of<GroupCubit>(context).updateGroup(
            groupEntity: GroupEntity(
          groupId: widget.singleChatEntity.groupId,
          lastMessage: _messageController.text,
          createAt: Timestamp.now(),
        ));
        _clear();
        sending = false;
      });
    }
  }

  Future<void> _sendVideoMessage() async {
    sending = true;
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
      sending = false;
    });
  }

  Future<void> _sendAudioMessage() async {
    sending = true;

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
      sending = false;
    });
  }

  Future<void> _sendPdfMessage() async {
    sending = true;

    final ref = _storage
        .ref()
        .child('pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf');

    final uploadTask = ref.putFile(_selectedPdf!);

    await uploadTask.whenComplete(() => null);

    final pdfUrl = await ref.getDownloadURL();

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
      sending = false;
    });
  }

  Future<void> _sendLocationMessage() async {
    sending = true;
    String? messageContent;

    if (newPosition != null) {
      messageContent = newPosition;
    } else {
      messageContent = myPosition;
    }

    BlocProvider.of<ChatCubit>(context)
        .sendTextMessage(
            textMessageEntity: TextMessageEntity(
                time: Timestamp.now(),
                content: messageContent,
                senderName: widget.singleChatEntity.username,
                senderId: widget.singleChatEntity.uid,
                type: "LOCATION"),
            channelId: widget.singleChatEntity.groupId)
        .then((value) {
      BlocProvider.of<GroupCubit>(context).updateGroup(
          groupEntity: GroupEntity(
        groupId: widget.singleChatEntity.groupId,
        lastMessage: _messageController.text,
        createAt: Timestamp.now(),
      ));
      _clear();
      sending = false;
    });
  }

  Future<void> _sendTextMessage() async {
    final messageContent = _messageController.text;
    if (_selectedImage == null &&
        _selectedVideo == null &&
        _selectedPdf == null &&
        _selectedAudio == null) {
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
}
