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
      backgroundColor: Colors.white, // ✅ fundo branco total
      body: Stack(
        children: [
          // Logo
          Positioned(
            top: 32,
            left: 32,
            child: Row(
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
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
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
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Sua ', style: TextStyle(fontSize: 36)),
              TextSpan(
                  text: 'saúde',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3CA6F6), fontSize: 36)),
              TextSpan(text: ', sua\n', style: TextStyle(fontSize: 36)),
              TextSpan(
                  text: 'escolha',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36)),
              TextSpan(text: ', seu\n', style: TextStyle(fontSize: 36)),
              TextSpan(
                  text: 'ritmo',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3CA6F6), fontSize: 36)),
              TextSpan(text: '. Bora\n', style: TextStyle(fontSize: 36)),
              TextSpan(
                  text: 'evoluir?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/login_ilustracao.png',
              height: 280,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 40),
        _botaoLogin(
          label: "ENTRAR",
          icon: Icons.email,
          color: const Color(0xFF63B6F5),
          textColor: const Color(0xFF004487),
          onPressed: () => setState(() => _showForm = true),
        ),
        const SizedBox(height: 16),
        _botaoGoogle(),
        const SizedBox(height: 16),
        _botaoApple(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _formulario() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _input('Nome', Icons.person, (v) => nome = v!),
          const SizedBox(height: 16),
          _input('E-mail', Icons.email, (v) => email = v!),
          const SizedBox(height: 16),
          _input('Peso (kg)', Icons.monitor_weight, (v) => peso = v!, keyboard: TextInputType.number),
          const SizedBox(height: 16),
          _input('Altura (cm)', Icons.height, (v) => altura = v!, keyboard: TextInputType.number),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                _formKey.currentState?.save();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => DashboardScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3CA6F6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, IconData icon, Function(String?) onSaved, {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      keyboardType: keyboard,
      onSaved: onSaved,
    );
  }

  Widget _botaoLogin({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
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
            Icon(icon, color: textColor),
            const SizedBox(width: 16),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _botaoGoogle() {
    return SizedBox(
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
            Image.asset('assets/google_logo.png', height: 28),
            const SizedBox(width: 16),
            const Text("GOOGLE"),
          ],
        ),
      ),
    );
  }

  Widget _botaoApple() {
    return SizedBox(
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
          children: const [
            Icon(Icons.apple, color: Colors.white, size: 28),
            SizedBox(width: 16),
            Text("APPLE"),
          ],
        ),
      ),
    );
  }
}
