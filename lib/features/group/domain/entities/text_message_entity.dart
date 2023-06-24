import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TextMessageEntity extends Equatable {
  final String? recipientId;
  final String? senderId;
  final String? senderName;
  final String? type;
  final Timestamp? time;
  final String? content;
  final String? receiverName;
  final String? messageId;
  final String? videoUrl; // URL del archivo multimedia
  final String? imageUrl;
  final String? audioUrl;

  const TextMessageEntity({
    this.recipientId,
    this.senderId,
    this.senderName,
    this.type,
    this.time,
    this.content,
    this.receiverName,
    this.messageId,
    this.audioUrl,
    this.imageUrl,
    this.videoUrl,
  });

  TextMessageEntity copyWith({
    String? recipientId,
    String? senderId,
    String? senderName,
    String? type,
    Timestamp? time,
    String? content,
    String? receiverName,
    String? messageId,
    String? audioUrl,
    String? imageUrl,
    String? videoUrl,
  }) {
    return TextMessageEntity(
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      type: type ?? this.type,
      time: time ?? this.time,
      content: content ?? this.content,
      receiverName: receiverName ?? this.receiverName,
      messageId: messageId ?? this.messageId,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  @override
  List<Object?> get props => [
        recipientId,
        senderId,
        senderName,
        type,
        time,
        content,
        receiverName,
        messageId,
        audioUrl,
        videoUrl,
        imageUrl,
      ];
}
