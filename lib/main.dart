import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const ChessOexApp());
}

class ChessOexApp extends StatelessWidget {
  const ChessOexApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1D6B5C);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Motores OEX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF6F1E7),
        useMaterial3: true,
      ),
      home: const OexHomePage(),
    );
  }
}

class OexHomePage extends StatefulWidget {
  const OexHomePage({super.key});

  @override
  State<OexHomePage> createState() => _OexHomePageState();
}

class _OexHomePageState extends State<OexHomePage> {
  static const _channel = MethodChannel('motor_oex/oex');
  late Future<OexStatus> _statusFuture;
  late Future<PackageInfo> _packageFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = _loadStatus();
    _packageFuture = PackageInfo.fromPlatform();
  }

  Future<OexStatus> _loadStatus() async {
    final raw = await _channel.invokeMapMethod<dynamic, dynamic>(
      'getEngineStatus',
    );
    if (raw == null) {
      throw PlatformException(
        code: 'empty_status',
        message: 'Android no devolvio estado.',
      );
    }
    return OexStatus.fromMap(Map<dynamic, dynamic>.from(raw));
  }

  Future<void> _refresh() async {
    final next = _loadStatus();
    setState(() {
      _statusFuture = next;
    });
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE5F3EE), Color(0xFFF6F1E7)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<OexStatus>(
            future: _statusFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 56,
                          color: Color(0xFF9A3412),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se pudo leer el estado OEX.',
                          style: theme.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text('${snapshot.error}', textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _refresh,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final status = snapshot.requireData;
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF113C38),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/app_icon.png',
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Motores OEX listos',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'La app expone motores UCI a GUIs compatibles mediante Open Exchange.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFFD7E7E3),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _InfoChip(label: 'ABI', value: status.deviceAbi),
                              _InfoChip(
                                label: 'Authority',
                                value: status.authority,
                              ),
                              _InfoChip(
                                label: 'Motores OEX',
                                value: '${status.advertisedCount}',
                              ),
                              FutureBuilder<PackageInfo>(
                                future: _packageFuture,
                                builder: (context, snap) {
                                  final v = snap.hasData
                                      ? snap.data!.version
                                      : '...';
                                  return _InfoChip(label: 'Versión', value: v);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBF2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE7D7B3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF8A5A00),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Autor de la app',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Adrian Cruz',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE7D7B3)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.open_in_new_rounded,
                                color: Color(0xFF8A5A00),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'GUI recomendada',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final url = Uri.parse(
                                'https://play.google.com/store/apps/details?id=com.lectorpgnapp.simplepgn',
                              );
                              if (!await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              )) {
                                debugPrint('Could not launch \$url');
                              }
                            },
                            child: Text(
                              'SimplePGN',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF1D514B),
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const _RepoLink(
                            label: 'Repositorio de la app (GitHub)',
                            url: 'https://github.com/adrianchess/motorOEX',
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE7D7B3)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.privacy_tip_rounded,
                                color: Color(0xFF8A5A00),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Política de privacidad',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final url = Uri.parse(
                                'https://sites.google.com/view/motoresoex/inicio?authuser=1',
                              );
                              if (!await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              )) {
                                debugPrint('Could not launch \$url');
                              }
                            },
                            child: Text(
                              'Ver política de privacidad',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF1D514B),
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE7D7B3)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.code_rounded,
                                color: Color(0xFF8A5A00),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Repositorios de los motores',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _RepoLink(
                            label: 'Stockfish (GitHub)',
                            url:
                                'https://github.com/official-stockfish/Stockfish',
                          ),
                          const SizedBox(height: 6),
                          _RepoLink(
                            label: 'PlentyChess (GitHub)',
                            url: 'https://github.com/Yoshie2000/PlentyChess',
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE7D7B3)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.gavel_rounded,
                                color: Color(0xFF8A5A00),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Licencia',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final url = Uri.parse(
                                'https://www.gnu.org/licenses/gpl-3.0.html',
                              );
                              if (!await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              )) {
                                debugPrint('Could not launch \$url');
                              }
                            },
                            child: Text(
                              'GPL-3.0 license',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF1D514B),
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Motores incluidos',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final engine in status.engines)
                      _EngineCard(engine: engine),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1D514B),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class _RepoLink extends StatelessWidget {
  const _RepoLink({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          debugPrint('Could not launch $url');
        }
      },
      child: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: const Color(0xFF1D514B),
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EngineCard extends StatelessWidget {
  const _EngineCard({required this.engine});

  final OexEngine engine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = engine.exported
        ? const Color(0xFF166534)
        : engine.compatible
        ? const Color(0xFF9A3412)
        : const Color(0xFF475569);
    final badgeText = engine.exported
        ? 'Publicado por OEX'
        : engine.compatible
        ? 'Instalado, no publicado'
        : 'No compatible con este ABI';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  engine.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Archivo OEX: ${engine.fileName}'),
          Text('Targets: ${engine.targets.join(', ')}'),
          Text('Preparado: ${engine.prepared ? 'si' : 'no'}'),
          if (engine.note != null && engine.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              engine.note!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF57534E),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OexStatus {
  OexStatus({
    required this.authority,
    required this.deviceAbi,
    required this.advertisedCount,
    required this.engines,
  });

  factory OexStatus.fromMap(Map<dynamic, dynamic> map) {
    final rawEngines = (map['engines'] as List<dynamic>? ?? const <dynamic>[])
        .cast<Map<dynamic, dynamic>>();

    return OexStatus(
      authority: (map['authority'] ?? '').toString(),
      deviceAbi: (map['deviceAbi'] ?? 'desconocido').toString(),
      advertisedCount: (map['advertisedCount'] as num? ?? 0).toInt(),
      engines: rawEngines.map(OexEngine.fromMap).toList(),
    );
  }

  final String authority;
  final String deviceAbi;
  final int advertisedCount;
  final List<OexEngine> engines;
}

class OexEngine {
  OexEngine({
    required this.name,
    required this.fileName,
    required this.targets,
    required this.exported,
    required this.compatible,
    required this.prepared,
    this.note,
  });

  factory OexEngine.fromMap(Map<dynamic, dynamic> map) {
    final rawTargets = (map['targets'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => item.toString())
        .toList();

    return OexEngine(
      name: (map['name'] ?? '').toString(),
      fileName: (map['fileName'] ?? '').toString(),
      targets: rawTargets,
      exported: map['exported'] == true,
      compatible: map['compatible'] == true,
      prepared: map['prepared'] == true,
      note: map['note']?.toString(),
    );
  }

  final String name;
  final String fileName;
  final List<String> targets;
  final bool exported;
  final bool compatible;
  final bool prepared;
  final String? note;
}
