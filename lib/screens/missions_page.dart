import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';
import '../models/missions.dart';
import '../widgets/mission_card.dart';
import 'package:provider/provider.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import '../services/mission_service.dart';
import '../widgets/centered_message.dart';

class MissionsPage extends StatefulWidget {
  final Future<List<Mission>> Function(String token)? fetchMissions;
  final Future<int> Function(String token, Mission mission)? claimMission;
  final void Function(int coins)? onCoinsEarned;
  final String? tokenOverride;

  const MissionsPage({
    super.key,
    this.fetchMissions,
    this.claimMission,
    this.onCoinsEarned,
    this.tokenOverride,
  });

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  List<Mission> _missions = [];
  bool _isLoading = true;
  String? _error;

  String _getToken() {
    return widget.tokenOverride ??
        Provider.of<UserModel>(context, listen: false).token;
  }

  @override
  void initState() {
    super.initState();
    _fetchMissions();
  }

  Future<void> _fetchMissions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = _getToken();

      final missions = widget.fetchMissions != null
          ? await widget.fetchMissions!(token)
          : await MissionService.fetchMissions(token: token);

      if (!mounted) return;

      setState(() {
        _missions = missions;
        _isLoading = false;
      });
    } on MissionException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }
  
  Future<void> _claimMission(Mission mission) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final token = _getToken();

      final coinsEarned = widget.claimMission != null
          ? await widget.claimMission!(token, mission)
          : await MissionService.claimMission(
              token: token,
              mission: mission,
            );

      if (coinsEarned > 0 && mounted) {
        if (widget.onCoinsEarned != null) {
          widget.onCoinsEarned!(coinsEarned);
        } else {
          final userModel = Provider.of<UserModel>(context, listen: false);
          userModel.setCoins(userModel.monedes + coinsEarned);
        }
      }

      if (!mounted) return;

      CenteredMessage.show(
        context,
        l10n.missionsClaimSuccess,
        type: CenteredMessageType.success,
      );

      await _fetchMissions();
    } on MissionException catch (e) {
      if (!mounted) return;

      final errorMsg = switch (e.message) {
        'Mission already claimed' => l10n.missionsErrorAlreadyClaimed,
        'Mission in progress' => l10n.missionsErrorInProgress,
        'Mission not found' => l10n.missionsErrorNotFound,
        _ => l10n.missionsErrorGeneric,
      };

      CenteredMessage.show(
        context,
        errorMsg,
        type: CenteredMessageType.error,
      );
    }
  }


  int get _completedCount =>
      _missions.where((m) => m.isCompleted || m.isClaimed).length;

  int get _inProgressCount => _missions.where((m) => m.isInProgress).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/imatge_fondo1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.white.withValues(alpha: 0.18),
          child: SafeArea(
            child: Column(
              children: [
                _MissionsHeader(
                  total: _missions.length,
                  completed: _completedCount,
                  inProgress: _inProgressCount,
                ),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2F6B43)),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 48),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchMissions,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6B43),
              ),
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      );
    }
    if (_missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flag_outlined, color: Colors.white54, size: 56),
            const SizedBox(height: 16),
            Text(
              l10n.missionsEmpty,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final active = _missions.where((m) => !m.isClaimed).toList()
      ..sort((a, b) {
        int priority(Mission m) => m.isCompleted ? 0 : 1;
        return priority(a).compareTo(priority(b));
      });

    final claimed = _missions.where((m) => m.isClaimed).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        if (active.isNotEmpty) ...[
          _SectionTitle(
            icon: Icons.flag_rounded,
            title: l10n.missionsActiveSectionTitle,
            color: const Color(0xFF2F6B43),
            backgroundColor: Colors.white.withValues(alpha: 0.78),
          ),
          const SizedBox(height: 12),
          ...active.map(
            (m) => MissionCard(
              mission: m,
              onClaim: m.isCompleted ? () => _claimMission(m) : null,
            ),
          ),
        ],

        if (claimed.isNotEmpty) ...[
          const SizedBox(height: 14),
          _SectionTitle(
            icon: Icons.check_circle_rounded,
            title: l10n.missionsClaimedSectionTitle,
            color: Colors.grey.shade700,
            backgroundColor: Colors.white.withValues(alpha: 0.72),
          ),
          const SizedBox(height: 12),
          ...claimed.map((m) => MissionCard(mission: m, onClaim: null)),
        ],
      ],
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _MissionsHeader extends StatelessWidget {
  final int total;
  final int completed;
  final int inProgress;

  const _MissionsHeader({
    required this.total,
    required this.completed,
    required this.inProgress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2F6B43).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFDDF3D8),
                child: Icon(Icons.flag, color: Color(0xFF1E6B35), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.missionsTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.missionsSubtitle,
                      style: const TextStyle(
                        color: Color(0xFFDDEDDD),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeaderStat(
                  icon: Icons.check_circle_outline,
                  label: l10n.missionsCompleted,
                  value: '$completed',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderStat(
                  icon: Icons.pending_outlined,
                  label: l10n.missionsInProgress,
                  value: '$inProgress',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeaderStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFDDEDDD),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section widgets ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color backgroundColor;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
