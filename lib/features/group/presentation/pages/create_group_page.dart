import 'dart:io';

import 'package:chat_app_1/features/group/domain/entities/group_entity.dart';
import 'package:chat_app_1/features/group/presentation/cubits/group/group_cubit.dart';
import 'package:chat_app_1/features/storage/domain/usecases/upload_group_image_usecase.dart';
import 'package:chat_app_1/global/common/common.dart';
import 'package:chat_app_1/global/theme/style.dart';
import 'package:chat_app_1/global/widgets/container/container_button.dart';
import 'package:chat_app_1/global/widgets/custom_text_field/text_field_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app_1/features/injection_container.dart' as di;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:network_image/network_image.dart';

class CreateGroupPage extends StatefulWidget {
  final String uid;

  const CreateGroupPage({Key? key, required this.uid}) : super(key: key);

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  File? _groupImage;

  bool _isImageUploading = false;

  TextEditingController _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future getImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
      );

      setState(() {
        if (pickedFile != null) {
          _groupImage = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    } catch (e) {
      toast("error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Group"),
      ),
      body: Container(
        margin: EdgeInsets.all(25),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                getImage();
              },
              child: Container(
                height: 80,
                width: 80,
                child: NetworkImageWidget(
                  imageFile: _groupImage,
                  borderRadiusImageFile: 50,
                  imageFileBoxFit: BoxFit.cover,
                  placeHolderBoxFit: BoxFit.cover,
                  networkImageBoxFit: BoxFit.cover,
                  imageUrl: "",
                  progressIndicatorBuilder: Center(
                    child: CircularProgressIndicator(),
                  ),
                  placeHolder: "assets/profile_default.png",
                ),
              ),
            ),
            SizedBox(
              height: 14,
            ),
            Text(
              'Add Group Image',
              style: TextStyle(
                  color: greenColor, fontSize: 16, fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 20,
            ),
            TextFieldContainer(
              controller: _groupNameController,
              keyboardType: TextInputType.text,
              hintText: 'group name',
              prefixIcon: FontAwesomeIcons.edit,
            ),
            SizedBox(
              height: 17,
            ),
            Divider(
              thickness: 2,
              indent: 120,
              endIndent: 120,
            ),
            SizedBox(
              height: 17,
            ),
            ContainerButton(
              onTap: () {
                _createNewGroup();
              },
              title: "Create new Group",
            ),
            SizedBox(
              height: 20,
            ),
            _isImageUploading == true
                ? Row(
                    children: [
                      Text("Please wait for moment..."),
                      SizedBox(
                        width: 10,
                      ),
                      CircularProgressIndicator(),
                    ],
                  )
                : Text(""),
          ],
        ),
      ),
    );
  }

  void _createNewGroup() {
    if (_groupNameController.text.isEmpty) {
      toast("Enter Group name");
      return;
    }
    if (_groupImage == null) {
      toast("Please select group image");
      return;
    }

    setState(() {
      _isImageUploading = true;
    });

    if (_groupImage != null) {
      di
          .sl<UploadGroupImageUseCase>()
          .call(file: _groupImage!)
          .then((imageUrl) {
        BlocProvider.of<GroupCubit>(context)
            .getCreateGroup(
                groupEntity: GroupEntity(
          createAt: Timestamp.now(),
          lastMessage: "",
          groupName: _groupNameController.text,
          uid: widget.uid,
          groupProfileImage: imageUrl,
        ))
            .then((value) {
          toast("group created successfully");
          _clear();
        });
      });
    }
  }

  void _clear() {
    setState(() {
      _groupNameController.clear();
      _groupImage = null;
      _isImageUploading = false;
    });
  }
}
