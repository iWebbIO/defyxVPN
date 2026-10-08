/// How selected apps interact with the VPN tunnel.
///
/// [exclude]: every app is routed through the VPN except the selected ones.
/// [include]: only the selected apps are routed through the VPN.
enum SplitTunnelMode { exclude, include }

/// An app installed on the device that can be routed in or out of the tunnel.
class InstalledApp {
  final String packageName;
  final String label;

  const InstalledApp({required this.packageName, required this.label});

  Map<String, dynamic> toJson() => {'packageName': packageName, 'label': label};

  factory InstalledApp.fromJson(Map<dynamic, dynamic> json) => InstalledApp(
    packageName: json['packageName'] as String? ?? '',
    label: json['label'] as String? ?? json['packageName'] as String? ?? '',
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstalledApp && other.packageName == packageName;

  @override
  int get hashCode => packageName.hashCode;
}

/// User-selected split tunneling configuration.
class SplitTunnelConfig {
  final SplitTunnelMode mode;
  final List<String> packages;

  const SplitTunnelConfig({
    this.mode = SplitTunnelMode.exclude,
    this.packages = const [],
  });

  /// Whether the config changes tunnel routing at all. An empty selection
  /// means "route everything", which is the default tunnel behavior for
  /// both modes (an include list with no apps cannot express "route nothing").
  bool get isActive => packages.isNotEmpty;

  /// Mode string sent to the native tunnel builder; "disabled" leaves the
  /// builder with no app filters (full tunnel).
  String get effectiveMode => isActive ? mode.name : 'disabled';

  bool isSelected(String packageName) => packages.contains(packageName);

  SplitTunnelConfig copyWith({SplitTunnelMode? mode, List<String>? packages}) =>
      SplitTunnelConfig(
        mode: mode ?? this.mode,
        packages: packages ?? this.packages,
      );

  Map<String, dynamic> toJson() => {'mode': mode.name, 'packages': packages};

  factory SplitTunnelConfig.fromJson(Map<String, dynamic> json) {
    final modeName = json['mode'] as String?;
    final mode = SplitTunnelMode.values.where((m) => m.name == modeName).firstOrNull;
    final packages =
        (json['packages'] as List<dynamic>? ?? [])
            .whereType<String>()
            .where((p) => p.isNotEmpty)
            .toList();
    return SplitTunnelConfig(
      mode: mode ?? SplitTunnelMode.exclude,
      packages: packages,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitTunnelConfig &&
          other.mode == mode &&
          other.packages.length == packages.length &&
          other.packages.every(packages.contains);

  @override
  int get hashCode => Object.hash(mode, Object.hashAllUnordered(packages));
}
