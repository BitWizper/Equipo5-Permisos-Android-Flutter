import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const PermissionsApp());
}

class PermissionsApp extends StatelessWidget {
  const PermissionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permisos Equipo 5',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const PermissionsPage(),
    );
  }
}

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  PermissionStatus? _scanStatus;
  PermissionStatus? _connectStatus;
  bool _isRequesting = false;
  String? _errorMessage;

  // --- Notificaciones (Persona 1) ---
  PermissionStatus? _notificationStatus;
  bool _isRequestingNotification = false;
  String? _notificationError;

  // --- Reminders (Persona 3) ---
  PermissionStatus? _remindersStatus;
  bool _isRequestingReminders = false;
  String? _remindersError;

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
  }

  /// Lee el estado actual sin mostrar ningún diálogo.
  Future<void> _loadNotificationStatus() async {
    final status = await Permission.notification.status;
    if (!mounted) return;
    setState(() => _notificationStatus = status);
  }

  /// En Android 13+ (API 33) muestra el diálogo del sistema.
  /// En Android 12 o inferior el permiso se concede automáticamente.
  Future<void> _requestNotificationPermission() async {
    setState(() {
      _isRequestingNotification = true;
      _notificationError = null;
    });

    try {
      final status = await Permission.notification.request();
      if (!mounted) return;
      setState(() => _notificationStatus = status);
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _notificationError =
            'No se pudo solicitar el permiso de notificaciones: '
            '${error.message}';
      });
    } finally {
      if (mounted) {
        setState(() => _isRequestingNotification = false);
      }
    }
  }

  Future<void> _requestRemindersPermission() async {
    setState(() {
      _isRequestingReminders = true;
      _remindersError = null;
    });

    try {
      final status = await Permission.reminders.request();
      if (!mounted) return;
      setState(() => _remindersStatus = status);
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _remindersError =
            'No se pudo consultar el permiso de Reminders: ${error.message}';
      });
    } finally {
      if (mounted) {
        setState(() => _isRequestingReminders = false);
      }
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isRequesting = true;
      _errorMessage = null;
    });

    try {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      if (!mounted) return;
      setState(() {
        _scanStatus = statuses[Permission.bluetoothScan];
        _connectStatus = statuses[Permission.bluetoothConnect];
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'No se pudieron solicitar los permisos: ${error.message}';
      });
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  String _statusLabel(PermissionStatus? status) {
    if (status == null) return 'Sin solicitar';
    if (status.isGranted) return 'Concedido';
    if (status.isPermanentlyDenied) return 'Denegado permanentemente';
    if (status.isDenied) return 'Denegado';
    if (status.isRestricted) return 'Restringido';
    return 'No disponible';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permisos Equipo 5')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.bluetooth, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Bluetooth: la app solo solicita los permisos Scan y Connect. '
                'No busca, empareja ni conecta dispositivos.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _PermissionStatus(
                label: 'Bluetooth Scan',
                status: _statusLabel(_scanStatus),
              ),
              _PermissionStatus(
                label: 'Bluetooth Connect',
                status: _statusLabel(_connectStatus),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isRequesting ? null : _requestPermissions,
                child: Text(
                  _isRequesting ? 'Solicitando...' : 'Solicitar permisos',
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),
              const Icon(Icons.notifications_active, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Notificaciones: la app solicita el permiso POST_NOTIFICATIONS '
                '(Android 13 o superior). No envía ninguna notificación.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _PermissionStatus(
                label: 'Notificaciones',
                status: _statusLabel(_notificationStatus),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isRequestingNotification
                    ? null
                    : _requestNotificationPermission,
                child: Text(
                  _isRequestingNotification
                      ? 'Solicitando...'
                      : 'Solicitar permiso de notificaciones',
                ),
              ),
              if (_notificationStatus?.isPermanentlyDenied ?? false) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: openAppSettings,
                  child: const Text('Abrir ajustes de la app'),
                ),
              ],
              if (_notificationError != null) ...[
                const SizedBox(height: 16),
                Text(
                  _notificationError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),
              const Icon(Icons.event_note, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Reminders: permiso para acceder a los recordatorios del '
                'dispositivo (iOS). Android no tiene un permiso nativo '
                'equivalente ni muestra un diálogo. permission_handler puede '
                'responder Concedido porque no hay permiso Android que '
                'gestionar; esto no significa que la app tenga acceso a '
                'recordatorios.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _PermissionStatus(
                label: 'Reminders',
                status: defaultTargetPlatform == TargetPlatform.android
                    ? _remindersStatus == null
                          ? 'No disponible en Android'
                          : 'No disponible (plugin: '
                                '${_statusLabel(_remindersStatus)})'
                    : _statusLabel(_remindersStatus),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isRequestingReminders
                    ? null
                    : _requestRemindersPermission,
                child: Text(
                  _isRequestingReminders
                      ? 'Solicitando...'
                      : 'Solicitar permiso de Reminders',
                ),
              ),
              if (_remindersError != null) ...[
                const SizedBox(height: 16),
                Text(
                  _remindersError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionStatus extends StatelessWidget {
  const _PermissionStatus({required this.label, required this.status});

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(status),
    );
  }
}
