import 'dart:io';

import 'package:defyx_vpn/l10n/app_localizations.dart';
import 'package:defyx_vpn/modules/settings/models/split_tunnel_config.dart';
import 'package:defyx_vpn/modules/settings/providers/settings_provider.dart';
import 'package:defyx_vpn/modules/settings/providers/split_tunnel_provider.dart';
import 'package:defyx_vpn/shared/layout/main_screen_background.dart';
import 'package:defyx_vpn/shared/providers/connection_state_provider.dart';
import 'package:defyx_vpn/shared/widgets/defyx_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SplitTunnelScreen extends ConsumerStatefulWidget {
  const SplitTunnelScreen({super.key});

  @override
  ConsumerState<SplitTunnelScreen> createState() => _SplitTunnelScreenState();
}

class _SplitTunnelScreenState extends ConsumerState<SplitTunnelScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(splitTunnelProvider.notifier).loadApps();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onConfigChanged() {
    if (!mounted) return;
    // Refresh the settings list so the INCLUDED/EXCLUDED subtitle matches.
    ref.read(settingsProvider.notifier).applyLocalization(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final connectionState = ref.watch(connectionStateProvider);
    final splitTunnelState = ref.watch(splitTunnelProvider);

    return MainScreenBackground(
      connectionStatus: connectionState.status,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 45.h),
            _buildHeader(),
            SizedBox(height: 25.h),
            if (!Platform.isAndroid)
              Expanded(child: Center(child: Text(l10n.splitTunnelUnavailable)))
            else ...[
              _buildModeSelector(l10n, splitTunnelState.config.mode),
              SizedBox(height: 12.h),
              _buildModeDescription(l10n, splitTunnelState.config.mode),
              SizedBox(height: 20.h),
              Text(
                l10n.splitTunnelApplyNote,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Lato',
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: 20.h),
              _buildSearchField(l10n),
              SizedBox(height: 10.h),
              Expanded(child: _buildAppList(l10n, splitTunnelState)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 26.sp),
            onPressed: () => context.pop(),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'D',
                          style: TextStyle(
                            fontSize: 35.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFFC927),
                          ),
                        ),
                        TextSpan(
                          text: 'efyx ',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFFFC927),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  AppLocalizations.of(context).settingsSplitTunnel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(AppLocalizations l10n, SplitTunnelMode mode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: _buildModeOption(
              label: l10n.splitTunnelModeExclude,
              selected: mode == SplitTunnelMode.exclude,
              onTap: () async {
                await ref
                    .read(splitTunnelProvider.notifier)
                    .setMode(SplitTunnelMode.exclude);
                _onConfigChanged();
              },
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildModeOption(
              label: l10n.splitTunnelModeInclude,
              selected: mode == SplitTunnelMode.include,
              onTap: () async {
                await ref
                    .read(splitTunnelProvider.notifier)
                    .setMode(SplitTunnelMode.include);
                _onConfigChanged();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: selected ? const Color(0xFF00D4AA) : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: selected ? const Color(0xFF00D4AA) : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            color: selected ? const Color(0xFF1A1A1A) : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildModeDescription(AppLocalizations l10n, SplitTunnelMode mode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text(
        mode == SplitTunnelMode.include
            ? l10n.splitTunnelIncludeDescription
            : l10n.splitTunnelExcludeDescription,
        style: TextStyle(
          fontSize: 14.sp,
          fontFamily: 'Lato',
          color: Colors.grey[400],
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        style: TextStyle(
          fontSize: 15.sp,
          fontFamily: 'Lato',
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: l10n.splitTunnelSearchApps,
          hintStyle: TextStyle(
            fontSize: 15.sp,
            fontFamily: 'Lato',
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 22.sp),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: const Color(0xFF00D4AA).withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildAppList(AppLocalizations l10n, SplitTunnelState tunnelState) {
    if (tunnelState.isLoadingApps) {
      return Center(
        child: CircularProgressIndicator(color: const Color(0xFF00D4AA)),
      );
    }

    if (tunnelState.loadAppsError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.splitTunnelLoadError,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Lato',
                color: Colors.grey[400],
              ),
            ),
            TextButton(
              onPressed: () => ref.read(splitTunnelProvider.notifier).loadApps(),
              child: Text(
                l10n.splitTunnelRetry,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Lato',
                  color: const Color(0xFF00D4AA),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final query = _query.trim().toLowerCase();
    final apps = query.isEmpty
        ? tunnelState.installedApps
        : tunnelState.installedApps
              .where(
                (app) =>
                    app.label.toLowerCase().contains(query) ||
                    app.packageName.toLowerCase().contains(query),
              )
              .toList();

    if (apps.isEmpty) {
      return Center(
        child: Text(
          l10n.splitTunnelNoApps,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Lato',
            color: Colors.grey[500],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 130.h),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        final isSelected = tunnelState.isSelected(app.packageName);
        return GestureDetector(
          onTap: () async {
            await ref
                .read(splitTunnelProvider.notifier)
                .toggleApp(app.packageName);
            _onConfigChanged();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        app.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        app.packageName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Lato',
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // The whole row handles taps; the switch is display-only so
                // tapping it doesn't toggle twice.
                IgnorePointer(
                  child: DefyxSwitch(value: isSelected, onChanged: (_) {}),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
