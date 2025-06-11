class Tarefa {
  final String nome;
  final String prioridade;

  Tarefa({required this.nome, required this.prioridade});

  @override
  String toString() => nome;
}

class TarefaService {
  static final TarefaService _instancia = TarefaService._interna();
  factory TarefaService() => _instancia;

  final Map<int, List<Tarefa>> _tarefasPorDia = {};

  TarefaService._interna();

  List<Tarefa> getTarefas(int dia) {
    return _tarefasPorDia[dia] ?? [];
  }

  void adicionarTarefa(int dia, Tarefa tarefa) {
    if (!_tarefasPorDia.containsKey(dia)) {
      _tarefasPorDia[dia] = [];
    }
    _tarefasPorDia[dia]!.add(tarefa);
  }

  void editarTarefa(int dia, Tarefa tarefaAntiga, Tarefa tarefaNova) {
    if (_tarefasPorDia.containsKey(dia)) {
      final index = _tarefasPorDia[dia]!.indexOf(tarefaAntiga);
      if (index != -1) {
        _tarefasPorDia[dia]![index] = tarefaNova;
      }
    }
  }

  void removerTarefa(int dia, Tarefa tarefa) {
    if (_tarefasPorDia.containsKey(dia)) {
      _tarefasPorDia[dia]!.remove(tarefa);
    }
  }

  List<Tarefa> todasTarefas() {
    return _tarefasPorDia.values.expand((list) => list).toList();
  }
}