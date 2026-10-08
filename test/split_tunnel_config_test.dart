import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:defyx_vpn/modules/settings/models/split_tunnel_config.dart';

void main() {
  group('SplitTunnelMode', () {
    test('effectiveMode is disabled for empty config', () {
      const config = SplitTunnelConfig();
      expect(config.isActive, false);
      expect(config.effectiveMode, 'disabled');
    });

    test('effectiveMode reflects the selected mode once apps are chosen', () {
      const excludeConfig = SplitTunnelConfig(
        mode: SplitTunnelMode.exclude,
        packages: ['com.example.a'],
      );
      const includeConfig = SplitTunnelConfig(
        mode: SplitTunnelMode.include,
        packages: ['com.example.a'],
      );
      expect(excludeConfig.effectiveMode, 'exclude');
      expect(includeConfig.effectiveMode, 'include');
    });
  });

  group('SplitTunnelConfig json', () {
    test('round trips through toJson/fromJson', () {
      const config = SplitTunnelConfig(
        mode: SplitTunnelMode.include,
        packages: ['com.example.a', 'com.example.b'],
      );
      final restored = SplitTunnelConfig.fromJson(
        jsonDecode(jsonEncode(config.toJson())) as Map<String, dynamic>,
      );
      expect(restored, config);
      expect(restored.mode, SplitTunnelMode.include);
      expect(restored.packages, ['com.example.a', 'com.example.b']);
    });

    test('fromJson defaults on unknown or corrupt values', () {
      const corrupt = '{"mode": "banana", "packages": [1, null, ""]}';
      final restored = SplitTunnelConfig.fromJson(
        jsonDecode(corrupt) as Map<String, dynamic>,
      );
      expect(restored.mode, SplitTunnelMode.exclude);
      expect(restored.packages, isEmpty);
      expect(restored.isActive, false);
    });
  });

  group('SplitTunnelConfig selection', () {
    test('isSelected and copyWith', () {
      const config = SplitTunnelConfig(packages: ['com.example.a']);
      expect(config.isSelected('com.example.a'), true);
      expect(config.isSelected('com.example.b'), false);

      final toggled = config.copyWith(mode: SplitTunnelMode.include);
      expect(toggled.mode, SplitTunnelMode.include);
      expect(toggled.packages, config.packages);
    });
  });

  group('InstalledApp', () {
    test('fromJson falls back to packageName as label', () {
      final app = InstalledApp.fromJson({'packageName': 'com.example.a'});
      expect(app.label, 'com.example.a');
      expect(app.packageName, 'com.example.a');
    });

    test('equality is by package name', () {
      const a = InstalledApp(packageName: 'com.example.a', label: 'App A');
      const b = InstalledApp(packageName: 'com.example.a', label: 'Different label');
      expect(a, b);
    });
  });
}
