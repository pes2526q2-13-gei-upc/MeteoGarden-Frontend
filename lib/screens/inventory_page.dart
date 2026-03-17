import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/seed_option.dart';

// ─── API Service ──────────────────────────────────────────────────────────────

class InventoryApiService {
  final String baseUrl;
  final String username;

  InventoryApiService({required this.baseUrl, required this.username});

  Future<List<SeedOption>> fetchSeeds() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/laia/seeds/'), // canviar despres
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => SeedOption.fromJson(e)).toList();
    }
    throw Exception('Error carregant llavors: ${response.statusCode}');
  }

  Future<List<ProductItem>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/laia/products/'), // canviar despres
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ProductItem.fromJson(e)).toList();
    }
    throw Exception('Error carregant pocions: ${response.statusCode}');
  }
}

// ─── Inventory Page ───────────────────────────────────────────────────────────

class InventoryPage extends StatefulWidget {
  final String baseUrl;
  final String username;

  const InventoryPage({
    super.key,
    required this.baseUrl,
    required this.username,
  });

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  late final InventoryApiService _api;
  late final TabController _tabController;

  List<SeedOption> _seeds = [];
  List<ProductItem> _products = [];
  bool _loading = true;
  String? _error;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _api = InventoryApiService(
      baseUrl: widget.baseUrl,
      username: widget.username,
    );
    _tabController = TabController(length: 2, vsync: this);
    _loadInventory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.fetchSeeds(),
        _api.fetchProducts(),
      ]);
      setState(() {
        _seeds = results[0] as List<SeedOption>;
        _products = results[1] as List<ProductItem>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  int get _totalItems => _seeds.length + _products.length;

  List<SeedOption> get _filteredSeeds => _seeds
      .where((s) =>
          s.scientificName.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  List<ProductItem> get _filteredProducts => _products
      .where((p) =>
          p.productName.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                          errorBuilder: (_, __, ___) => const Icon(
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
                    const Text(
                      'El teu Inventari',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    if (!_loading && _error == null)
                      Text(
                        '$_totalItems elements disponibles',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: Color(0xFF4CAF50)),
                onPressed: () {},
              ),
            ],
          ),
          Positioned(
            left: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF4CAF50)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Cerca una llavor o poció...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon:
              const Icon(Icons.search, color: Color(0xFF9E9E9E), size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(30),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF4CAF50),
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grass, size: 16),
                  SizedBox(width: 6),
                  Text('Llavors'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science, size: 16),
                  SizedBox(width: 6),
                  Text('Pocions'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadInventory,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildSeedsGrid(),
        _buildProductsGrid(),
      ],
    );
  }

  Widget _buildSeedsGrid() {
    final items = _filteredSeeds;
    if (items.isEmpty) {
      return _buildEmptyState('No hi ha llavors disponibles');
    }
    return RefreshIndicator(
      onRefresh: _loadInventory,
      color: const Color(0xFF4CAF50),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _SeedCard(seed: items[index]),
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    final items = _filteredProducts;
    if (items.isEmpty) {
      return _buildEmptyState('No hi ha pocions disponibles');
    }
    return RefreshIndicator(
      onRefresh: _loadInventory,
      color: const Color(0xFF4CAF50),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _ProductCard(product: items[index]),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ─── Seed Card ────────────────────────────────────────────────────────────────

class _SeedCard extends StatelessWidget {
  final SeedOption seed;

  const _SeedCard({required this.seed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                'assets/images/seeds/${seed.scientificName.toLowerCase().replaceAll(' ', '_')}.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.local_florist,
                  size: 40,
                  color: Color(0xFF66BB6A),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              seed.scientificName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
            Text(
              'Quantitat: ${seed.amount}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final ProductItem product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                'assets/images/products/${product.productName.toLowerCase().replaceAll(' ', '_')}.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.science,
                  size: 40,
                  color: Color(0xFF7E57C2),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.productName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4527A0),
              ),
            ),
            Text(
              'Quantitat: ${product.amount}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}