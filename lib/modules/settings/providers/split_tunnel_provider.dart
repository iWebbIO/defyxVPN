import 'dart:convert';
import 'dart:io';

import 'package:defyx_vpn/core/data/local/secure_storage/secure_storage.dart';
import 'package:defyx_vpn/core/data/local/secure_storage/secure_storage_const.dart';
import 'package:defyx_vpn/core/data/local/secure_storage/secure_storage_interface.dart';
import 'package:defyx_vpn/modules/core/vpn_bridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/split_tunnel_config.dart';

class SplitTunnelState {
  final SplitTunnelConfig config;
  final List<InstalledApp> installedApps;
  final bool isLoadingApps;
  final String? loadAppsError;

  const SplitTunnelState({
    this.config = const SplitTunnelConfig(),
    this.installedApps = const [],
    this.isLoadingApps = false,
    this.loadAppsError,
  });

  bool isSelected(String packageName) => config.isSelected(packageName);

  SplitTunnelState copyWith({
    SplitTunnelConfig? config,
    List<InstalledApp>? installedApps,
    bool? isLoadingApps,
    String? loadAppsError,
    bool clearError = false,
  }) {
    return SplitTunnelState(
      config: config ?? this.config,
      installedApps: installedApps ?? this.installedApps,
      isLoadingApps: isLoadingApps ?? this.isLoadingApps,
      loadAppsError: clearError ? null : (loadAppsError ?? this.loadAppsError),
    );
  }
}

class SplitTunnelNotifier extends StateNotifier<SplitTunnelState> {
  final Ref<SplitTunnelState> ref;
  ISecureStorage? _secureStorage;
  Future<void>? _initFuture;

  SplitTunnelNotifier(this.ref) : super(const SplitTunnelState()) {
    _secureStorage = ref.read(secureStorageProvider);
    _initFuture = _loadConfig();
  }

  /// Completes once the saved configuration has been loaded from storage.
  /// The VPN connect path awaits this so it always pushes a fresh config.
  Future<void> ensureInitialized() => _initFuture ?? Future.value();

  Future<void> _loadConfig() async {
    try {
      final json = await _secureStorage?.read(splitTunnelKey);
      if (json == null) return;
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        state = state.copyWith(config: SplitTunnelConfig.fromJson(decoded));
      }
    } catch (_) {
      // Corrupted config falls back to defaults on next save.
    }
  }

  Future<void> _persist() async {
    try {
      await _secureStorage?.write(
        splitTunnelKey,
        jsonEncode(state.config.toJson()),
      );
    } catch (_) {
      // Storage failures keep the in-memory config; next change retries.
    }
  }

  Future<void> setMode(SplitTunnelMode mode) async {
    state = state.copyWith(config: state.config.copyWith(mode: mode));
    await _persist();
  }

  Future<void> toggleApp(String packageName) async {
    final packages = List<String>.from(state.config.packages);
    if (!packages.remove(packageName)) {
      packages.add(packageName);
    }
    state = state.copyWith(config: state.config.copyWith(packages: packages));
    await _persist();
  }

  /// Loads the launchable apps of the device. Android only: other platforms
  /// have no tunnel builder to apply per-app routing to.
  Future<void> loadApps() async {
    if (!Platform.isAndroid || state.isLoadingApps) return;
    state = state.copyWith(isLoadingApps: true, clearError: true);
    try {
      final apps = await VpnBridge().getInstalledApps();
      state = state.copyWith(installedApps: apps, isLoadingApps: false);
    } catch (e) {
      state = state.copyWith(isLoadingApps: false, loadAppsError: e.toString());
    }
  }
}

final splitTunnelProvider =
    StateNotifierProvider<SplitTunnelNotifier, SplitTunnelState>(
      (ref) => SplitTunnelNotifier(ref),
    );
