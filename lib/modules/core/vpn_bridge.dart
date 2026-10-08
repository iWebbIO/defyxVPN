import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../settings/models/split_tunnel_config.dart';

class VpnBridge {
  VpnBridge._internal();
  static final VpnBridge _instance = VpnBridge._internal();
  factory VpnBridge() => _instance;

  final _methodChannel = MethodChannel('com.defyx.vpn');

  Future<String?> getVpnStatus() async =>
      await _methodChannel.invokeMethod('getVpnStatus');

  Future<void> setAsnName() async =>
      await _methodChannel.invokeMethod('setAsnName');

  Future<String> getPing() async =>
      (await _methodChannel.invokeMethod('calculatePing')).toString();

  Future<void> setTimezone(String timezone) =>
      _methodChannel.invokeMethod("setTimezone", {"timezone": timezone});

  Future<void> disconnectVpn() async =>
      await _methodChannel.invokeMethod('disconnect');

  Future<void> stopVPN() async => await _methodChannel.invokeMethod('stopVPN');

  Future<void> stopTun2Socks() async =>
      await _methodChannel.invokeMethod("stopTun2Socks");

  Future<bool?> connectVpn() async =>
      await _methodChannel.invokeMethod<bool>('connect');

  Future<bool?> grantVpnPermission() async =>
      await _methodChannel.invokeMethod<bool>("grantVpnPermission");

  Future<void> startVPN(
    String flowline,
    String pattern,
    bool deepScan,
    bool healthCheck,
  ) async => await _methodChannel.invokeMethod("startVPN", {
    "flowLine": flowline,
    "pattern": pattern,
    "deepScan": deepScan.toString(),
    "healthCheck": healthCheck.toString(),
  });

  Future<void> startTun2socks() =>
      _methodChannel.invokeMethod("startTun2socks");

  /// Pushes the split tunneling config to the native tunnel builder so the
  /// next established tunnel routes apps accordingly. A null config is the
  /// same as an inactive one: full tunnel, no app filters.
  Future<void> setSplitTunnelApps(SplitTunnelConfig? config) async {
    await _methodChannel.invokeMethod("setSplitTunnelApps", {
      "mode": config?.effectiveMode ?? 'disabled',
      "packages": config?.packages ?? const <String>[],
    });
  }

  /// Launchable apps installed on the device (Android only).
  Future<List<InstalledApp>> getInstalledApps() async {
    final apps = await _methodChannel.invokeMethod<List<dynamic>>(
      "getInstalledApps",
    );
    return (apps ?? [])
        .whereType<Map>()
        .map(InstalledApp.fromJson)
        .toList();
  }

  Future<bool> isTunnelRunning() async =>
      (await _methodChannel.invokeMethod<bool>("isTunnelRunning")) ?? false;

  Future<void> setConnectionMethod(String method) async => await _methodChannel
      .invokeMethod("setConnectionMethod", {"method": method});
  Future<String> getFlowLine(String token) async {
    final isTestMode = dotenv.env['IS_TEST_MODE'] ?? 'false';
    final flowLine = await _methodChannel.invokeMethod<String>('getFlowLine', {
      "isTest": isTestMode,
      "token": token,
    });
    return flowLine ?? '';
  }

  Future<String> getCachedFlowLine() async {
    final info = await _methodChannel.invokeMethod<String>('getCachedFlowLine');
    return info ?? "";
  }

  Future<String> decodeAndVerifyFlowline(String flowLine) async {
    final decoded = await _methodChannel.invokeMethod<String>(
      'decodeAndVerifyFlowline',
      {"flowLine": flowLine},
    );
    return decoded ?? "";
  }

  Future<void> setCacheDir(String cacheDir) async {
    await _methodChannel.invokeMethod('setCacheDir', {"cacheDir": cacheDir});
  }

  Future<String> getSharedDirectory() async =>
      (await _methodChannel.invokeMethod<String>('getSharedDirectory')) ?? "";

  Future<String> getFlag() async =>
      (await _methodChannel.invokeMethod<String>('getFlag') ?? "");

  Future<bool> prepareVpn() async =>
      (await _methodChannel.invokeMethod('prepareVPN')) ?? false;

  Future<bool> isVPNPrepared() async =>
      (await _methodChannel.invokeMethod<bool>('isVPNPrepared')) ?? false;

  Future<bool> verifyGateway() async {
    try {
      return (await _methodChannel.invokeMethod<bool>('verifyGateway')) ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<String> login(String email, String password) async =>
      (await _methodChannel.invokeMethod<String>('login', {
        "email": email,
        "password": password,
      }) ??
      "");

  Future<String> loginByCode(String code) async =>
      (await _methodChannel.invokeMethod<String>('loginByCode', {
        "code": code,
      }) ??
      "");
}
