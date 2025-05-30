class TarefaService {
  static final TarefaService _instancia = TarefaService._interna();
  factory TarefaService() => _instancia;

  final Map<int, List<String>> _tarefasPorDia = {};

  TarefaService._interna();

  List<String> getTarefas(int dia) {
    return _tarefasPorDia[dia] ?? [];
  }

  void adicionarTarefa(int dia, String tarefa) {
    if (!_tarefasPorDia.containsKey(dia)) {
      _tarefasPorDia[dia] = [];
    }
    _tarefasPorDia[dia]!.add(tarefa);
  }

  List<String> todasTarefas() {
    return _tarefasPorDia.values.expand((list) => list).toList();
  }
}
