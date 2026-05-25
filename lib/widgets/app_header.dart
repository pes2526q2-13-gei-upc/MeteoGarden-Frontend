import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? extraInfo;
  final bool showBack;
  final VoidCallback? onMenuPressed;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.extraInfo,
    this.showBack = true,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ─── LOGO + NOM APP ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 28,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.eco,
                            color: Color(0xFF4CAF50),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'MeteoGarden',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // ─── TITLE ───
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B5E20),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // ─── SUBTITLE ───
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2E7D32),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    // ─── EXTRA INFO ───
                    if (extraInfo != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        extraInfo!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // ─── BACK BUTTON ───
          if (showBack)
            Positioned(
              left: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF4CAF50)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
        ],
      ),
    );
  }
}
