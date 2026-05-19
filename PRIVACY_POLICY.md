# Política de Privacidad — Motores OEX

**Última actualización:** 24 de abril de 2026

Esta Política de Privacidad describe cómo trato la información del usuario en mi aplicación **Motores OEX** (en adelante, "la App"). La App es un proveedor de motores de ajedrez UCI conforme al estándar Open Exchange (OEX) para Android.

## 1. Responsable

- **Aplicación:** Motores OEX (`motor_oex`)
- **Licencia:** GPL-3.0
- **Repositorio:** Proyecto de código abierto

Si tienes cualquier consulta relacionada con esta política, puedes abrir una incidencia en el repositorio público del proyecto y la atenderé personalmente.

## 2. Información que recopilo

**No recopilo, almaceno ni transmito ningún dato personal del usuario.**

En particular, **no** recojo:

- Tu nombre, correo electrónico, número de teléfono ni ningún identificador personal.
- Identificadores de dispositivo (IMEI, Android ID, Advertising ID, etc.).
- Tu ubicación geográfica (ni precisa ni aproximada).
- Tu lista de contactos, calendario, fotos, micrófono o cámara.
- Tu historial de partidas, posiciones de ajedrez ni movimientos analizados.
- Datos de uso, métricas de telemetría, analítica ni informes de fallos automáticos.

## 3. Permisos del sistema

No solicito permisos sensibles de Android (ni ubicación, ni almacenamiento externo, ni red, ni cámara, ni micrófono).

Para que la App funcione como proveedor OEX, únicamente expongo:

- Una **Activity** con el intent `intent.chess.provider.ENGINE` para que las GUIs de ajedrez compatibles con OEX puedan descubrirla.
- Un **ContentProvider** de solo lectura que devuelve la lista de motores incluidos (nombre, archivo, arquitecturas soportadas).
- Los binarios nativos de los motores (por ejemplo, Stockfish 18) ubicados en el directorio nativo de la aplicación.

Las GUIs de ajedrez de terceros que utilicen estos motores se ejecutan en su propio proceso y bajo su propia política de privacidad. No controlo ni recibo información sobre el uso que dichas GUIs hagan de los motores.

## 4. Conexiones de red

La App **no realiza conexiones a Internet**. Los motores de ajedrez incluidos se ejecutan localmente en tu dispositivo y no envío información a ningún servidor.

## 5. Servicios de terceros

No integro SDKs de terceros de analítica, publicidad, redes sociales, notificaciones push ni informes de fallos.

## 6. Datos de menores

Como no recopilo información alguna, tampoco recopilo datos de menores de edad.

## 7. Seguridad

Al no recopilar ni transmitir datos personales, no existe riesgo de filtración de datos por mi parte. Los binarios de los motores los distribuyo tal y como aparecen en sus respectivos proyectos de código abierto.

## 8. Cambios en esta política

Si modifico esta Política de Privacidad, publicaré los cambios actualizando este archivo en el repositorio del proyecto, junto con una nueva fecha de "Última actualización".

## 9. Contacto

Para cualquier pregunta o aclaración sobre esta política, abre una incidencia (issue) en el repositorio público del proyecto Motores OEX y te responderé.
