import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/password_provider.dart';
import '../widgets/password_list_item.dart';
import 'add_password_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Contraseñas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Consumer<PasswordProvider>(
        builder: (context, passwordProvider, child) {
          if (!passwordProvider.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (passwordProvider.passwords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay contraseñas guardadas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text('Agregar Contraseña'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: passwordProvider.passwords.length,
            itemBuilder: (context, index) {
              final password = passwordProvider.passwords[index];
              return PasswordListItem(password: password);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPasswordScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
