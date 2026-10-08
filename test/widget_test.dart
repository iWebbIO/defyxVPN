import 'package:flutter_test/flutter_test.dart';

import 'package:defyx_vpn/app/router/app_router.dart';
import 'package:defyx_vpn/modules/settings/constants/settings_constants.dart';
import 'package:defyx_vpn/modules/settings/factories/settings_factory.dart';
import 'package:defyx_vpn/modules/settings/models/settings_item.dart';

void main() {
  test('router registers the split tunnel sub-route', () {
    expect(DefyxVPNRoutes.splitTunnel.route, '/settings/split_tunnel');
    expect(SettingsRoute.splitTunnel, DefyxVPNRoutes.splitTunnel.route);
  });

  test('traffic control group includes split tunnel item when configured', () {
    SettingsFactory.configure(
      const SettingsConfig(showSplitTunnel: true, showDeepScan: true),
    );
    addTearDown(
      () => SettingsFactory.configure(SettingsConfig.defaultConfig),
    );

    final group = SettingsFactory.createTrafficControlGroup(
      title: 'ESCAPE MODE',
      splitTunnelTitle: 'SPLIT TUNNEL',
      splitTunnelSubtitle: 'EXCLUDED',
      deepScanTitle: 'DEEP SCAN',
      healthCheckTitle: 'HEALTH CHECK',
    );

    final splitTunnelItem = group.items
        .where((item) => item.id == SettingsItemId.splitTunnel)
        .first;
    expect(splitTunnelItem.itemType, SettingsItemType.navigation);
    expect(splitTunnelItem.navigationRoute, SettingsRoute.splitTunnel);
    expect(splitTunnelItem.subtitle, 'EXCLUDED');
  });

  test('traffic control group omits split tunnel item by default', () {
    SettingsFactory.configure(
      const SettingsConfig(showSplitTunnel: false, showDeepScan: true),
    );
    addTearDown(
      () => SettingsFactory.configure(SettingsConfig.defaultConfig),
    );

    final group = SettingsFactory.createTrafficControlGroup(
      title: 'ESCAPE MODE',
      splitTunnelTitle: 'SPLIT TUNNEL',
      splitTunnelSubtitle: 'EXCLUDED',
      deepScanTitle: 'DEEP SCAN',
      healthCheckTitle: 'HEALTH CHECK',
    );

    expect(
      group.items.where((item) => item.id == SettingsItemId.splitTunnel),
      isEmpty,
    );
    expect(
      group.items.map((item) => item.id),
      contains(SettingsItemId.deepScan),
    );
  });

  test('saved split tunnel state is restored when the group is recreated', () {
    SettingsFactory.configure(
      const SettingsConfig(showSplitTunnel: true, showDeepScan: true),
    );
    addTearDown(
      () => SettingsFactory.configure(SettingsConfig.defaultConfig),
    );

    final group = SettingsFactory.createTrafficControlGroup(
      title: 'ESCAPE MODE',
      splitTunnelTitle: 'SPLIT TUNNEL',
      splitTunnelSubtitle: 'INCLUDED',
      deepScanTitle: 'DEEP SCAN',
      healthCheckTitle: 'HEALTH CHECK',
      splitTunnelEnabled: true,
    );

    final splitTunnelItem = group.items
        .where((item) => item.id == SettingsItemId.splitTunnel)
        .first;
    expect(splitTunnelItem.isEnabled, true);
    expect(
      SettingsFactory.getSavedItemState(
        group.items,
        SettingsItemId.splitTunnel,
      ),
      true,
    );
  });
}
