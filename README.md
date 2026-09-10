# Motores OEX

Aplicacion Flutter para Android que publica motores de ajedrez UCI mediante el formato OEX (Open Exchange), de forma que GUIs compatibles como SimplePGN puedan detectarlos e importarlos.

## Motores publicados por OEX

- Stockfish 19
- PlentyChess 7.0.65

Los binarios expuestos por la app se empaquetan como librerias nativas Android en `android/app/src/main/jniLibs` y se sirven a traves de un ContentProvider Android usando la authority definida en el AndroidManifest.

## Licencia

Este proyecto se distribuye bajo GPL-3.0.

Al redistribuir la app o sus APKs debes acompañar la licencia GPL-3.0 y ofrecer el codigo fuente correspondiente de esta app y de la forma exacta en que distribuyes los binarios incluidos.

## Revision de compatibilida

- Stockfish: GitHub declara GPL-3.0 y el proyecto distribuye Copying.txt con la GPL v3.
- PlentyChess: GitHub declara GPL-3.0 en el repositorio.

Con la composicion actual, GPL-3.0 es una licencia compatible y adecuada para la app contenedora.

## Build

Para generar un APK de depuracion:

```bash
flutter build apk --debug
```

### Compilar Stockfish 19 para Android

Requisitos: Android NDK 28.2.13676358, Bash, Make, curl, tar y shasum.

```bash
ANDROID_NDK_HOME="$HOME/Library/Android/sdk/ndk/28.2.13676358" \
	bash scripts/build_stockfish_android.sh
```

El script descarga la etiqueta oficial `sf_19` sin modificarla, verifica el
codigo fuente y la red NNUE, y genera `build/stockfish-19/libstockfish.so`.
Usa ARMv8-A basico (sin dotprod obligatorio), Android API 24, C++ estatico
y alineacion ELF de 16 KB. La red NNUE queda integrada en el ejecutable.
No sustituye automaticamente el motor de la app.

Para integrarlo, conserva una copia del motor anterior y copia el nuevo a
`android/app/src/main/jniLibs/arm64-v8a/libstockfish.so`. Este binario esta
ignorado por Git; un checkout nuevo requiere compilarlo y copiarlo.

Al redistribuir, conserva y proporciona tambien el codigo fuente correspondiente,
el script, la red NNUE y la licencia. Los archivos fuente, red y licencia se
guardan junto al binario en `build/stockfish-19/`; esa carpeta es local y puede
eliminarse con `flutter clean`.

La validacion final requiere importar el motor desde una GUI OEX en Android
ARM64 y comprobar `uci`, `isready` y una busqueda. Stockfish 19 termina el
proceso ante determinados comandos UCI o posiciones invalidos.
