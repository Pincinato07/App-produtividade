import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import './tarefa_model.dart'; // Importa o novo TarefaModel

class TarefaService {
  static final TarefaService _instancia = TarefaService._interna();
  factory TarefaService() => _instancia;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TarefaService._interna();

  // Obtém a coleção de tarefas do usuário logado
  CollectionReference<Map<String, dynamic>> _getTarefasCollection() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }
    return _firestore.collection('users').doc(userId).collection('tarefas');
  }

  // Buscar tarefas para um dia específico
  Future<List<TarefaModel>> getTarefasPorData(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      final snapshot = await _getTarefasCollection()
          .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('data', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('data', descending: false) // Opcional: ordenar por data
          .get();

      return snapshot.docs
          .map((doc) => TarefaModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('TarefaService: Erro ao buscar tarefas por data: $e');
      return [];
    }
  }

  // Adicionar uma nova tarefa
  Future<void> adicionarTarefa(TarefaModel tarefa) async {
    try {
      await _getTarefasCollection().add(tarefa.toJson());
      debugPrint('TarefaService: Tarefa adicionada com sucesso: ${tarefa.nome}');
    } catch (e) {
      debugPrint('TarefaService: Erro ao adicionar tarefa: $e');
      rethrow;
    }
  }

  // Editar uma tarefa existente
  Future<void> editarTarefa(TarefaModel tarefa) async {
    if (tarefa.id == null) {
      throw Exception('ID da tarefa não fornecido para edição.');
    }
    try {
      await _getTarefasCollection().doc(tarefa.id).update(tarefa.toJson());
      debugPrint('TarefaService: Tarefa atualizada com sucesso: ${tarefa.nome}');
    } catch (e) {
      debugPrint('TarefaService: Erro ao editar tarefa: $e');
      rethrow;
    }
  }

  // Remover uma tarefa
  Future<void> removerTarefa(String tarefaId) async {
    try {
      await _getTarefasCollection().doc(tarefaId).delete();
      debugPrint('TarefaService: Tarefa removida com sucesso: $tarefaId');
    } catch (e) {
      debugPrint('TarefaService: Erro ao remover tarefa: $e');
      rethrow;
    }
  }

  // Buscar todas as tarefas (para dashboard ou outra listagem geral)
  Future<List<TarefaModel>> todasTarefas() async {
    try {
      final snapshot = await _getTarefasCollection().get();
      final tarefas = snapshot.docs
          .map((doc) => TarefaModel.fromJson(doc.data(), doc.id))
          .toList();
      
      // Ordena as tarefas: primeiro as que têm dueDate (as mais próximas primeiro),
      // depois as que não têm dueDate (ordenadas pela data de criação).
      tarefas.sort((a, b) {
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!); // Ambas têm prazo
        } else if (a.dueDate != null) {
          return -1; // A tem prazo, B não tem (A vem antes)
        } else if (b.dueDate != null) {
          return 1; // B tem prazo, A não tem (B vem antes)
        } else {
          return a.data.compareTo(b.data); // Nenhuma tem prazo, ordena pela data de criação
        }
      });

      return tarefas;
    } catch (e) {
      debugPrint('TarefaService: Erro ao buscar todas as tarefas: $e');
      return [];
    }
  }
}