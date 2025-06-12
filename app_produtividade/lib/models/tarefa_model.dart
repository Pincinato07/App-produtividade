import 'package:cloud_firestore/cloud_firestore.dart';

class TarefaModel {
  final String? id;
  final String nome;
  final String prioridade;
  final DateTime data;
  final bool isCompleted;
  final DateTime? dueDate;
  final String? category;

  TarefaModel({
    this.id,
    required this.nome,
    required this.prioridade,
    required this.data,
    this.isCompleted = false,
    this.dueDate,
    this.category,
  });

  // Converte um objeto TarefaModel para um mapa JSON (para Firestore)
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'prioridade': prioridade,
      'data': Timestamp.fromDate(data),
      'isCompleted': isCompleted,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'category': category,
    };
  }

  // Cria um objeto TarefaModel a partir de um mapa JSON (do Firestore)
  factory TarefaModel.fromJson(Map<String, dynamic> json, String id) {
    return TarefaModel(
      id: id,
      nome: json['nome'] as String,
      prioridade: json['prioridade'] as String,
      data: (json['data'] as Timestamp).toDate(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      dueDate: (json['dueDate'] as Timestamp?)?.toDate(),
      category: json['category'] as String?,
    );
  }

  // Método copyWith para criar uma nova instância com valores atualizados
  TarefaModel copyWith({
    String? id,
    String? nome,
    String? prioridade,
    DateTime? data,
    bool? isCompleted,
    DateTime? dueDate,
    String? category,
  }) {
    return TarefaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      prioridade: prioridade ?? this.prioridade,
      data: data ?? this.data,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
    );
  }

  @override
  String toString() => 'Tarefa: $nome, Prioridade: $prioridade, Data: ${data.toIso8601String()}, Concluída: $isCompleted, Prazo: ${dueDate?.toIso8601String()}, Categoria: $category';
} 