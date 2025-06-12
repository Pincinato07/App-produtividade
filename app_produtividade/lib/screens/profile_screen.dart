import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Nenhum usuário logado',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                        child: const Text('Fazer Login'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: const Color(0xFF3CA6F6),
                                    child: Text(
                                      user.name != null && user.name!.isNotEmpty
                                          ? user.name!.substring(0, 1).toUpperCase()
                                          : user.email.isNotEmpty
                                              ? user.email.substring(0, 1).toUpperCase()
                                              : '', // Fallback if both name and email are empty
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name != null && user.name!.isNotEmpty
                                              ? user.name!
                                              : 'Nome Não Informado', // Display a default if name is null
                                          style: Theme.of(context).textTheme.headlineSmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.email,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 32),
                              if (user.weight != null && user.height != null) ...[
                                _buildInfoRow(
                                  context,
                                  'Peso',
                                  '${user.weight} kg',
                                  Icons.monitor_weight,
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  context,
                                  'Altura',
                                  '${user.height} cm',
                                  Icons.height,
                                ),
                                const SizedBox(height: 16),
                              ],
                              _buildInfoRow(
                                context,
                                'Método de Login',
                                user.authProvider.name.toUpperCase(),
                                Icons.login,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfileScreen(user: user),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('EDITAR INFORMAÇÕES'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3CA6F6),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await context.read<AuthProvider>().signOut();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/register');
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('SAIR DA CONTA'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF3CA6F6)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }
} 