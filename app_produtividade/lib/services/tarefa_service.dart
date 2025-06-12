import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_produtividade/models/tarefa_model.dart';

class TarefaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TarefaModel>> getTarefas() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('tarefas')
          .where('userId', isEqualTo: user.uid)
          .get();

      return snapshot.docs
          .map((doc) => TarefaModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar tarefas: $e');
      return [];
    }
  }

  Future<void> adicionarTarefa(TarefaModel tarefa) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final tarefaData = tarefa.toJson();
      tarefaData['userId'] = user.uid;

      await _firestore.collection('tarefas').add(tarefaData);
    } catch (e) {
      print('Erro ao adicionar tarefa: $e');
    }
  }

  Future<void> editarTarefa(TarefaModel tarefa) async {
    try {
      if (tarefa.id == null) return;

      final tarefaData = tarefa.toJson();
      tarefaData['userId'] = FirebaseAuth.instance.currentUser?.uid;

      await _firestore.collection('tarefas').doc(tarefa.id).update(tarefaData);
    } catch (e) {
      print('Erro ao editar tarefa: $e');
    }
  }

  Future<void> deletarTarefa(String tarefaId) async {
    try {
      await _firestore.collection('tarefas').doc(tarefaId).delete();
    } catch (e) {
      print('Erro ao deletar tarefa: $e');
    }
  }
} 