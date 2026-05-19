# Motores OEX

Aplicacion Flutter para Android que publica motores de ajedrez UCI mediante el formato OEX (Open Exchange), de forma que GUIs compatibles como SimplePGN puedan detectarlos e importarlos.

## Motores publicados por OEX

- Stockfish 18
- RubiChess 20240817

Los binarios expuestos por la app viven en android/app/src/main/assets/engines y se sirven a traves de un ContentProvider Android usando la authority definida en el AndroidManifest.

## Licencia

Este proyecto se distribuye bajo GPL-3.0.

Al redistribuir la app o sus APKs debes acompañar la licencia GPL-3.0 y ofrecer el codigo fuente correspondiente de esta app y de la forma exacta en que distribuyes los binarios incluidos.

## Revision de compatibilidad

- Stockfish: GitHub declara GPL-3.0 y el proyecto distribuye Copying.txt con la GPL v3.
- RubiChess: GitHub declara GPL-3.0 en el archivo copying del repositorio.

Con la composicion actual, GPL-3.0 es una licencia compatible y adecuada para la app contenedora.

## Build

Para generar un APK de depuracion:

```bash
flutter build apk --debug
```
