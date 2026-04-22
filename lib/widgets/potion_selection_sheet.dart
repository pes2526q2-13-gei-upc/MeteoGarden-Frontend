import 'package:flutter/material.dart';
import '../models/garden.dart';
import '../services/garden_service.dart';
import '../models/seed_option.dart';
import 'package:meteo_garden/generated/app_localizations.dart';

class PotionSelectionSheet extends StatefulWidget {
  final GardenPot pot;
  final String username;
  final String gardenName;
  final GardenService gardenService;
  final VoidCallback onPotionSuccess;

  const PotionSelectionSheet({
    super.key,
    required this.pot,
    required this.username,
    required this.gardenName,
    required this.gardenService,
    required this.onPotionSuccess,
  });

  @override
  State<PotionSelectionSheet> createState() => _PotionSelectionSheetState();
}

class _PotionSelectionSheetState extends State<PotionSelectionSheet> {
  ProductItem? _selectedPotion;
  bool _isApplying = false;
  String? _potionResult;
  String? _errorMessage;
  late Future<List<ProductItem>> _productsFuture;

  static const Color potionYellow = Color(0xFFFCD34D);
  

  @override
  void initState() {
    super.initState();
    _productsFuture = widget.gardenService.fetchProducts(widget.username);
  }

  Future<void> _applyPotion() async {
    if (_selectedPotion == null) return;

    setState(() {
      _isApplying = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.gardenService.applyPotion(
        username: widget.username,
        gardenName: widget.gardenName,
        potNumber: widget.pot.potNumber,
        productName: _selectedPotion!.productName,
      );

      setState(() {
        _potionResult = result;
        _isApplying = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isApplying = false;
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
                child: _potionResult != null
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHandle(),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: potionYellow.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: potionYellow.withValues(alpha: 0.6)),
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: potionYellow,
            size: 42,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _potionResult!,
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
            onPressed: () {
              widget.onPotionSuccess();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: potionYellow,
              foregroundColor: Colors.black,
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
                color: potionYellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: potionYellow.withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.local_drink,
                color: potionYellow,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.aplyPotion,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${t.selectPotion} ${widget.pot.potNumber}",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<ProductItem>>(
          future: _productsFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.hasError) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 42,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t.errorPotions,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            final potions = snap.data ?? [];

            if (potions.isEmpty) {
              return _buildEmptyState(context);
            }

            return Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: potions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final potion = potions[index];
                  final isSelected =
                      _selectedPotion?.productName == potion.productName;

                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _selectedPotion = potion),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? potionYellow.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? potionYellow.withValues(alpha: 0.8)
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
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? potionYellow.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.local_drink,
                                color: potionYellow,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    potion.productName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    t.readyPotion,
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
                                    color: potionYellow.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: potionYellow.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "x${potion.amount}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: potionYellow,
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
                                      ? potionYellow
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
            );
          },
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
            onPressed: (_selectedPotion == null || _isApplying)
                ? null
                : _applyPotion,
            icon: _isApplying
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.local_drink),
            label: Text(
              _isApplying ? t.aplyingPotion : t.aplyPotion,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: potionYellow,
              foregroundColor: Colors.black,
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
            t.noPotions,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            t.extraPotions,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
