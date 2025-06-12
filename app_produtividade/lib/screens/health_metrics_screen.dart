import 'package:flutter/material.dart';

class HealthMetricsScreen extends StatelessWidget {
  const HealthMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Métricas de Saúde'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Métricas de Saúde',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: _metricCard('Passos', '4312', Icons.directions_walk, color: const Color(0xFF3CA6F6))),
                  const SizedBox(width: 12),
                  Expanded(child: _metricCard('Sono', '08:00', Icons.bedtime, color: const Color(0xFF3CA6F6), gradient: true)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                children: [
                  Expanded(child: _metricCard('Coração', '77 bpm', Icons.favorite, color: const Color(0xFF3CA6F6), chart: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _metricCard('Calorias', '1250 kcal', Icons.local_fire_department, color: const Color(0xFF3CA6F6), chart: true)),
                ],
              ),
            ),
            // Você pode adicionar mais métricas ou informações aqui
            const SizedBox(height: 24),
            const Text(
              'Histórico Recente',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            // Exemplo de lista para histórico (ainda estático)
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('2023-11-14: Passos: 4312, Sono: 8h'),
              subtitle: Text('Coração: 77bpm, Calorias: 1250kcal'),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('2023-11-13: Passos: 5500, Sono: 7.5h'),
              subtitle: Text('Coração: 75bpm, Calorias: 1300kcal'),
            ),
          ],
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