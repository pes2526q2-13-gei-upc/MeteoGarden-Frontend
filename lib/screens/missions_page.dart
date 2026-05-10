import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../generated/app_localizations.dart';
import '../models/url.dart';
import '../models/missions.dart';
import '../widgets/mission_card.dart';
import 'package:provider/provider.dart';
import 'package:meteo_garden/models/dades_usr.dart';

class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  List<Mission> _missions = [];
  bool _isLoading = true;
  String? _error;

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
      final token = Provider.of<UserModel>(context, listen: false).token;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/missions/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['missions'];
        setState(() {
          _missions = list.map((e) => Mission.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _claimMission(Mission mission) async {
    try {
        final token = Provider.of<UserModel>(context, listen: false).token;
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/user/missions/claim/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
          body: jsonEncode({'mission': mission.name}),
        );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['coins'] ?? '¡Recompensa reclamada!'),
              backgroundColor: const Color(0xFF2F6B43),
            ),
          );
          _fetchMissions(); // refresca la lista
        }
      } else {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['error'] ?? 'No se pudo reclamar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            child: Text(AppLocalizations.of(context)!.commonRetry),
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
            AppLocalizations.of(context)!.missionsEmpty,
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
  

    // Ordenamos: completadas (reclamables) primero, luego en curso, luego reclamadas
    final sorted = [..._missions]..sort((a, b) {
        int priority(Mission m) {
          if (m.isCompleted) return 0;
          if (m.isInProgress) return 1;
          return 2;
        }
        return priority(a).compareTo(priority(b));
      });

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final mission = sorted[index];
        return MissionCard(
          mission: mission,
          onClaim: mission.isCompleted ? () => _claimMission(mission) : null,
        );
      },
    );
  }
}

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
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 12),
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
                  label: 'Completadas',
                  value: '$completed',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderStat(
                  icon: Icons.pending_outlined,
                  label: 'En curso',
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