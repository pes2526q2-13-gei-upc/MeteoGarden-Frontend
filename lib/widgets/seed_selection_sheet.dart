import 'package:flutter/material.dart';
import '../models/garden.dart';
import '../models/seed_option.dart';
import '../services/garden_service.dart';
import 'package:meteo_garden/generated/app_localizations.dart';

class SeedSelectionSheet extends StatefulWidget {
  final GardenPot pot;
  final List<SeedOption> seeds;
  final String username;
  final String gardenName;
  final GardenService gardenService;
  final Future<void> Function(int potNumber) onPlantingSuccess;

  const SeedSelectionSheet({
    super.key,
    required this.pot,
    required this.seeds,
    required this.username,
    required this.gardenName,
    required this.gardenService,
    required this.onPlantingSuccess,
  });

  @override
  State<SeedSelectionSheet> createState() => _SeedSelectionSheetState();
}

class _SeedSelectionSheetState extends State<SeedSelectionSheet> {
  SeedOption? _selectedSeed;
  bool _isPlanting = false;
  PlantingResult? _plantingResult;
  String? _errorMessage;

  Future<void> _plantSeed() async {
    if (_selectedSeed == null) return;

    setState(() {
      _isPlanting = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.gardenService.plantSeed(
        username: widget.username,
        gardenName: widget.gardenName,
        potNumber: widget.pot.potNumber,
        scientificName: _selectedSeed!.scientificName,
      );

      setState(() {
        _plantingResult = result;
        _isPlanting = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isPlanting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Material(
        color: const Color(0xFF1F2937),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/foto_terra2.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.65)),
            ),
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: _plantingResult != null
                    ? _buildSuccessView()
                    : _buildSelectionView(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    final result = _plantingResult!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHandle(),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Colors.greenAccent,
            size: 42,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          result.message,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await widget.onPlantingSuccess(widget.pot.potNumber);
              if (!context.mounted) return;
              navigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16a34a),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Tancar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionView(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHandle(),
        const SizedBox(height: 18),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.greenAccent,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.testbuit,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${t.selectionLlavor} ${widget.pot.potNumber}",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        if (widget.seeds.isEmpty)
          _buildEmptyState(context)
        else ...[
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.seeds.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final seed = widget.seeds[index];
                final isSelected =
                    _selectedSeed?.scientificName == seed.scientificName;

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => _selectedSeed = seed),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.withValues(alpha: 0.18)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.greenAccent.withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.14),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.green.withValues(alpha: 0.24)
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: (seed.imageUrl?.isNotEmpty ?? false)
                                ? Image.network(
                                    seed.imageUrl!,
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null){
                                            return child;
                                          }
                                          return const Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        },
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.spa_rounded,
                                      color: Colors.greenAccent,
                                      size: 28,
                                    ),
                                  )
                                : const Icon(
                                    Icons.spa_rounded,
                                    color: Colors.greenAccent,
                                    size: 28,
                                  ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  seed.scientificName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t.llavorDisp,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  "x${seed.amount}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFE082),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: isSelected
                                    ? Colors.greenAccent
                                    : Colors.white54,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_selectedSeed == null || _isPlanting)
                  ? null
                  : _plantSeed,
              icon: _isPlanting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.spa_rounded),
              label: Text(
                _isPlanting ? t.planting : t.plant,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16a34a),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.white24,
                disabledForegroundColor: Colors.white60,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 42, color: Colors.white70),
          SizedBox(height: 10),
          Text(
            t.noLlavor,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            t.extraLlavor,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
