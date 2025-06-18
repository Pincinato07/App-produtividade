import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry_model.dart';
import '../services/journal_service.dart';
import '../providers/auth_provider.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalService _journalService = JournalService();
  List<JournalEntryModel> _journalEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJournalEntries();
  }

  Future<void> _fetchJournalEntries() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        final entries = await _journalService.getJournalEntries();
        setState(() {
          _journalEntries = entries;
        });
      } else {
        setState(() {
          _journalEntries = [];
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar entradas do diário: $e');
      setState(() {
        _journalEntries = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar diário: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addOrEditEntry({JournalEntryModel? entry}) async {
    final TextEditingController _contentController = TextEditingController(text: entry?.content ?? '');
    bool isNewEntry = entry == null;

    await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isNewEntry ? 'Nova Entrada' : 'Editar Entrada',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF3CA6F6),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Escreva seus pensamentos...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        final String newContent = _contentController.text.trim();
                        if (newContent.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('O conteúdo não pode estar vazio.'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        Navigator.pop(context, true);
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        if (isNewEntry) {
                          final newEntry = JournalEntryModel(
                            userId: authProvider.user!.id,
                            content: newContent,
                            timestamp: DateTime.now(),
                          );
                          _journalService.addJournalEntry(newEntry).then((_) => _fetchJournalEntries());
                        } else {
                          _journalService.updateJournalEntry(entry!.copyWith(content: newContent, timestamp: DateTime.now())).then((_) => _fetchJournalEntries());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3CA6F6),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(isNewEntry ? 'ADICIONAR' : 'SALVAR'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteEntry(String entryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza de que deseja excluir esta entrada do diário?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _journalService.deleteJournalEntry(entryId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrada excluída com sucesso!'), backgroundColor: Colors.green),
          );
        }
        _fetchJournalEntries(); // Recarrega as entradas após excluir
      } catch (e) {
        debugPrint('Erro ao excluir entrada: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Diário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addOrEditEntry,
            tooltip: 'Adicionar Nova Entrada',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _journalEntries.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma entrada no diário ainda. Que tal adicionar uma?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20.0),
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemCount: _journalEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _journalEntries[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.13),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        leading: Icon(Icons.book, color: Colors.blue[400], size: 32),
                        title: Text(
                          DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(entry.timestamp),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            entry.content,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF3CA6F6)),
                              onPressed: () => _addOrEditEntry(entry: entry),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteEntry(entry.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 