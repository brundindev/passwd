import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/password_provider.dart';
import 'add_password_screen.dart';
import '../models/password_entry.dart';

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

          return FutureBuilder<List<PasswordEntry>>(
            future: passwordProvider.loadPasswords(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final passwords = snapshot.data ?? [];

              if (passwords.isEmpty) {
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
                itemCount: passwords.length,
                itemBuilder: (context, index) {
                  final password = passwords[index];
                  return ListTile(
                    title: Text(password.title),
                    subtitle: Text(password.username),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        passwordProvider.deletePassword(password.id);
                      },
                    ),
                  );
                },
              );
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
