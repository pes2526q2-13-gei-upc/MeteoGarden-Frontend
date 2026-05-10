import 'package:flutter/material.dart';

enum CenteredMessageType { success, error, warning, info }

class CenteredMessage {
  static void show(
    BuildContext context,
    String message, {
    CenteredMessageType type = CenteredMessageType.success,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    final config = _config(type);

    final overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.25)),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: config.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(icon ?? config.icon, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static _CenteredMessageConfig _config(CenteredMessageType type) {
    switch (type) {
      case CenteredMessageType.success:
        return const _CenteredMessageConfig(
          icon: Icons.check_circle_rounded,
          gradientColors: [Color(0xFF388E3C), Color(0xFF1B5E20)],
        );

      case CenteredMessageType.error:
        return const _CenteredMessageConfig(
          icon: Icons.error_rounded,
          gradientColors: [Color(0xFFE53935), Color(0xFFB71C1C)],
        );

      case CenteredMessageType.warning:
        return const _CenteredMessageConfig(
          icon: Icons.warning_amber_rounded,
          gradientColors: [Color(0xFFF59E0B), Color(0xFFB45309)],
        );

      case CenteredMessageType.info:
        return const _CenteredMessageConfig(
          icon: Icons.info_rounded,
          gradientColors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
        );
    }
  }
}

class _CenteredMessageConfig {
  final IconData icon;
  final List<Color> gradientColors;

  const _CenteredMessageConfig({
    required this.icon,
    required this.gradientColors,
  });
}
