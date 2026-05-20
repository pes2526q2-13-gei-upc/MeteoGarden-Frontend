import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import '../models/url.dart';

const Color _pageBackground = Color(0xFFF5F9F0);
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _darkGreen = Color(0xFF2E7D32);
const Color _deepGreen = Color(0xFF1B5E20);
const Color _cardWhite = Colors.white;

class ShopPage extends StatefulWidget {
  final http.Client? httpClient; // per al test

  const ShopPage({super.key, this.httpClient});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  late final http.Client _client; // per al test

  List<dynamic> seeds = [];
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _client = widget.httpClient ?? http.Client(); // per al test
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchShopItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 1. OBTENIR DADES DE LA BOTIGA
  Future<void> fetchShopItems() async {
    final l10n = AppLocalizations.of(context)!;
    final token = Provider.of<UserModel>(context, listen: false).token;
    final url = Uri.parse('${ApiConfig.baseUrl}/api/shop/');

    try {
      final response = await _client.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            seeds = data['seeds'] ?? [];
            products = data['products'] ?? [];
            isLoading = false;
          });
        }
      } else {
        _showError(l10n.shopLoadError);
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      _showError(l10n.shopConnectionError);
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> buyItem(bool isSeed, Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context)!;

    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: _primaryGreen)),
    );

    final token = Provider.of<UserModel>(context, listen: false).token;
    final username = Provider.of<UserModel>(context, listen: false).username;

    final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$username/buy/');

    final body = jsonEncode({
      "type": isSeed ? "seed" : "product",
      "name": isSeed ? item['scientificName'] : item['name'],
      "price": item['price'],
    });

    try {
      final response = await _client.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
        body: body,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        Provider.of<UserModel>(
          context,
          listen: false,
        ).setCoins(jsonDecode(response.body)['coins_remaining']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.shopPurchaseSuccess),
            backgroundColor: _darkGreen,
          ),
        );
      } else {
        _showError(
          jsonDecode(response.body)['error'] ??
              l10n.shopPurchaseProcessingError,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showError(l10n.shopPurchaseProcessingError);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showItemDetails(
    BuildContext context,
    bool isSeed,
    Map<String, dynamic> item,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final String name = isSeed
        ? (item['commonName'] ?? item['scientificName'])
        : (item['displayName'] ?? item['display_name'] ?? item['name']);
    final String? description = item['description']?.toString();
    final int price = item['price'] ?? 0;

    final String imageUrl = item['image_url']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                isSeed
                                    ? Icons.eco_rounded
                                    : Icons.shopping_bag_rounded,
                                color: _primaryGreen,
                                size: 34,
                              );
                            },
                          )
                        : Icon(
                            isSeed
                                ? Icons.eco_rounded
                                : Icons.shopping_bag_rounded,
                            color: _primaryGreen,
                            size: 34,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _deepGreen,
                          ),
                        ),
                        if (isSeed && item['family'] != null)
                          Text(
                            item['family'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (description != null && description.isNotEmpty) ...[
                Text(
                  l10n.commonDescription,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _primaryGreen.withValues(alpha: 0.22),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.shopTotalPrice,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _deepGreen,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "$price",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: _darkGreen,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.monetization_on_rounded,
                          color: Colors.amber,
                          size: 28,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        l10n.commonBack,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => buyItem(isSeed, item),
                      style: FilledButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        l10n.shopBuyButton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final totalItems = seeds.length + products.length;

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 28,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.eco,
                            color: _primaryGreen,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'MeteoGarden',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _darkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.shopTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _deepGreen,
                      ),
                    ),
                    if (!isLoading)
                      Text(
                        '$totalItems articles disponibles',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (Navigator.canPop(context))
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: _primaryGreen,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            return TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: _primaryGreen,
                borderRadius: BorderRadius.circular(30),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: _primaryGreen,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                _ShopTab(
                  icon: Icons.eco_rounded,
                  label: l10n.shopSeedsTab,
                  selected: _tabController.index == 0,
                ),
                _ShopTab(
                  icon: Icons.shopping_bag_rounded,
                  label: l10n.shopOtherTab,
                  selected: _tabController.index == 1,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryGreen),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [_buildItemList(seeds, true), _buildItemList(products, false)],
    );
  }

  Widget _buildItemList(List<dynamic> items, bool isSeed) {
    final l10n = AppLocalizations.of(context)!;

    if (items.isEmpty) {
      return _EmptyShopState(
        icon: isSeed ? Icons.eco_outlined : Icons.shopping_bag_outlined,
        message: l10n.shopNoItemsAvailable,
      );
    }

    return RefreshIndicator(
      color: _primaryGreen,
      onRefresh: fetchShopItems,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final name = isSeed
              ? (item['commonName'] ?? item['scientificName'])
              : (item['displayName'] ?? item['display_name'] ?? item['name']);
          final price = item['price'] ?? 0;

          final String imageUrl = item['image_url']?.toString() ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => _showItemDetails(
                  context,
                  isSeed,
                  item as Map<String, dynamic>,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: _cardWhite.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.04),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: _primaryGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    isSeed
                                        ? Icons.eco_rounded
                                        : Icons.shopping_bag_rounded,
                                    color: _primaryGreen,
                                    size: 28,
                                  );
                                },
                              )
                            : Icon(
                                isSeed
                                    ? Icons.eco_rounded
                                    : Icons.shopping_bag_rounded,
                                color: _primaryGreen,
                                size: 28,
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            if (isSeed && item['family'] != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                item['family'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _primaryGreen.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$price",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: _darkGreen,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.monetization_on_rounded,
                              color: Colors.amber,
                              size: 19,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/imatge_fondo1.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: _pageBackground),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.76),
                    _pageBackground.withValues(alpha: 0.96),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _ShopTab({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _EmptyShopState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyShopState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                color: _primaryGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: _primaryGreen),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
