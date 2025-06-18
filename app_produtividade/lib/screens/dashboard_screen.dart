import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_produtividade/services/tarefa_service.dart';
import 'package:app_produtividade/models/tarefa_model.dart';
import '../providers/auth_provider.dart';
import 'health_metrics_screen.dart';
import 'pomodoro_timer_screen.dart';
import 'journal_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TarefaService _tarefaService = TarefaService();
  List<TarefaModel> _allTasks = [];
  List<TarefaModel> _filteredTasks = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String searchQuery = '';
  String? selectedPriority;
  String? selectedCategory;
  List<int> _selectedRepetitionDays = [];

  // Mapeamento de dias da semana para exibição na UI e valores de inteiro
  final Map<int, String> _weekdaysMap = {
    1: 'Segunda',
    2: 'Terça',
    3: 'Quarta',
    4: 'Quinta',
    5: 'Sexta',
    6: 'Sábado',
    7: 'Domingo',
  };

  // Lista de categorias disponíveis
  final List<String> _categories = [
    'Trabalho',
    'Pessoal',
    'Estudo',
    'Saúde',
    'Lazer',
    'Outros'
  ];

  // Adicionar variável de controle para o filtro
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchTasks();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;
    setState(() {
      searchQuery = _searchController.text;
      _filterTasks();
    });
  }

  void _filterTasks() {
    setState(() {
      _filteredTasks = _allTasks.where((tarefa) {
        bool matchesSearch = tarefa.nome.toLowerCase().contains(searchQuery.toLowerCase());
        bool matchesPriority = selectedPriority == null || tarefa.prioridade == selectedPriority;
        bool matchesCategory = selectedCategory == null || tarefa.category == selectedCategory;

        bool matchesRepetition = true; // Assume true se não há dias de repetição definidos
        if (tarefa.repetitionDays != null && tarefa.repetitionDays!.isNotEmpty) {
          // Verifica se o dia da semana atual está nos dias de repetição da tarefa
          // Dart's weekday: Monday is 1, Sunday is 7.
          matchesRepetition = tarefa.repetitionDays!.contains(DateTime.now().weekday);
        } else {
          // Para tarefas sem repetição, elas sempre correspondem ao critério de repetição para exibição no dashboard geral.
          // Se a data da tarefa ou dueDate for de um dia específico (e.g. hoje ou em um futuro próximo) e não tiver repetição, ela ainda aparecerá.
          // Se a intenção é exibir APENAS tarefas para HOJE no dashboard (para não-repetitivas), uma lógica adicional seria necessária.
          // Por enquanto, consideramos que tarefas não repetitivas devem aparecer no dashboard se atenderem outros filtros.
          matchesRepetition = true;
        }

        return matchesSearch && matchesPriority && matchesCategory && matchesRepetition;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(context),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _buildDashboardContent(context, authProvider, _filteredTasks),
      ),
      // Botão Meu Progresso fixo no rodapé
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/progress');
          },
          icon: const Icon(Icons.show_chart),
          label: const Text('Meu Progresso'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3CA6F6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
      BuildContext context, AuthProvider authProvider, List<TarefaModel> tarefasExibidas) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', height: 80),
                      const SizedBox(width: 8),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: const Icon(Icons.timer, color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PomodoroTimerScreen()));
                        },
                      ),
                      IconButton(
                        icon: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: const Icon(Icons.show_chart, color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthMetricsScreen()));
                        },
                      ),
                      IconButton(
                        icon: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: const Icon(Icons.book, color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const JournalScreen()));
                        },
                      ),
                      IconButton(
                        icon: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: const Icon(Icons.person, color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Buscar',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                  contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Aba expansível de filtros
            StatefulBuilder(
              builder: (context, setFilterState) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setFilterState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF3CA6F6))),
                            Icon(_showFilters ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF3CA6F6)),
                          ],
                        ),
                      ),
                    ),
                    if (_showFilters) ...[
                      const SizedBox(height: 10),
                      // Filtros de prioridade
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('Todas Prioridades'),
                              selected: selectedPriority == null,
                              selectedColor: Colors.blue[100],
                              backgroundColor: Colors.grey[200],
                              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                              onSelected: (selected) {
                                setState(() {
                                  selectedPriority = null;
                                  _filterTasks();
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            ...['Alta', 'Média', 'Baixa'].map((priority) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(priority),
                                selected: selectedPriority == priority,
                                selectedColor: Colors.blue[100],
                                backgroundColor: Colors.grey[200],
                                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                                onSelected: (selected) {
                                  setState(() {
                                    selectedPriority = selected ? priority : null;
                                    _filterTasks();
                                  });
                                },
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Filtros de categoria
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('Todas Categorias'),
                              selected: selectedCategory == null,
                              selectedColor: Colors.blue[100],
                              backgroundColor: Colors.grey[200],
                              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                              onSelected: (selected) {
                                setState(() {
                                  selectedCategory = null;
                                  _filterTasks();
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            ..._categories.map((category) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category),
                                selected: selectedCategory == category,
                                selectedColor: Colors.blue[100],
                                backgroundColor: Colors.grey[200],
                                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                                onSelected: (selected) {
                                  setState(() {
                                    selectedCategory = selected ? category : null;
                                    _filterTasks();
                                  });
                                },
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 10),
            // Lista de tarefas
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tarefasExibidas.length,
              itemBuilder: (context, index) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _buildTaskItem(tarefasExibidas[index]),
                );
              },
            ),
            const SizedBox(height: 80), // Espaço para o botão no rodapé
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(TarefaModel tarefa) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
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
        leading: Checkbox(
          value: tarefa.isCompleted,
          activeColor: const Color(0xFF3CA6F6),
          onChanged: (bool? value) async {
            if (value != null) {
              final tarefaAtualizada = tarefa.copyWith(isCompleted: value);
              await _tarefaService.editarTarefa(tarefaAtualizada);
              // Animação simples ao marcar como concluída
              await Future.delayed(const Duration(milliseconds: 200));
              _fetchTasks();
            }
          },
        ),
        title: Text(
          tarefa.nome,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            decoration: tarefa.isCompleted ? TextDecoration.lineThrough : null,
            color: tarefa.isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.flag,
                  size: 18,
                  color: _getPriorityColor(tarefa.prioridade),
                ),
                const SizedBox(width: 4),
                Text(
                  tarefa.prioridade,
                  style: TextStyle(
                    color: _getPriorityColor(tarefa.prioridade),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (tarefa.category != null) ...[
                  const SizedBox(width: 10),
                  Icon(
                    Icons.category,
                    size: 18,
                    color: Colors.blueGrey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tarefa.category!,
                    style: TextStyle(
                      color: Colors.blueGrey[400],
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
            if (tarefa.dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy', 'pt_BR').format(tarefa.dueDate!),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF3CA6F6)),
              onPressed: () => _showEditTaskDialog(context, tarefa),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _deleteTask(tarefa.id!),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTask(String tarefaId) async {
    try {
      await _tarefaService.deletarTarefa(tarefaId);
      _fetchTasks();
    } catch (e) {
      print('Erro ao deletar tarefa: $e');
    }
  }

  Color _getPriorityColor(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return Colors.red;
      case 'Média':
        return Colors.orange;
      case 'Baixa':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showEditTaskDialog(BuildContext context, TarefaModel tarefa) {
    String nomeEditado = tarefa.nome;
    String prioridadeEditada = tarefa.prioridade;
    bool isCompletedEdit = tarefa.isCompleted;
    DateTime? _selectedDueDateEdit = tarefa.dueDate;
    String? _selectedCategoryEdit = tarefa.category;
    List<int> _dialogRepetitionDays = List.from(tarefa.repetitionDays ?? []);

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
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
                      controller: TextEditingController(text: nomeEditado),
                      decoration: InputDecoration(
                        labelText: "Nome da tarefa",
                        prefixIcon: const Icon(Icons.edit_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: (value) => nomeEditado = value,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField(
                      value: prioridadeEditada,
                      items: ["Alta", "Média", "Baixa"]
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (val) => prioridadeEditada = val!,
                      decoration: InputDecoration(
                        labelText: "Prioridade",
                        prefixIcon: const Icon(Icons.flag),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryEdit,
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => _selectedCategoryEdit = val,
                      decoration: InputDecoration(
                        labelText: "Categoria",
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Repetir em (Opcional)",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: _weekdaysMap.entries.map((entry) {
                        final int dayIndex = entry.key;
                        final String dayName = entry.value;
                        final bool isSelected = _dialogRepetitionDays.contains(dayIndex);
                        return ChoiceChip(
                          label: Text(dayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setInnerState(() {
                              if (selected) {
                                _dialogRepetitionDays.add(dayIndex);
                              } else {
                                _dialogRepetitionDays.remove(dayIndex);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    StatefulBuilder(
                      builder: (context, setInnerState) {
                        return InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDueDateEdit ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                            );
                            if (picked != null) {
                              setInnerState(() {
                                _selectedDueDateEdit = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Data de Vencimento (Opcional)",
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            child: Text(
                              _selectedDueDateEdit == null
                                  ? 'Selecionar Data'
                                  : DateFormat('dd/MM/yyyy', 'pt_BR').format(_selectedDueDateEdit!),
                              style: TextStyle(
                                color: _selectedDueDateEdit == null ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: isCompletedEdit,
                          onChanged: (bool? newValue) {
                            if (newValue != null) {
                              isCompletedEdit = newValue;
                            }
                          },
                        ),
                        const Text('Concluída'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (nomeEditado.isNotEmpty) {
                          final tarefaAtualizada = tarefa.copyWith(
                            nome: nomeEditado,
                            prioridade: prioridadeEditada,
                            data: tarefa.data,
                            isCompleted: isCompletedEdit,
                            dueDate: _selectedDueDateEdit,
                            category: _selectedCategoryEdit,
                            repetitionDays: _dialogRepetitionDays.isNotEmpty ? _dialogRepetitionDays : null,
                          );
                          await _tarefaService.editarTarefa(tarefaAtualizada);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                          _fetchTasks();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3CA6F6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('SALVAR'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    String nomeTarefa = '';
    String prioridade = 'Média';
    DateTime? _selectedDueDate;
    String? _selectedCategory;
    List<int> _dialogRepetitionDays = List.from(_selectedRepetitionDays);

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
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
                          fontSize: 22,
                          color: Color(0xFF3CA6F6)),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Nome da tarefa",
                        prefixIcon: const Icon(Icons.edit_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      style: const TextStyle(fontSize: 18),
                      onChanged: (value) => nomeTarefa = value,
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField(
                      value: prioridade,
                      items: ["Alta", "Média", "Baixa"]
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (val) => prioridade = val!,
                      decoration: InputDecoration(
                        labelText: "Prioridade",
                        prefixIcon: const Icon(Icons.flag),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => _selectedCategory = val,
                      decoration: InputDecoration(
                        labelText: "Categoria",
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Repetir em (Opcional)",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: _weekdaysMap.entries.map((entry) {
                        final int dayIndex = entry.key;
                        final String dayName = entry.value;
                        final bool isSelected = _dialogRepetitionDays.contains(dayIndex);
                        return ChoiceChip(
                          label: Text(dayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setInnerState(() {
                              if (selected) {
                                _dialogRepetitionDays.add(dayIndex);
                              } else {
                                _dialogRepetitionDays.remove(dayIndex);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    StatefulBuilder(
                      builder: (context, setInnerState) {
                        return InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDueDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                            );
                            if (picked != null) {
                              setInnerState(() {
                                _selectedDueDate = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Data de Vencimento (Opcional)",
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            child: Text(
                              _selectedDueDate == null
                                  ? 'Selecionar Data'
                                  : DateFormat('dd/MM/yyyy', 'pt_BR').format(_selectedDueDate!),
                              style: TextStyle(
                                color: _selectedDueDate == null ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: () {
                        if (nomeTarefa.isNotEmpty) {
                          Navigator.pop(context); // FECHA O DIÁLOGO ANTES DO AWAIT
                          _tarefaService.adicionarTarefa(
                            TarefaModel(
                              nome: nomeTarefa,
                              prioridade: prioridade,
                              data: DateTime.now(),
                              dueDate: _selectedDueDate,
                              category: _selectedCategory,
                              repetitionDays: _dialogRepetitionDays.isNotEmpty ? _dialogRepetitionDays : null,
                            ),
                          ).then((_) => _fetchTasks());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3CA6F6),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('ADICIONAR TAREFA'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _fetchTasks() {
    setState(() {
    });
    _tarefaService.getTarefas().then((tarefas) {
      setState(() {
        _allTasks = tarefas;
        _filterTasks();
      });
    });
  }
}