import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importe para formatação de datas
import 'package:app_produtividade/models/tarefa_model.dart';
import 'package:app_produtividade/services/tarefa_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final TarefaService _tarefaService = TarefaService();
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  List<TarefaModel> _tarefasHoje = [];
  Map<DateTime, List<TarefaModel>> _allTasksInMonth = {}; // Novo mapa para todas as tarefas do mês
  bool _isLoadingTasks = true;
  DateTime? _selectedDueDate;
  String? _selectedCategory;
  String? _selectedFilterCategory;
  List<int> _selectedRepetitionDays = []; // Novo: Dias da semana selecionados para repetição

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

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day);
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    _fetchTasksForCurrentMonth(); // Carregar todas as tarefas para o mês atual
  }

  Future<void> _fetchTasksForCurrentMonth() async {
    setState(() {
      _isLoadingTasks = true;
    });

    try {
      final tarefas = await _tarefaService.getTarefas();
      final tarefasDoMes = tarefas.where((tarefa) {
        // Verifica se a tarefa tem data definida E está dentro do mês atual
        // OU se ela tem dias de repetição definidos
        final tarefaDate = DateTime(
            tarefa.data.year, tarefa.data.month, tarefa.data.day);

        bool isWithinMonth = tarefaDate.isAfter(_currentMonth.subtract(const Duration(days: 1))) &&
            tarefaDate.isBefore(DateTime(_currentMonth.year, _currentMonth.month + 1, 1));

        // Se a tarefa tem dias de repetição, ela é relevante para todo o mês
        if (tarefa.repetitionDays != null && tarefa.repetitionDays!.isNotEmpty) {
          return true; // Considera a tarefa relevante para ser processada por todos os dias do mês
        }

        return isWithinMonth; // Para tarefas sem repetição, verifica a data normal
      }).toList();

      final tarefasPorDia = <DateTime, List<TarefaModel>>{};
      for (var tarefa in tarefasDoMes) {
        if (tarefa.repetitionDays != null && tarefa.repetitionDays!.isNotEmpty) {
          // Se a tarefa tem repetição, adicione-a a todos os dias aplicáveis do mês
          final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
          final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

          for (DateTime d = firstDayOfMonth; d.isBefore(lastDayOfMonth.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
            // Ajuste o dia da semana para corresponder ao padrão do Dart (1=Seg, 7=Dom)
            // O .weekday do Dart retorna 1 para segunda e 7 para domingo.
            // Se o repetitionDays usa 1 para segunda e 7 para domingo, a lógica está ok.
            // Certifique-se de que a enumeração corresponde.
            if (tarefa.repetitionDays!.contains(d.weekday)) {
              final dateKey = DateTime(d.year, d.month, d.day);
              tarefasPorDia[dateKey] = [...(tarefasPorDia[dateKey] ?? []), tarefa];
            }
          }
        } else {
          // Para tarefas sem repetição, adicione-as apenas à sua data específica
          final date = DateTime(
              tarefa.data.year, tarefa.data.month, tarefa.data.day);
          tarefasPorDia[date] = [...(tarefasPorDia[date] ?? []), tarefa];
        }
      }

      setState(() {
        _allTasksInMonth = tarefasPorDia;
        _filterTasksForSelectedDate();
        _isLoadingTasks = false;
      });
    } catch (e) {
      print('Erro ao buscar tarefas: $e');
      setState(() {
        _isLoadingTasks = false;
      });
    }
  }

  // Método para gerar todos os dias de um determinado mês
  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];
    for (int i = 0; i <= lastDayOfMonth.day - 1; i++) {
      days.add(firstDayOfMonth.add(Duration(days: i)));
    }
    return days;
  }


  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
    });
    _fetchTasksForCurrentMonth();
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
    });
    _fetchTasksForCurrentMonth();
  }

  // Calcula o progresso de tarefas completadas para o dia selecionado
  double _calculateProgress() {
    if (_tarefasHoje.isEmpty) return 0.0;
    final completedTasks = _tarefasHoje.where((t) => t.isCompleted).length;
    return completedTasks / _tarefasHoje.length;
  }

  // Retorna a quantidade de tarefas concluídas no dia selecionado
  int _getCompletedTasksCount() {
    return _tarefasHoje.where((t) => t.isCompleted).length;
  }

  void _filterTasksForSelectedDate() {
    // Pega todas as tarefas para o dia selecionado, incluindo as tarefas repetidas que foram pré-processadas
    List<TarefaModel> tarefasDoDia = _allTasksInMonth[_selectedDate] ?? [];

    if (_selectedFilterCategory != null) {
      tarefasDoDia = tarefasDoDia
          .where((tarefa) => tarefa.category == _selectedFilterCategory)
          .toList();
    }

    setState(() {
      _tarefasHoje = tarefasDoDia;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Remova as variáveis progresso e meta fixas, se não forem mais usadas
    // double progresso = 40;
    // double meta = 150;

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

              // Navegação do Mês
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: _goToPreviousMonth,
                    ),
                    Text(
                      DateFormat('MMMM y', 'pt_BR').format(_currentMonth),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: _goToNextMonth,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Dias da Semana (Rolável)
              SizedBox(
                height: 70, // Altura fixa para os cards de dia
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _getDaysInMonth(_currentMonth).length, // Exibir todos os dias do mês
                  itemBuilder: (context, index) {
                    final day = _getDaysInMonth(_currentMonth)[index];
                    bool isSelected = _selectedDate.year == day.year &&
                        _selectedDate.month == day.month &&
                        _selectedDate.day == day.day;
                    
                    final dateKey = DateTime(day.year, day.month, day.day);
                    final hasTasks = _allTasksInMonth.containsKey(dateKey) && (_allTasksInMonth[dateKey]?.isNotEmpty ?? false);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = day; // Atualiza o dia selecionado
                            _tarefasHoje = _allTasksInMonth[dateKey] ?? []; // Atualiza as tarefas do dia selecionado
                          });
                        },
                        onLongPress: () => _abrirAgendamento(context, day), // Passa a data selecionada
                          child: Container(
                            width: 60,
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
                                day.day.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                  color: isSelected ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                DateFormat('MMM', 'pt_BR').format(day), // Exibe o mês abreviado
                                  style: TextStyle(
                                    fontSize: 12,
                                  color:
                                      isSelected ? Colors.white : Colors.black54,
                                ),
                              ),
                              if (hasTasks) // Use a variável hasTasks aqui
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                  },
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
                      value: _calculateProgress(), // Substituído por progresso real
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      color: const Color(0xFF3CA6F6),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        '${_getCompletedTasksCount()} / ${_tarefasHoje.length} tarefas concluídas', // Substituído por valores reais
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
              if (_isLoadingTasks)
                const Center(child: CircularProgressIndicator())
              else if (_tarefasHoje.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Nenhuma tarefa para este dia.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tarefas do dia',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._tarefasHoje.map((tarefa) => _buildTaskItem(tarefa)),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Todas'),
                      selected: _selectedFilterCategory == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilterCategory = null;
                          _filterTasksForSelectedDate();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ..._categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedFilterCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilterCategory = selected ? category : null;
                              _filterTasksForSelectedDate();
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3CA6F6),
        onPressed: () {
          // Resetar _selectedDueDate antes de abrir o diálogo de nova tarefa
          setState(() {
            _selectedDueDate = null;
            _selectedCategory = null;
          });
          _abrirAgendamento(context, _selectedDate);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _abrirAgendamento(BuildContext context, DateTime selectedDate) async {
    String prioridade = 'Média';
    String nomeTarefa = '';
    DateTime? _selectedDueDate = this._selectedDueDate;
    String? _selectedCategory = this._selectedCategory;
    List<int> _dialogRepetitionDays = List.from(_selectedRepetitionDays); // Usar uma cópia para o diálogo

    await showDialog(
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
                        prefixIcon: const Icon(Icons.flag),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 16),
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
                            borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Adicionado: Seleção de Dias de Repetição
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
                                  borderRadius: BorderRadius.circular(16)),
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
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (nomeTarefa.isNotEmpty) {
                          final novaTarefa = TarefaModel(
                            nome: nomeTarefa,
                            prioridade: prioridade,
                            data: selectedDate,
                            dueDate: _selectedDueDate,
                            category: _selectedCategory,
                            repetitionDays: _dialogRepetitionDays.isNotEmpty ? _dialogRepetitionDays : null, // Salvar dias de repetição
                          );
                          await _tarefaService.adicionarTarefa(novaTarefa);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                          _fetchTasksForCurrentMonth();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3CA6F6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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

  Future<void> _showEditTaskDialog(
      BuildContext context, TarefaModel tarefa, DateTime selectedDate) async {
    String nomeEditado = tarefa.nome;
    String prioridadeEditada = tarefa.prioridade;
    bool isCompletedEdit = tarefa.isCompleted;
    DateTime? _selectedDueDateEdit = tarefa.dueDate;
    String? _selectedCategoryEdit = tarefa.category;
    List<int> _dialogRepetitionDays = List.from(tarefa.repetitionDays ?? []); // Carregar dias de repetição existentes

    await showDialog(
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
                    // Adicionado: Seleção de Dias de Repetição na Edição
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
                            repetitionDays: _dialogRepetitionDays.isNotEmpty ? _dialogRepetitionDays : null, // Salvar dias de repetição
                          );
                          await _tarefaService.editarTarefa(tarefaAtualizada);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                          _fetchTasksForCurrentMonth();
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

  Future<void> _deleteTask(String tarefaId) async {
    try {
      await _tarefaService.deletarTarefa(tarefaId);
      _fetchTasksForCurrentMonth();
    } catch (e) {
      print('Erro ao deletar tarefa: $e');
    }
  }

  Future<void> _toggleTaskCompletion(TarefaModel tarefa) async {
    try {
      final tarefaAtualizada = tarefa.copyWith(isCompleted: !tarefa.isCompleted);
      await _tarefaService.editarTarefa(tarefaAtualizada);
      _fetchTasksForCurrentMonth();
    } catch (e) {
      print('Erro ao atualizar status da tarefa: $e');
    }
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
              await _toggleTaskCompletion(tarefa);
              await Future.delayed(const Duration(milliseconds: 200));
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
              onPressed: () => _showEditTaskDialog(context, tarefa, _selectedDate),
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

  Color _getPriorityColor(String prioridade) {
    // Implemente a lógica para determinar a cor com base na prioridade
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
}