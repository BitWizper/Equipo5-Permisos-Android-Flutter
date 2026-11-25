# Permisos Equipo 5

Aplicacion Flutter para Android que solicita y muestra el estado de:

- Bluetooth: `Scan` y `Connect` (no escanea, empareja ni conecta dispositivos).
- Notificaciones: `POST_NOTIFICATIONS` (Android 13+; no envia notificaciones).
- Reminders: `Permission.reminders` (solo iOS; Android no tiene un permiso
  nativo equivalente y la solicitud no muestra un dialogo del sistema. El
  plugin puede responder `granted` en Android porque no hay permiso que
  gestionar; eso no concede acceso a recordatorios).

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
El boton **Solicitar permiso de Reminders** permite comprobar la respuesta del
plugin; en Android se indica **No disponible en Android** y, tras la solicitud,
tambien se muestra la respuesta del plugin, que no implica acceso real.
