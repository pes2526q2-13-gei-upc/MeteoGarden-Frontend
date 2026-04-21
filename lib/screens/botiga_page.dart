import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:meteo_garden/l10n/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import '../models/url.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;

  List<dynamic> seeds = [];
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchShopItems();
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
      final response = await http.get(
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

  // 2. COMPRAR UN ARTICLE
  Future<void> buyItem(bool isSeed, Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context)!;

    Navigator.pop(context); // Tanquem el BottomSheet primer

    // Mostrem un indicador de càrrega
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF166534)),
      ),
    );

    final token = Provider.of<UserModel>(context, listen: false).token;
    final username = Provider.of<UserModel>(context, listen: false).username;

    final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$username/buy/');

    // Preparem el payload depenent de si és llavor o producte
    final body = jsonEncode({
      "type": isSeed ? "seed" : "product",
      "name": isSeed ? item['scientificName'] : item['name'],
      "price": item['price'],
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
        body: body,
      );

      if (!mounted) return;
      Navigator.pop(context); // Amaguem l'indicador de càrrega

      if (response.statusCode == 200) {
        Provider.of<UserModel>(
          context,
          listen: false,
        ).setCoins(jsonDecode(response.body)['coins_remaining']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.shopPurchaseSuccess),
            backgroundColor: const Color(0xFF166534),
          ),
        );
      } else {
        _showError(
          jsonDecode(response.body)['error'] ?? l10n.shopPurchaseProcessingError,
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

  // 3. BOTTOM SHEET DE DETALLS I CONFIRMACIÓ
  void _showItemDetails(
      BuildContext context,
      bool isSeed,
      Map<String, dynamic> item,
      ) {
    final l10n = AppLocalizations.of(context)!;

    final String name = isSeed
        ? (item['commonName'] ?? item['scientificName'])
        : item['name'];
    final String? description = isSeed ? item['description'] : null;
    final int price = item['price'] ?? 0;

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
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                    child: Icon(
                      isSeed ? Icons.eco_rounded : Icons.shopping_bag_rounded,
                      color: const Color(0xFF166534),
                      size: 32,
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
                            fontWeight: FontWeight.bold,
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
              if (description != null) ...[
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.shopTotalPrice,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "$price",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF166534),
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
              const SizedBox(height: 32),
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
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => buyItem(isSeed, item),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF166534),
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

  Widget _buildItemList(List<dynamic> items, bool isSeed) {
    final l10n = AppLocalizations.of(context)!;

    if (items.isEmpty) {
      return Center(
        child: Text(
          l10n.shopNoItemsAvailable,
          style: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final name = isSeed
            ? (item['commonName'] ?? item['scientificName'])
            : item['name'];
        final price = item['price'] ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSeed ? Icons.eco_rounded : Icons.shopping_bag_rounded,
                color: const Color(0xFF166534),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: isSeed && item['family'] != null
                ? Text(
              item['family'],
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$price",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF166534),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
              ],
            ),
            onTap: () => _showItemDetails(context, isSeed, item),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          l10n.shopTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/imatge_fondo1.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.70),
                    Colors.green.withValues(alpha: 0.20),
                    Colors.white.withValues(alpha: 0.95),
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
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    labelColor: const Color(0xFF166534),
                    unselectedLabelColor: Colors.white,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    tabs: [
                      Tab(text: l10n.shopSeedsTab),
                      Tab(text: l10n.shopOtherTab),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                      : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildItemList(seeds, true),
                      _buildItemList(products, false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}