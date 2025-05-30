import 'package:flutter/material.dart';
import 'progress_screen.dart';
import '/models/tarefa_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final tarefaService = TarefaService();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final tarefasFiltradas = tarefaService
        .todasTarefas()
        .where((t) => t.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', height: 32),
                      const SizedBox(width: 8),
                      const Text(
                        'Focusly',
                        style: TextStyle(
                          color: Color(0xFF3CA6F6),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Minhas atividades', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar tarefas...',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (searchQuery.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tarefasFiltradas.map((tarefa) {
                        return ListTile(
                          leading: Icon(Icons.task),
                          title: Text(tarefa),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(child: Image.asset('assets/atividade.png', height: 120)),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Workout levels', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Beginner', 'Amateur', 'Professional', 'Expert'].map(_chip).toList(),
                  ),
                ],
              ),
            ),

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
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProgressScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3CA6F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Seu Progresso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, {Color color = Colors.blue, bool gradient = false, bool chart = false}) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: gradient ? null : Colors.white,
        gradient: gradient
            ? LinearGradient(colors: [Color(0xFF3CA6F6), Color(0xFF005B9F)], begin: Alignment.topLeft, end: Alignment.bottomRight)
            : null,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: gradient ? Colors.white : Colors.black)),
          ]),
          const SizedBox(height: 8),
          chart
              ? Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      height: 24,
                      width: 60,
                      child: CustomPaint(painter: _FakeChartPainter(color: color)),
                    ),
                  ),
                )
              : Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: gradient ? Colors.white : Colors.black)),
        ],
      ),
    );
  }
}

class _FakeChartPainter extends CustomPainter {
  final Color color;
  _FakeChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(128)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.2, size.height * 0.2);
    path.lineTo(size.width * 0.4, size.height * 0.8);
    path.lineTo(size.width * 0.6, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.6);
    path.lineTo(size.width, size.height * 0.4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
