import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showLoginForm = false;
  bool _showRegisterForm = false;
  String nome = '', email = '', senha = '', peso = '', altura = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 70),
                  const SizedBox(height: 16),
                  Container(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
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
                    child: _showLoginForm
                        ? _loginForm()
                        : _showRegisterForm
                            ? _registerForm()
                            : _telaInicial(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _telaInicial() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Sua ', style: TextStyle(fontSize: 26)),
              TextSpan(
                  text: 'saúde',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3CA6F6), fontSize: 26)),
              TextSpan(text: ', sua\n', style: TextStyle(fontSize: 26)),
              TextSpan(
                  text: 'escolha',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 26)),
              TextSpan(text: ', seu\n', style: TextStyle(fontSize: 26)),
              TextSpan(
                  text: 'ritmo',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3CA6F6), fontSize: 26)),
              TextSpan(text: '. Bora\n', style: TextStyle(fontSize: 26)),
              TextSpan(
                  text: 'evoluir?',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 26)),
            ],
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 12),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/login_ilustracao.png',
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _botao("ENTRAR", Icons.email, const Color(0xFF63B6F5), const Color(0xFF004487), onPressed: () {
          setState(() {
            _showLoginForm = true;
            _showRegisterForm = false;
          });
        }),
        const SizedBox(height: 6),
        _botaoGoogle(),
        const SizedBox(height: 6),
        _botaoApple(),
        const SizedBox(height: 6),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _showRegisterForm = true;
                _showLoginForm = false;
              });
            },
            child: const Text(
              'Ainda não tem conta? Criar conta',
              style: TextStyle(
                color: Color(0xFF3CA6F6),
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _input('E-mail', Icons.email, (v) => email = v!, keyboard: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _input('Senha', Icons.lock, (v) => senha = v!, obscure: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                _formKey.currentState?.save();
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signInWithEmail(email, senha);
                // O Consumer no main.dart cuida da navegação
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
                'Entrar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _showLoginForm = false;
              });
            },
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  Widget _registerForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _input('Nome', Icons.person, (v) => nome = v!),
          const SizedBox(height: 16),
          _input('E-mail', Icons.email, (v) => email = v!, keyboard: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _input('Senha', Icons.lock, (v) => senha = v!, obscure: true),
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
                // Aqui você pode implementar o cadastro real
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
                'Criar conta',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _showRegisterForm = false;
              });
            },
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, IconData icon, Function(String?) onSaved, {TextInputType keyboard = TextInputType.text, bool obscure = false}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      keyboardType: keyboard,
      obscureText: obscure,
      onSaved: onSaved,
    );
  }

  Widget _botao(String label, IconData icon, Color color, Color textColor, {required VoidCallback onPressed}) {
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
        onPressed: () async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.signInWithGoogle();
        },
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
        onPressed: () async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.signInWithApple();
        },
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
