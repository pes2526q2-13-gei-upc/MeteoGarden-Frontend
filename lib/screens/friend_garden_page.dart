import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/app_localizations.dart';
import '../models/dades_usr.dart';
import '../models/garden.dart';
import '../services/amics_service.dart';
import '../services/garden_service.dart';
import '../widgets/pot_widget.dart';
import '../../models/avatar_stack.dart';

class FriendGardenPage extends StatefulWidget {
  final String friendUsername;
  final String gardenName;
  final Map<String, dynamic>? avatarParts;
  final GardenService? gardenService;
  final AmicsService? amicsService;

  const FriendGardenPage({
    super.key,
    required this.friendUsername,
    required this.gardenName,
    this.avatarParts,
    this.gardenService,
    this.amicsService,
  });

  @override
  State<FriendGardenPage> createState() => _FriendGardenPageState();
}

class _FriendGardenPageState extends State<FriendGardenPage> {
  late final GardenService _gardenService;
  late final AmicsService _amicsService;

  late Future<List<GardenPot>> _potsFuture;
  bool _likeSending = false;
  bool _liked = false;

  @override
  @override
void initState() {
  super.initState();
  _gardenService = widget.gardenService ?? GardenService();
  _amicsService = widget.amicsService ?? AmicsService();
  _loadGarden();
  _loadLikeState();
}

  Future<void> _loadLikeState() async {
    final token = Provider.of<UserModel>(context, listen: false).token;

    try {
      final liked = await _amicsService.getGardenLikeState(
        username: widget.friendUsername,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _liked = liked;
      });
    } catch (_) {
      // No bloquegem la pantalla si falla carregar l'estat del like.
    }
  }

  void _loadGarden() {
    _potsFuture = _gardenService.fetchGardenPlants(
      username: widget.friendUsername,
      gardenName: widget.gardenName,
    );
  }

  Future<void> _giveLike() async {
    if (_likeSending) return;

    final token = Provider.of<UserModel>(context, listen: false).token;

    setState(() => _likeSending = true);

    try {
      final newLikeState = await _amicsService.likeGarden(
        username: widget.friendUsername,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _liked = newLikeState;
      });
    } catch (e) {
      if (!mounted) return;

      _showSnack(e.toString().replaceFirst('Exception: ', ''), success: false);
    } finally {
      if (mounted) {
        setState(() => _likeSending = false);
      }
    }
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? const Color(0xFF2E7D32) : Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS DE MIDA (iguals que a GardenPage)
  // ---------------------------------------------------------------------------

  double _horizontalPadding(double width) {
    if (width < 360) return 8;
    if (width < 700) return 12;
    return 16;
  }

  double _gridSpacing(double width) {
    if (width < 360) return 6;
    if (width < 700) return 10;
    return 14;
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/imatge_fondo1.png',
                  fit: BoxFit.cover,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _horizontalPadding(width),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 18,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: height * 0.002),
                            child: _buildHeader(width),
                          ),
                        ),
                      ),

                      const Expanded(flex: 42, child: SizedBox.shrink()),

                      SizedBox(height: height * 0.02),

                      Expanded(flex: 50, child: _buildPotsGrid(width)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CAPÇALERA
  // ---------------------------------------------------------------------------

  Widget _buildHeader(double width) {
    final t = AppLocalizations.of(context)!;
    final avatarSize = width < 360 ? 56.0 : 64.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.50),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.60),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),

          const SizedBox(width: 10),

          _FriendAvatarCircle(
            username: widget.friendUsername,
            avatarParts: widget.avatarParts,
            size: avatarSize,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.friendUsername,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B5E20),
                    shadows: [Shadow(color: Colors.white, blurRadius: 5)],
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  widget.gardenName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                    shadows: [Shadow(color: Colors.white, blurRadius: 5)],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Tooltip(
            message: _liked ? t.likedGarden : t.likeGarden,
            child: GestureDetector(
              onTap: _likeSending ? null : _giveLike,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _liked
                      ? const Color(0xFF4CAF50)
                      : Colors.white.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                  boxShadow: _liked
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF2E7D32,
                            ).withValues(alpha: 0.22),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: _likeSending
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _liked
                                ? Colors.white
                                : const Color(0xFF4CAF50),
                          ),
                        )
                      : Icon(
                          _liked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _liked
                              ? Colors.white
                              : const Color(0xFF4CAF50),
                          size: 22,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // GRAELLA DE TESTOS (read-only, sense onTap)
  // ---------------------------------------------------------------------------

  Widget _buildPotsGrid(double width) {
    final padding = _horizontalPadding(width);
    final spacing = _gridSpacing(width);

    return FutureBuilder<List<GardenPot>>(
      future: _potsFuture,
      builder: (context, snap) {
        final t = AppLocalizations.of(context)!;

        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white70,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${t.gardenLoadError}\n${snap.error}',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final pots = snap.data ?? [];

        if (pots.isEmpty) {
          return Center(
            child: Text(
              t.emptyFriendGarden,
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        const crossAxisCount = 4;
        final rowCount = (pots.length / crossAxisCount).ceil();

        return LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final totalHeight = constraints.maxHeight;

            final usableWidth = totalWidth - (padding * 2);
            final itemWidth =
                (usableWidth - (spacing * (crossAxisCount - 1))) /
                crossAxisCount;
            final itemHeight =
                (totalHeight - (spacing * (rowCount - 1))) / rowCount;
            final aspectRatio = itemHeight > 0 ? itemWidth / itemHeight : 1.0;

            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
              itemCount: pots.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, index) {
                final pot = pots[index];
                // PotWidget sense onTap → jardí de només lectura
                return PotWidget(pot: pot, onTap: () {});
              },
            );
          },
        );
      },
    );
  }
}

class _FriendAvatarCircle extends StatelessWidget {
  final String username;
  final Map<String, dynamic>? avatarParts;
  final double size;

  const _FriendAvatarCircle({
    required this.username,
    required this.avatarParts,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8F5E9),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: avatarParts != null
            ? AvatarStack(
                body: avatarParts!['body'] as String? ?? '',
                eye: avatarParts!['eye'] as String? ?? '',
                expression: avatarParts!['expression'] as String? ?? '',
                hair: avatarParts!['hair'] as String? ?? '',
                facialHair: avatarParts!['facialHair'] as String? ?? '',
                clothing: avatarParts!['clothing'] as String? ?? '',
                accessories: avatarParts!['accessories'] as String? ?? '',
              )
            : Center(
                child: Text(
                  username.isEmpty ? '?' : username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
              ),
      ),
    );
  }
}
