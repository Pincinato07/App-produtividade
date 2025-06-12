import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.user.weight?.toString() ?? '');
    _heightController = TextEditingController(text: widget.user.height?.toString() ?? '');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informações Pessoais',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: 'Peso (kg)',
                          prefixIcon: Icon(Icons.monitor_weight),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu peso';
                          }
                          final weight = double.tryParse(value);
                          if (weight == null || weight <= 0 || weight > 300) {
                            return 'Peso inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _heightController,
                        decoration: const InputDecoration(
                          labelText: 'Altura (cm)',
                          prefixIcon: Icon(Icons.height),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua altura';
                          }
                          final height = double.tryParse(value);
                          if (height == null || height <= 0 || height > 300) {
                            return 'Altura inválida';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3CA6F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('SALVAR ALTERAÇÕES'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final weight = double.parse(_weightController.text);
      final height = double.parse(_heightController.text);

      final updatedUser = widget.user.copyWith(
        weight: weight,
        height: height,
      );

      try {
        await context.read<AuthProvider>().updateUserProfile(updatedUser);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar perfil: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
} 