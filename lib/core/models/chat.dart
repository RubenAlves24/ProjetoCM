import 'dart:io';
import 'package:harvestly/core/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  String? id;
  String? name;
  String? description;
  List<String>? adminIds;
  List<String> membersIds;
  String? imageUrl;
  File? localImageFile;
  DateTime? createdAt;
  ChatMessage? lastMessage;

  Chat({
    this.id,
    this.name,
    this.description,
    this.adminIds,
    List<String>? membersIds,
    this.imageUrl,
    this.localImageFile,
    this.createdAt,
    this.lastMessage,
  }) : membersIds = membersIds ?? [];

  void addMember(String newUserId) {
    final userAlreadyExists = membersIds.contains(newUserId);
    if (userAlreadyExists) {
      print("Erro! Usuário já é membro.");
      return;
    }
    membersIds.add(newUserId);
  }

  String getName() => name ?? '';

  void setName(String name) => this.name = name;
  void setDescription(String description) => this.description = description;
  void setImage(String url) => imageUrl = url;

  factory Chat.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime? createdAt;
    if (data['createdAt'] is String) {
      createdAt = DateTime.tryParse(data['createdAt']);
    } else if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    }

    ChatMessage? lastMessage;
    if (data['lastMessage'] != null) {
      lastMessage = ChatMessage.fromMap(Map<String, dynamic>.from(data['lastMessage']));
    }

    return Chat(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      createdAt: createdAt,
      membersIds: List<String>.from(data['membersIds'] ?? []),
      adminIds: data['adminIds'] != null ? List<String>.from(data['adminIds']) : [],
      lastMessage: lastMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'membersIds': membersIds,
      'adminIds': adminIds ?? [],
      'lastMessage': lastMessage?.toMap(),
    };
  }
}
