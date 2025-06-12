import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_entry_model.dart';

class JournalService {
  static final JournalService _instance = JournalService._internal();
  factory JournalService() => _instance;

  JournalService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _getJournalCollection() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception("Usuário não autenticado.");
    }
    return _firestore.collection('users').doc(userId).collection('journal_entries');
  }

  Future<void> addJournalEntry(JournalEntryModel entry) async {
    try {
      await _getJournalCollection().add(entry.toJson());
      print('Entrada de diário adicionada com sucesso!');
    } catch (e) {
      print('Erro ao adicionar entrada de diário: $e');
      rethrow;
    }
  }

  Future<List<JournalEntryModel>> getJournalEntries() async {
    try {
      final snapshot = await _getJournalCollection()
          .orderBy('timestamp', descending: true) // Ordenar por data mais recente
          .get();

      return snapshot.docs
          .map((doc) => JournalEntryModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar entradas de diário: $e');
      return [];
    }
  }

  Future<void> updateJournalEntry(JournalEntryModel entry) async {
    if (entry.id == null) {
      throw Exception('ID da entrada de diário não fornecido para atualização.');
    }
    try {
      await _getJournalCollection().doc(entry.id).update(entry.toJson());
      print('Entrada de diário atualizada com sucesso: ${entry.id}');
    } catch (e) {
      print('Erro ao atualizar entrada de diário: $e');
      rethrow;
    }
  }

  Future<void> deleteJournalEntry(String entryId) async {
    try {
      await _getJournalCollection().doc(entryId).delete();
      print('Entrada de diário excluída com sucesso: $entryId');
    } catch (e) {
      print('Erro ao excluir entrada de diário: $e');
      rethrow;
    }
  }
} 