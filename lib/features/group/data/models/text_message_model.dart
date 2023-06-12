import 'package:chat_app_1/features/group/domain/entities/text_message_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TextMessageModel extends TextMessageEntity {
  TextMessageModel({
    String? recipientId,
    String? senderId,
    String? senderName,
    String? type,
    Timestamp? time,
    String? content,
    String? receiverName,
    String? messageId,
    String? videoUrl,
    String? audioUrl,
    String? imageUrl,
  }) : super(
          recipientId: recipientId,
          senderId: senderId,
          senderName: senderName,
          type: type,
          time: time,
          content: content,
          receiverName: receiverName,
          messageId: messageId,
          videoUrl: videoUrl,
          audioUrl: audioUrl,
          imageUrl: imageUrl,
        );

  factory TextMessageModel.fromSnapshot(DocumentSnapshot snapshot) {
    return TextMessageModel(
      recipientId: snapshot.get('recipientId'),
      senderId: snapshot.get('senderId'),
      senderName: snapshot.get('senderName'),
      type: snapshot.get('type'),
      time: snapshot.get('time'),
      content: snapshot.get('content'),
      receiverName: snapshot.get('receiverName'),
      messageId: snapshot.get('messageId'),
      imageUrl: snapshot.get('imageUrl'),
      audioUrl: snapshot.get('audioUrl'),
      videoUrl: snapshot.get('videoUrl'),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      "recipientId": recipientId,
      "senderId": senderId,
      "senderName": senderName,
      "type": type,
      "time": time,
      "content": content,
      "receiverName": receiverName,
      "messageId": messageId,
      "imageUrl": imageUrl,
      "videoUrl": videoUrl,
      "audioUrl": audioUrl,
    };
  }
}
