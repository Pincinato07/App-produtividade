import 'package:flutter/material.dart';
import '../models/tarefa_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final tarefaService = TarefaService();
  int selectedDay = 11;

  @override
  Widget build(BuildContext context) {
    double progresso = 40;
    double meta = 150;
    final tarefasHoje = tarefaService.getTarefas(selectedDay);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                    ),
                    const Icon(Icons.search, color: Colors.black),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Temporada atual',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('50 min',
                    style: TextStyle(fontSize: 18, color: Colors.black54)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Intensidade média',
                    style: TextStyle(fontSize: 14, color: Colors.black38)),
              ),
              const SizedBox(height: 16),

              // Dias
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [11, 12, 13, 14].map((day) {
                      bool isSelected = selectedDay == day;
                      final tarefas = tarefaService.getTarefas(day);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          onTap: () => setState(() => selectedDay = day),
                          onLongPress: () => _abrirAgendamento(context),
                          child: Container(
                            width: 60,
                            height: 70,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF3CA6F6)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                          color: const Color(0xFF3CA6F6)
                                              .withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4))
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color:
                                        isSelected ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Nov',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                ),
                                if (tarefas.isNotEmpty)
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Progresso
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Seu progresso',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progresso / meta,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      color: const Color(0xFF3CA6F6),
                    ),
                    const SizedBox(height: 4),
                    Text('${progresso.toInt()} min / ${meta.toInt()} min',
                        style: const TextStyle(fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Imagem ilustrativa maior
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Image.asset('assets/progresso.png', height: 260),
                ),
              ),

              const SizedBox(height: 32),

              // Lista de tarefas do dia
              if (tarefasHoje.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tarefas do dia',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...tarefasHoje.map((tarefa) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.check_circle_outline),
                              title: Text(tarefa.toString()),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _showEditTaskDialog(context, tarefa),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteTask(tarefa),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3CA6F6),
        onPressed: () => _abrirAgendamento(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _abrirAgendamento(BuildContext context) {
    String prioridade = 'Média';
    String nomeTarefa = '';

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Nova Tarefa",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF3CA6F6)),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Nome da tarefa",
                    prefixIcon: const Icon(Icons.edit_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) => nomeTarefa = value,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: prioridade,
                  items: ["Alta", "Média", "Baixa"]
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) => prioridade = val!,
                  decoration: InputDecoration(
                    labelText: "Prioridade",
                    prefixIcon: const Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar",
                          style: TextStyle(color: Colors.black54)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (nomeTarefa.trim().isNotEmpty) {
                          setState(() {
                            tarefaService.adicionarTarefa(
                                selectedDay,
                                Tarefa(
                                    nome: nomeTarefa.trim(),
                                    prioridade: prioridade));
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3CA6F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("Salvar",
                          style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showEditTaskDialog(BuildContext context, Tarefa tarefa) {
    String nomeTarefa = tarefa.nome;
    String prioridade = tarefa.prioridade;

    showDialog(
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
                const Text(
                  "Editar Tarefa",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF3CA6F6)),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Nome da tarefa",
                    prefixIcon: const Icon(Icons.edit_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  controller: TextEditingController(text: nomeTarefa),
                  onChanged: (value) => nomeTarefa = value,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: prioridade,
                  items: ["Alta", "Média", "Baixa"]
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) => prioridade = val!,
                  decoration: InputDecoration(
                    labelText: "Prioridade",
                    prefixIcon: const Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar",
                          style: TextStyle(color: Colors.black54)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (nomeTarefa.trim().isNotEmpty) {
                          setState(() {
                            tarefaService.editarTarefa(
                                selectedDay,
                                tarefa,
                                Tarefa(
                                    nome: nomeTarefa.trim(),
                                    prioridade: prioridade));
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3CA6F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("Salvar",
                          style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _deleteTask(Tarefa tarefa) {
    setState(() {
      tarefaService.removerTarefa(selectedDay, tarefa);
    });
  }
}