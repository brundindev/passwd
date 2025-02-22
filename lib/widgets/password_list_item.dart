import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/password_entry.dart';
import '../services/totp_service.dart';

class PasswordListItem extends StatelessWidget {
  final PasswordEntry password;

  const PasswordListItem({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              // Implementar edición
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
          ),
          SlidableAction(
            onPressed: (context) {
              // Implementar eliminación
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Eliminar',
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            password.title[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(password.title),
        subtitle: Text(password.username),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (password.totpSecret != null)
              TOTPWidget(secret: password.totpSecret!),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: password.password));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contraseña copiada al portapapeles'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TOTPWidget extends StatefulWidget {
  final String secret;

  const TOTPWidget({
    super.key,
    required this.secret,
  });

  @override
  State<TOTPWidget> createState() => _TOTPWidgetState();
}

class _TOTPWidgetState extends State<TOTPWidget> {
  String? _currentCode;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateCode();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCode());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateCode() {
    final code = TOTPService.generateTOTP(widget.secret);
    if (code != _currentCode) {
      setState(() {
        _currentCode = code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        if (_currentCode != null) {
          Clipboard.setData(ClipboardData(text: _currentCode!));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código TOTP copiado al portapapeles'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Text(
        _currentCode ?? '------',
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 16,
        ),
      ),
    );
  }
}
