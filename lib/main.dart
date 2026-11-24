import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const BluetoothPermissionsApp());
}

class BluetoothPermissionsApp extends StatelessWidget {
  const BluetoothPermissionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permisos Bluetooth',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const BluetoothPermissionsPage(),
    );
  }
}

class BluetoothPermissionsPage extends StatefulWidget {
  const BluetoothPermissionsPage({super.key});

  @override
  State<BluetoothPermissionsPage> createState() =>
      _BluetoothPermissionsPageState();
}

class _BluetoothPermissionsPageState extends State<BluetoothPermissionsPage> {
  PermissionStatus? _scanStatus;
  PermissionStatus? _connectStatus;
  bool _isRequesting = false;
  String? _errorMessage;

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
      appBar: AppBar(title: const Text('Permisos Bluetooth')),
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
                'Esta aplicación solo solicita permisos Bluetooth. '
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
