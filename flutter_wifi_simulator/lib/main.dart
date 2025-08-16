import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const WifiSimApp());
}

class WifiSimApp extends StatelessWidget {
  const WifiSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wi‑Fi Simulator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WifiSimPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum WifiSecurity { open, wpa2, wpa3 }

extension WifiSecurityLabel on WifiSecurity {
  String get label {
    switch (this) {
      case WifiSecurity.open:
        return 'Açık';
      case WifiSecurity.wpa2:
        return 'WPA2';
      case WifiSecurity.wpa3:
        return 'WPA3';
    }
  }

  bool get requiresPassword => this != WifiSecurity.open;
}

class WifiNetwork {
  final String ssid;
  final int signalPercent; // 0..100
  final WifiSecurity security;

  const WifiNetwork({
    required this.ssid,
    required this.signalPercent,
    required this.security,
  });

  bool get requiresPassword => security.requiresPassword;
}

class WifiController extends ChangeNotifier {
  final Random _random = Random(1);
  final List<WifiNetwork> _networks = <WifiNetwork>[];

  WifiNetwork? _connectedNetwork;
  bool _isScanning = false;
  bool _isConnecting = false;
  String _filterQuery = '';
  bool _onlyOpen = false;

  List<WifiNetwork> get networks => _filteredSortedNetworks();
  WifiNetwork? get connectedNetwork => _connectedNetwork;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  String get filterQuery => _filterQuery;
  bool get onlyOpen => _onlyOpen;

  void setFilter(String value) {
    _filterQuery = value;
    notifyListeners();
  }

  void setOnlyOpen(bool value) {
    _onlyOpen = value;
    notifyListeners();
  }

  Future<void> scan({Duration duration = const Duration(seconds: 2)}) async {
    if (_isScanning) return;
    _isScanning = true;
    notifyListeners();

    await Future<void>.delayed(duration);

    final List<WifiNetwork> generated = _generateFakeNetworks();

    _networks
      ..clear()
      ..addAll(generated);

    _isScanning = false;
    notifyListeners();
  }

  List<WifiNetwork> _generateFakeNetworks() {
    final List<String> names = <String>[
      'HomeNet',
      'Office',
      'Cafe',
      'Airport_Free',
      'Hotel_Guest',
      'MyPhone',
      'Campus_WiFi',
      'IoT_1',
      'IoT_2',
      'Printer_123',
      'PublicWiFi',
      'Fiber_5G',
      'Fiber_2G',
      'Guest_AP',
      'Studio',
      'LivingRoom_AP',
      'Mesh_Node',
      'Neighbors',
      'WorkLab',
      'Lab_AP',
    ];

    names.shuffle(_random);
    final int count = 10 + _random.nextInt(6); // 10..15

    return List<WifiNetwork>.generate(count, (int i) {
      final String ssid = names[i];
      final int signal = 30 + _random.nextInt(70); // 30..99
      final WifiSecurity security = WifiSecurity.values[_random.nextInt(WifiSecurity.values.length)];
      return WifiNetwork(ssid: ssid, signalPercent: signal, security: security);
    });
  }

  List<WifiNetwork> _filteredSortedNetworks() {
    Iterable<WifiNetwork> list = _networks;

    if (_filterQuery.isNotEmpty) {
      final String query = _filterQuery.toLowerCase();
      list = list.where((WifiNetwork n) => n.ssid.toLowerCase().contains(query));
    }

    if (_onlyOpen) {
      list = list.where((WifiNetwork n) => n.security == WifiSecurity.open);
    }

    final List<WifiNetwork> sorted = list.toList()
      ..sort((WifiNetwork a, WifiNetwork b) => b.signalPercent.compareTo(a.signalPercent));

    if (_connectedNetwork != null) {
      sorted.sort((WifiNetwork a, WifiNetwork b) {
        if (a.ssid == _connectedNetwork!.ssid) return -1;
        if (b.ssid == _connectedNetwork!.ssid) return 1;
        return b.signalPercent.compareTo(a.signalPercent);
      });
    }

    return sorted;
  }

  Future<void> connect(WifiNetwork network, {String? password}) async {
    if (_isConnecting) return;
    _isConnecting = true;
    notifyListeners();

    await Future<void>.delayed(Duration(milliseconds: 800 + _random.nextInt(800)));

    if (network.requiresPassword && (password == null || password.length < 8)) {
      _isConnecting = false;
      notifyListeners();
      throw Exception('Parola gerekli (en az 8 karakter).');
    }

    if (_random.nextInt(10) == 0) {
      _isConnecting = false;
      notifyListeners();
      throw Exception('Bağlantı başarısız oldu. Tekrar deneyin.');
    }

    _connectedNetwork = network;
    _isConnecting = false;
    notifyListeners();
  }

  Future<void> disconnect() async {
    if (_connectedNetwork == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _connectedNetwork = null;
    notifyListeners();
  }
}

class WifiSimPage extends StatefulWidget {
  const WifiSimPage({super.key});

  @override
  State<WifiSimPage> createState() => _WifiSimPageState();
}

class _WifiSimPageState extends State<WifiSimPage> {
  late final WifiController controller;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = WifiController();
    unawaited(controller.scan());
  }

  @override
  void dispose() {
    controller.dispose();
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi‑Fi Simulator'),
        actions: <Widget>[
          IconButton(
            onPressed: controller.isScanning ? null : () => controller.scan(),
            icon: controller.isScanning
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
            tooltip: 'Tara',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? _) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocus,
                        onChanged: controller.setFilter,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Ağ ara (SSID)...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: const Text('Sadece açık ağlar'),
                      selected: controller.onlyOpen,
                      onSelected: (bool v) => controller.setOnlyOpen(v),
                    ),
                  ],
                ),
              ),
              if (controller.connectedNetwork != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      avatar: const Icon(Icons.check, size: 18),
                      label: Text('Bağlı: ${controller.connectedNetwork!.ssid}'),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: controller.networks.isEmpty
                    ? Center(
                        child: controller.isScanning
                            ? const CircularProgressIndicator()
                            : const Text('Ağ bulunamadı. Yeniden tarayın.'),
                      )
                    : ListView.separated(
                        itemCount: controller.networks.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (BuildContext _, int index) {
                          final WifiNetwork n = controller.networks[index];
                          final bool isConnected = controller.connectedNetwork?.ssid == n.ssid;
                          return ListTile(
                            leading: Icon(
                              _wifiIconForSignal(n.signalPercent),
                              color: isConnected ? Colors.green : null,
                            ),
                            title: Text(
                              n.ssid,
                              style: TextStyle(fontWeight: isConnected ? FontWeight.w600 : null),
                            ),
                            subtitle: Text('${n.security.label} • Sinyal ${n.signalPercent}%'),
                            trailing: isConnected
                                ? TextButton.icon(
                                    onPressed: controller.disconnect,
                                    icon: const Icon(Icons.link_off),
                                    label: const Text('Kes'),
                                  )
                                : TextButton.icon(
                                    onPressed: controller.isConnecting
                                        ? null
                                        : () async {
                                            if (n.requiresPassword) {
                                              final String? pw = await _askPassword(context, n.ssid);
                                              if (pw == null) return;
                                              try {
                                                await controller.connect(n, password: pw);
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('${n.ssid} ağına bağlandı')),
                                                  );
                                                }
                                              } catch (Object e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                                                  );
                                                }
                                              }
                                            } else {
                                              try {
                                                await controller.connect(n);
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('${n.ssid} ağına bağlandı')),
                                                  );
                                                }
                                              } catch (Object e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                    icon: controller.isConnecting
                                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                        : Icon(n.requiresPassword ? Icons.lock : Icons.wifi),
                                    label: const Text('Bağlan'),
                                  ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.isScanning ? null : () => controller.scan(),
        label: Text(controller.isScanning ? 'Taranıyor...' : 'Tarama'),
        icon: const Icon(Icons.wifi),
      ),
    );
  }
}

IconData _wifiIconForSignal(int percent) {
  if (percent >= 75) return Icons.signal_wifi_4_bar;
  if (percent >= 50) return Icons.signal_wifi_3_bar;
  if (percent >= 25) return Icons.signal_wifi_2_bar;
  return Icons.signal_wifi_0_bar;
}

Future<String?> _askPassword(BuildContext context, String ssid) async {
  final TextEditingController controller = TextEditingController();
  final String? result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('$ssid – Parola'),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Parola (en az 8 karakter)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Bağlan'),
          ),
        ],
      );
    },
  );
  return result;
}