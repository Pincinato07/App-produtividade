import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showForm = false;
  String nome = '', email = '', peso = '', altura = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Logo no canto superior esquerdo
          Positioned(
            top: 32,
            left: 32,
            child: Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 32,
                ),
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
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _showForm ? _formulario() : _loginInicial(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginInicial() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Texto grande com quebras de linha
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Sua ', style: TextStyle(fontSize: 38)),
              TextSpan(
                  text: 'saúde',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3CA6F6), fontSize: 38)),
              TextSpan(text: ', sua\n', style: TextStyle(fontSize: 38)),
              TextSpan(
                  text: 'escolha',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 38)),
              TextSpan(text: ', seu\n', style: TextStyle(fontSize: 38)),
              TextSpan(
                  text: 'ritmo',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3CA6F6), fontSize: 38)),
              TextSpan(text: '. Bora\n', style: TextStyle(fontSize: 38)),
              TextSpan(
                  text: 'evoluir?',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 38)),
            ],
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 32),
        // Imagem maior
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/login_ilustracao.png',
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 40),
        // Botão Entrar com E-mail
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _showForm = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF63B6F5),
              foregroundColor: const Color(0xFF004487),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, left: 8.0),
                  child: Icon(Icons.email, color: Colors.black),
                ),
                Text("ENTRAR"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Botão Google
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => setState(() => _showForm = true),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF004487),
              side: const BorderSide(color: Color(0xFFE0E0E0)),
              padding: const EdgeInsets.symmetric(vertical: 18),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, left: 8.0),
                  child: Image.asset(
                    'assets/google_logo.png',
                    height: 28,
                    width: 28,
                  ),
                ),
                Text("GOOGLE"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Botão Apple
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _showForm = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only( left: 8.0),
                  child: Icon(Icons.apple, color: Colors.white, size: 28),
                ),
                Text("APPLE"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _formulario() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Nome'),
              onSaved: (value) => nome = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'E-mail'),
              onSaved: (value) => email = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Peso (kg)'),
              onSaved: (value) => peso = value!,
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Altura (cm)'),
              onSaved: (value) => altura = value!,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _formKey.currentState?.save();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => DashboardScreen()),
                );
              },
              child: const Text('Continuar'),
            )
          ],
        ),
      ),
    );
  }
}
