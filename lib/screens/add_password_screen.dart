import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/password_entry.dart';
import '../providers/password_provider.dart';
import '../services/password_generator.dart';
import '../services/totp_service.dart';

class AddPasswordScreen extends StatefulWidget {
  final PasswordEntry? passwordToEdit;

  const AddPasswordScreen({
    super.key,
    this.passwordToEdit,
  });

  @override
  State<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _totpController;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.passwordToEdit?.title);
    _usernameController = TextEditingController(text: widget.passwordToEdit?.username);
    _passwordController = TextEditingController(text: widget.passwordToEdit?.password);
    _totpController = TextEditingController(text: widget.passwordToEdit?.totpSecret);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _totpController.dispose();
    super.dispose();
  }

  void _generatePassword() {
    final password = PasswordGenerator.generateRandomPassword();
    _passwordController.text = password;
  }

  void _generateTOTPSecret() {
    final secret = TOTPService.generateSecretKey();
    _totpController.text = secret;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.passwordToEdit == null ? 'Nueva Contraseña' : 'Editar Contraseña'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                icon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Por favor ingrese un título';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                icon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Por favor ingrese un usuario';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                icon: const Icon(Icons.lock),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _generatePassword,
                    ),
                  ],
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Por favor ingrese una contraseña';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totpController,
              decoration: InputDecoration(
                labelText: 'Secreto TOTP (opcional)',
                icon: const Icon(Icons.security),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _generateTOTPSecret,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final password = PasswordEntry(
                    id: widget.passwordToEdit?.id ?? DateTime.now().toString(),
                    title: _titleController.text,
                    username: _usernameController.text,
                    password: _passwordController.text,
                    totpSecret: _totpController.text.isEmpty ? null : _totpController.text,
                    createdAt: widget.passwordToEdit?.createdAt ?? DateTime.now(),
                    modifiedAt: DateTime.now(),
                  );

                  if (widget.passwordToEdit != null) {
                    context.read<PasswordProvider>().updatePassword(
                          widget.passwordToEdit!.id,
                          password,
                        );
                  } else {
                    context.read<PasswordProvider>().addPassword(password);
                  }

                  Navigator.pop(context);
                }
              },
              child: Text(
                widget.passwordToEdit == null ? 'Guardar' : 'Actualizar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
