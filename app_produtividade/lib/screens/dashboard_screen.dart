import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tarefa_service.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final tarefaService = TarefaService();
  String searchQuery = '';
  String? selectedPriority; // Renomeado de selectedLevel para selectedPriority

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final todasTarefas = tarefaService.todasTarefas();
    final tarefasFiltradas = todasTarefas
        .where((tarefa) =>
            tarefa.nome.toLowerCase().contains(searchQuery.toLowerCase()) &&
            (selectedPriority == null || tarefa.prioridade == selectedPriority))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
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
                ),
                const Divider(height: 1),
                const SizedBox(height: 8),
                const Text(
                  'Minhas atividades',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                // Campo de pesquisa
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: 'Buscar',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Imagem
                Center(
                  child: Image.asset(
                    'assets/atividade.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Prioridades',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                // Chips ajustados com clique
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ['Alta', 'Média', 'Baixa'].map((label) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: selectedPriority == label,
                            onSelected: (selected) {
                              setState(() {
                                selectedPriority = selected ? label : null;
                              });
                            },
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            backgroundColor: Colors.grey[100],
                            selectedColor: const Color(0xFF3CA6F6),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: selectedPriority == label
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Dashboards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(child: _metricCard('Passos', '4312', Icons.directions_walk, color: Color(0xFF3CA6F6))),
                      SizedBox(width: 12),
                      Expanded(child: _metricCard('Sono', '08:00', Icons.bedtime, color: Color(0xFF3CA6F6), gradient: true)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: _metricCard('Coração', '77 bpm', Icons.favorite, color: Color(0xFF3CA6F6), chart: true)),
                      SizedBox(width: 12),
                      Expanded(child: _metricCard('Calorias', '1250 kcal', Icons.local_fire_department, color: Color(0xFF3CA6F6), chart: true)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Tarefas filtradas
                if (searchQuery.isNotEmpty || selectedPriority != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tarefas Filtradas',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ...tarefasFiltradas.map((tarefa) {
                        return ListTile(
                          leading: const Icon(Icons.task),
                          title: Text(tarefa.toString()),
                        );
                      }).toList(),
                    ],
                  ),
                const SizedBox(height: 16),
                // Botão "Meu Progresso"
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/progress');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004487),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Meu Progresso'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, {Color color = Colors.blue, bool gradient = false, bool chart = false}) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: gradient ? null : Colors.white,
        gradient: gradient ? LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: gradient ? Colors.white : color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: gradient ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: gradient ? Colors.white : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (chart)
              const SizedBox(height: 8),
            if (chart)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: gradient ? Colors.white.withOpacity(0.3) : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}