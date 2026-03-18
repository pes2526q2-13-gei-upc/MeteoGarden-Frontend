import 'package:flutter/material.dart';
import '../models/garden.dart';
import '../models/seed_option.dart';
import '../services/garden_service.dart';

class SeedSelectionSheet extends StatefulWidget {
  final GardenPot pot;
  final List<SeedOption> seeds;
  final String username;
  final String gardenName;
  final GardenService gardenService;
  final VoidCallback onPlantingSuccess;

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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F6F1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: _plantingResult != null
            ? _buildSuccessView()
            : _buildSelectionView(),
      ),
    );
  }

  // En cas que la planta s'hagi plantat correctament

  Widget _buildSuccessView() {
    final result = _plantingResult!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHandle(),
        const SizedBox(height: 18),

        // Icona d'èxit
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            color: Colors.green.shade700,
            size: 42,
          ),
        ),
        const SizedBox(height: 14),

        Text(
          result.message, //missatge que em retorna la api
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D2D2D),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Botó tancar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              widget.onPlantingSuccess();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
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

  //Vista seleccio llavor a plantar

  Widget _buildSelectionView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHandle(),
        const SizedBox(height: 18),

        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.eco_rounded,
                color: Colors.green.shade700,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Test buit",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Selecciona una llavor pel test ${widget.pot.potNumber}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        if (widget.seeds.isEmpty)
          _buildEmptyState()
        else ...[
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.seeds.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final seed = widget.seeds[index];
                final isSelected = _selectedSeed?.scientificName ==
                    seed.scientificName;

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => _selectedSeed = seed),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.shade50
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.green.shade400
                            : Colors.black12,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.green.shade100
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.spa_rounded,
                              color: Colors.green.shade700,
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
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Llavor disponible per plantar",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
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
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "x${seed.amount}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown.shade800,
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
                                    ? Colors.green.shade600
                                    : Colors.grey.shade500,
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

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: Colors.red.shade400, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Botó Plantar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  (_selectedSeed == null || _isPlanting) ? null : _plantSeed,
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
                _isPlanting ? 'Plantant...' : 'Plantar',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
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
        color: Colors.black12,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 42,
            color: Colors.brown.shade300,
          ),
          const SizedBox(height: 10),
          const Text(
            "No tens llavors disponibles",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Quan n'aconsegueixis, les podràs plantar aquí.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}