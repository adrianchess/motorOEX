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

### Publicacion Android ofuscada

Version preparada: `1.0.14+15`, con target SDK 36 y min SDK 24.
Los motores incluidos requieren ARM64; la app conserva los ABI existentes.

```bash
flutter test
flutter analyze
flutter build appbundle --release --obfuscate \
	--split-debug-info=releases/1.0.14+15/symbols
```

La compilacion requiere la clave de publicacion configurada en
`android/key.properties`. Verifica siempre la firma: la configuracion actual
recurre a la clave debug si falta ese archivo. Nunca subas ese resultado a Play.
R8 reduce y ofusca el codigo Android; `--obfuscate` ofusca los nombres Dart,
pero no cifra recursos ni sustituye las obligaciones GPL.

El AAB se genera en `build/app/outputs/bundle/release/app-release.aab`.
Conserva una copia versionada, los simbolos Dart y
`build/app/outputs/mapping/release/mapping.txt` fuera de `build/`.
La carpeta local `releases/` esta excluida de Git; haz una copia de seguridad
privada y no sobrescribas los simbolos de una version ya distribuida.

Antes de publicar, valida el AAB con bundletool, comprueba su firma, manifiesto,
alineacion ELF de todas las bibliotecas y los APK derivados con `zipalign -P 16`.
Prueba tambien arranque, descubrimiento OEX y busqueda UCI en Android ARM64
con paginas de 16 KB. La extraccion de bibliotecas es necesaria para OEX.

En Play Console debes confirmar que el codigo de version no se ha usado,
que la firma coincide con la clave de subida, y revisar seguridad de datos,
URL de privacidad, anuncios, audiencia, clasificacion de contenido y requisitos
de cuenta/pruebas aplicables. Ejecuta el informe previo al lanzamiento y
proporciona el codigo fuente correspondiente de la app y ambos motores.
La validacion local no garantiza aprobacion ni cumplimiento total de politicas.

Referencias oficiales:
- https://support.google.com/googleplay/android-developer/answer/11926878
- https://developer.android.com/guide/practices/page-sizes

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
