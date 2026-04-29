import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meteo_garden/screens/home_shell.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../models/url.dart';
import '../../models/avatar_stack.dart';
import '../../models/dades_usr.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
//import '../widgets/app_header.dart';

class AvatarEditorPage extends StatefulWidget {
  final bool isNewUser;

  const AvatarEditorPage({super.key, this.isNewUser = true});

  @override
  State<AvatarEditorPage> createState() => _AvatarEditorPageState();
}

class _AvatarEditorPageState extends State<AvatarEditorPage> {
  // --- ESTADOS DE CARGA ---
  bool isLoading = true;
  bool isSaving = false;

  // --- ESTADO ACTUAL DEL AVATAR ---
  String currentBody = '';
  String currentEye = '';
  String currentExpression = '';
  String currentHair = '';
  String currentFacialHair = '';
  String currentClothing = '';
  String currentAccessories = '';
  String selectedHairColor = 'blond';

  final List<String> categories = [
    'Body',
    'Eyes',
    'Expression',
    'Hair',
    'Facial Hair',
    'Clothing',
    'Accessories',
  ];

  Map<String, List<String>> options = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // ==========================================
  // INICIALIZACIÓN SECUENCIAL
  // ==========================================
  Future<void> _initializeData() async {
    // 1. Primero cargamos las opciones disponibles
    await _fetchAvatarOptions();

    if (!mounted) return;

    // 2. Decidimos qué datos cargar según el tipo de usuario
    if (widget.isNewUser) {
      _setDefaultsFromOptions();
    } else {
      await _fetchUserAvatar();
    }

    // 3. Quitamos el estado de carga
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // ==========================================
  // CARGAR OPCIONES DESDE LA API
  // ==========================================
  Future<void> _fetchAvatarOptions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/avatar/'),
      );

      debugPrint('--- DEBUG FETCH OPTIONS ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('---------------------------');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (!mounted) return;
        setState(() {
          options = parseAvatarData(data);
        });
      } else {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        _showError('${l10n.errorLoadingOptions}: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('--- EXCEPTION FETCH OPTIONS ---');
      debugPrint('Error: $e');
      debugPrint('-------------------------------');

      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _showError(l10n.errorConnectionOptions);
    }
  }

  // ==========================================
  // PARSEAR EL JSON COMPLEJO DEL BACKEND
  // ==========================================
  Map<String, List<String>> parseAvatarData(Map<String, dynamic> data) {
    Map<String, List<String>> parsedOptions = {};

    final categoryMapping = {
      'body': 'Body',
      'eye': 'Eyes',
      'expression': 'Expression',
      'hair': 'Hair',
      'facialHair': 'Facial Hair',
      'clothing': 'Clothing',
      'accessories': 'Accessories',
    };

    data.forEach((key, value) {
      String mappedCategory = categoryMapping[key] ?? key;
      List<String> urls = [];

      if (value is List) {
        for (var item in value) {
          if (item['url'] != null) {
            urls.add(item['url'].toString().replaceAll('.com//', '.com/'));
          }
        }
      } else if (value is Map) {
        for (var subList in value.values) {
          if (subList is List) {
            for (var item in subList) {
              if (item['url'] != null) {
                urls.add(item['url'].toString().replaceAll('.com//', '.com/'));
              }
            }
          }
        }
      }

      parsedOptions[mappedCategory] = urls;
    });

    if (parsedOptions.containsKey('Hair'))
      parsedOptions['Hair']!.insert(0, 'none');
    if (parsedOptions.containsKey('Facial Hair'))
      parsedOptions['Facial Hair']!.insert(0, 'none');
    if (parsedOptions.containsKey('Accessories'))
      parsedOptions['Accessories']!.insert(0, 'none');

    return parsedOptions;
  }

  // ==========================================
  // ESTABLECER POR DEFECTO (USUARIOS NUEVOS)
  // ==========================================
  void _setDefaultsFromOptions() {
    setState(() {
      currentBody = options['Body']?.isNotEmpty == true
          ? options['Body']![0]
          : '';
      currentEye = options['Eyes']?.isNotEmpty == true
          ? options['Eyes']![0]
          : '';
      currentExpression = options['Expression']?.isNotEmpty == true
          ? options['Expression']![0]
          : '';
      currentHair = options['Hair']?.isNotEmpty == true
          ? options['Hair']![0]
          : '';
      currentFacialHair = options['Facial Hair']?.isNotEmpty == true
          ? options['Facial Hair']![0]
          : '';
      currentClothing = options['Clothing']?.isNotEmpty == true
          ? options['Clothing']![0]
          : '';
      currentAccessories = options['Accessories']?.isNotEmpty == true
          ? options['Accessories']![0]
          : '';
    });
  }

  // ==========================================
  // OBTENER AVATAR (USUARIOS EXISTENTES)
  // ==========================================
  Future<void> _fetchUserAvatar() async {
    final user = Provider.of<UserModel>(context, listen: false);
    final username = user.username;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/users/$username/avatar'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          currentBody = _extractId(data['body']) ?? currentBody;
          currentEye = _extractId(data['eye']) ?? currentEye;
          currentClothing = _extractId(data['clothing']) ?? currentClothing;
          currentAccessories =
              _extractId(data['accessories']) ?? currentAccessories;
          currentExpression =
              _extractId(data['expression']) ?? currentExpression;
          currentHair = _extractId(data['hair']) ?? currentHair;
          currentFacialHair =
              _extractId(data['facialHair']) ?? currentFacialHair;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _showError(l10n.errorConnectionAvatar);
    }
  }

  // Función auxiliar para sacar el ID numérico de cualquier URL
  String? _extractId(String? url) {
    if (url == null || url.isEmpty || url == 'none') return '0';
    try {
      final parts = url.split('/');
      for (var i = parts.length - 1; i >= 0; i--) {
        final cleanPart = parts[i].replaceAll('.png', '');
        if (int.tryParse(cleanPart) != null) {
          return cleanPart;
        }
      }
      return '0';
    } catch (e) {
      return '0';
    }
  }

  // ==========================================
  // GUARDAR EL AVATAR EN LA API
  // ==========================================
  Future<void> _saveAvatar() async {
    setState(() => isSaving = true);

    final user = Provider.of<UserModel>(context, listen: false);
    final username = user.username;

    try {
      final payload = {
        'body': _extractId(currentBody),
        'eye': _extractId(currentEye),
        'expression': _extractId(currentExpression),
        'hair': _extractId(currentHair),
        'facial_hair': _extractId(currentFacialHair),
        'clothing': _extractId(currentClothing),
        'accessories': _extractId(currentAccessories),
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/users/$username/save/avatar'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Token ${user.token}",
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        if (widget.isNewUser) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeShell()),
          );
        } else {
          Navigator.pop(context);
        }
      } else {
        debugPrint('Error del backend: ${response.body}');
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        _showError('${l10n.errorSavingAvatar}: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _showError(l10n.errorConnectionSaving);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void updateAvatar(String category, String item) {
    setState(() {
      switch (category) {
        case 'Body':
          currentBody = item;
          break;
        case 'Eyes':
          currentEye = item;
          break;
        case 'Expression':
          currentExpression = item;
          break;
        case 'Hair':
          currentHair = item;
          break;
        case 'Facial Hair':
          currentFacialHair = item;
          break;
        case 'Clothing':
          currentClothing = item;
          break;
        case 'Accessories':
          currentAccessories = item;
          break;
      }
    });
  }

  Widget _buildColorDot(String colorId, Color displayColor) {
    bool isSelected = selectedHairColor == colorId;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedHairColor = colorId;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: displayColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFF355F3F) : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            if (isSelected)
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
          ],
        ),
      ),
    );
  }

  // Traductor auxiliar para las pestañas
  String _getLocalizedCategoryName(String category, AppLocalizations l10n) {
    switch (category) {
      case 'Body':
        return l10n.categoryBody;
      case 'Eyes':
        return l10n.categoryEyes;
      case 'Expression':
        return l10n.categoryExpression;
      case 'Hair':
        return l10n.categoryHair;
      case 'Facial Hair':
        return l10n.categoryFacialHair;
      case 'Clothing':
        return l10n.categoryClothing;
      case 'Accessories':
        return l10n.categoryAccessories;
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ------------------------------------
    // PANTALLA DE CARGA INICIAL
    // ------------------------------------
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isNewUser ? l10n.createYourAvatar : l10n.editAvatar,
          ),
          backgroundColor: const Color(0xFF355F3F),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF355F3F)),
        ),
      );
    }

    // ------------------------------------
    // PANTALLA DEL EDITOR
    // ------------------------------------
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isNewUser ? l10n.createYourAvatar : l10n.editAvatar,
          ),
          backgroundColor: const Color(0xFF355F3F),
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // --- ZONA DE VISTA PREVIA ---
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: const Border(
                  bottom: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              child: Center(
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: AvatarStack(
                    body: currentBody,
                    eye: currentEye,
                    expression: currentExpression,
                    hair: currentHair,
                    facialHair: currentFacialHair,
                    clothing: currentClothing,
                    accessories: currentAccessories,
                  ),
                ),
              ),
            ),

            // --- PESTAÑAS (TABS) ---
            TabBar(
              isScrollable: true,
              labelColor: const Color(0xFF355F3F),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF355F3F),
              // Traducimos el texto de cada pestaña
              tabs: categories
                  .map((cat) => Tab(text: _getLocalizedCategoryName(cat, l10n)))
                  .toList(),
            ),

            // --- ZONA DE SELECCIÓN DE OPCIONES ---
            Expanded(
              child: TabBarView(
                children: categories.map((category) {
                  final items = options[category] ?? [];

                  if (items.isEmpty) {
                    return Center(child: Text(l10n.noOptionsAvailable));
                  }

                  List<String> displayedItems = items;
                  Widget? topMenu;

                  if (category == 'Hair') {
                    displayedItems = items
                        .where(
                          (url) =>
                              url == 'none' ||
                              url.contains('/$selectedHairColor/'),
                        )
                        .toList();

                    topMenu = Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildColorDot('blond', Colors.amber.shade300),
                        _buildColorDot('brown', Colors.brown),
                        _buildColorDot('dark', Colors.black87),
                      ],
                    );
                  }

                  Widget grid = GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: displayedItems.length,
                    itemBuilder: (context, index) {
                      final item = displayedItems[index];

                      bool isSelected = false;
                      switch (category) {
                        case 'Body':
                          isSelected = currentBody == item;
                          break;
                        case 'Eyes':
                          isSelected = currentEye == item;
                          break;
                        case 'Expression':
                          isSelected = currentExpression == item;
                          break;
                        case 'Hair':
                          isSelected = currentHair == item;
                          break;
                        case 'Facial Hair':
                          isSelected = currentFacialHair == item;
                          break;
                        case 'Clothing':
                          isSelected = currentClothing == item;
                          break;
                        case 'Accessories':
                          isSelected = currentAccessories == item;
                          break;
                      }

                      return GestureDetector(
                        onTap: () => updateAvatar(category, item),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF355F3F)
                                  : Colors.grey.shade300,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item == 'none'
                                ? const Center(
                                    child: Icon(
                                      Icons.block,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  )
                                : Image.network(
                                    item,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF355F3F),
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
                                  ),
                          ),
                        ),
                      );
                    },
                  );

                  if (category == 'Hair' && topMenu != null) {
                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        topMenu,
                        Expanded(child: grid),
                      ],
                    );
                  }

                  return grid;
                }).toList(),
              ),
            ),

            // --- BOTÓN DE GUARDAR ---
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isSaving ? null : _saveAvatar,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF355F3F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            widget.isNewUser
                                ? l10n.continueButton
                                : l10n.saveChangesButton,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
