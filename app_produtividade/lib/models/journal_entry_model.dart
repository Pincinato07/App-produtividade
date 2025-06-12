import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntryModel {
  final String? id;
  final String userId;
  final String content;
  final DateTime timestamp;

  JournalEntryModel({
    this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
  });

  // Converte um objeto JournalEntryModel para um mapa JSON (para Firestore)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Cria um objeto JournalEntryModel a partir de um mapa JSON (do Firestore)
  factory JournalEntryModel.fromJson(Map<String, dynamic> json, String id) {
    return JournalEntryModel(
      id: id,
      userId: json['userId'] as String,
      content: json['content'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  // Método copyWith para criar uma nova instância com valores atualizados
  JournalEntryModel copyWith({
    String? id,
    String? userId,
    String? content,
    DateTime? timestamp,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() => 'JournalEntry: {content: $content, timestamp: $timestamp}';
} 