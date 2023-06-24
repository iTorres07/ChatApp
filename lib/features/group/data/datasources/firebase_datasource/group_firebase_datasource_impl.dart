import 'package:chat_app_1/features/group/data/datasources/firebase_datasource/group_firebase_datasource.dart';
import 'package:chat_app_1/features/group/data/models/group_model.dart';
import 'package:chat_app_1/features/group/data/models/text_message_model.dart';
import 'package:chat_app_1/features/group/domain/entities/group_entity.dart';
import 'package:chat_app_1/features/group/domain/entities/text_message_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupFirebaseDataSourceImpl implements GroupFirebaseDataSource {
  final FirebaseFirestore firestore;

  GroupFirebaseDataSourceImpl({required this.firestore});

  @override
  Future<void> getCreateGroup(GroupEntity groupEntity) async {
    final groupCollection = firestore.collection("groups");

    final groupId = groupCollection.doc().id;

    groupCollection.doc(groupId).get().then((groupShopShot) async {
      final newGroup = GroupModel(
        uid: groupEntity.uid,
        createAt: groupEntity.createAt,
        groupId: groupId,
        groupName: groupEntity.groupName,
        groupProfileImage: groupEntity.groupProfileImage,
        lastMessage: groupEntity.lastMessage,
      ).toDocument();

      if (!groupShopShot.exists) {
        await groupCollection.doc(groupId).set(newGroup);

        return;
      }
      return;
    });
  }

  @override
  Stream<List<GroupEntity>> getGroups() {
    final groupCollection = firestore.collection("groups");
    return groupCollection
        .orderBy("createAt", descending: true)
        .snapshots()
        .map((querySnapshot) =>
            querySnapshot.docs.map((e) => GroupModel.fromSnapshot(e)).toList());
  }

  @override
  Stream<List<TextMessageEntity>> getMessages(String channelId) {
    final messagesCollection = firestore
        .collection("groupChatChannel")
        .doc(channelId)
        .collection("messages");

    return messagesCollection.orderBy('time').snapshots().map((querySnap) =>
        querySnap.docs
            .map((queryDoc) => TextMessageModel.fromSnapshot(queryDoc))
            .toList());
  }

  @override
  Future<void> sendTextMessage(
      TextMessageEntity textMessageEntity, String channelId) async {
    final messagesCollection = firestore
        .collection("groupChatChannel")
        .doc(channelId)
        .collection("messages");

    final messageId = messagesCollection.doc().id;

    final newTextMessage = TextMessageModel(
      content: textMessageEntity.content,
      senderName: textMessageEntity.senderName,
      senderId: textMessageEntity.senderId,
      recipientId: textMessageEntity.recipientId,
      receiverName: textMessageEntity.receiverName,
      time: textMessageEntity.time,
      messageId: messageId,
      type: "TEXT",
      videoUrl: textMessageEntity.videoUrl,
      imageUrl: textMessageEntity.imageUrl,
      audioUrl: textMessageEntity.audioUrl,
    ).toDocument();

    await messagesCollection.doc(messageId).set(newTextMessage);
  }

  @override
  Future<void> updateGroup(GroupEntity groupEntity) async {
    Map<String, dynamic> groupInformation = Map();

    final groupCollection = firestore.collection("groups");

    if (groupEntity.groupProfileImage != null &&
        groupEntity.groupProfileImage != "") {
      groupInformation['groupProfileImage'] = groupEntity.groupProfileImage;
    }

    if (groupEntity.createAt != null) {
      groupInformation["createAt"] = groupEntity.createAt;
    }

    if (groupEntity.groupName != null && groupEntity.groupName != "") {
      groupInformation["groupName"] = groupEntity.groupName;
    }

    if (groupEntity.lastMessage != null && groupEntity.lastMessage != "") {
      groupInformation["lastMessage"] = groupEntity.lastMessage;
    }

    groupCollection.doc(groupEntity.groupId).update(groupInformation);
  }
}
