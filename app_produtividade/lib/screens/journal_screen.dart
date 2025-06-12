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
        return AlertDialog(
          title: Text(isNewEntry ? 'Nova Entrada' : 'Editar Entrada'),
          content: TextField(
            controller: _contentController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Escreva seus pensamentos...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                if (!authProvider.isAuthenticated || authProvider.user == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erro: Usuário não autenticado.'), backgroundColor: Colors.red),
                    );
                  }
                  Navigator.pop(context, false);
                  return;
                }

                final String newContent = _contentController.text.trim();
                if (newContent.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('O conteúdo não pode estar vazio.'), backgroundColor: Colors.red),
                    );
                  }
                  return; // Não fechar o diálogo se o conteúdo for vazio
                }

                try {
                  if (isNewEntry) {
                    final newEntry = JournalEntryModel(
                      userId: authProvider.user!.id,
                      content: newContent,
                      timestamp: DateTime.now(),
                    );
                    await _journalService.addJournalEntry(newEntry);
                  } else {
                    final updatedEntry = entry.copyWith(
                      content: newContent,
                      timestamp: DateTime.now(), // Opcional: atualizar o timestamp na edição
                    );
                    await _journalService.updateJournalEntry(updatedEntry);
                  }
                  if (mounted) {
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  debugPrint('Erro ao salvar entrada: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: Text(isNewEntry ? 'Adicionar' : 'Salvar'),
            ),
          ],
        );
      },
    );
    _fetchJournalEntries(); // Recarrega as entradas após adicionar/editar
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
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _journalEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _journalEntries[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(entry.timestamp),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.content,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () => _addOrEditEntry(entry: entry),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _deleteEntry(entry.id!),
                                ),
                              ],
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