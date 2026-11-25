# Permisos Equipo 5

Aplicacion Flutter para Android que solicita y muestra el estado de:

- Bluetooth: `Scan` y `Connect` (no escanea, empareja ni conecta dispositivos).
- Notificaciones: `POST_NOTIFICATIONS` (Android 13+; no envia notificaciones).

## Ejecutar

Conecta un telefono Android con la depuracion USB activada y ejecuta:

```shell
flutter pub get
flutter run
```

En la pantalla, pulsa **Solicitar permisos** (Bluetooth) o **Solicitar permiso
de notificaciones** para mostrar la solicitud del sistema. Para probar las
notificaciones usa un dispositivo con Android 13 o superior; si el permiso queda
denegado permanentemente, aparece el boton **Abrir ajustes de la app**.
