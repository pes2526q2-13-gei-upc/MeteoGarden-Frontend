import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meteo_garden/screens/home_shell.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../models/url.dart'; 
import '../../models/avatar_stack.dart';
import '../../models/dades_usr.dart';

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

  final List<String> categories = [
    'Body', 'Eyes', 'Expression', 'Hair', 'Facial Hair', 'Clothing', 'Accessories'
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
        _showError('Error loading options: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('--- EXCEPTION FETCH OPTIONS ---');
      debugPrint('Error: $e');
      debugPrint('-------------------------------');

      _showError('Connection error while loading options.');
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
      'accessories': 'Accessories'
    };

    data.forEach((key, value) {
      String mappedCategory = categoryMapping[key] ?? key;
      List<String> urls = [];

      if (value is List) {
        for (var item in value) {
          if (item['url'] != null) {
            // per que el back envia els links amb //
            urls.add(item['url'].toString().replaceAll('.com//', '.com/'));
          }
        }
      } else if (value is Map) {
        for (var subList in value.values) {
          if (subList is List) {
            for (var item in subList) {
              if (item['url'] != null) {
                // 👇 Y AQUI TAMBIEN 👇
                urls.add(item['url'].toString().replaceAll('.com//', '.com/'));
              }
            }
          }
        }
      }
      
      parsedOptions[mappedCategory] = urls;
    });

    return parsedOptions;
  }

  // ==========================================
  // ESTABLECER POR DEFECTO (USUARIOS NUEVOS)
  // ==========================================
  void _setDefaultsFromOptions() {
    setState(() {
      // Toma el primer elemento de cada lista si existe
      currentBody = options['Body']?.isNotEmpty == true ? options['Body']![0] : '';
      currentEye = options['Eyes']?.isNotEmpty == true ? options['Eyes']![0] : '';
      currentExpression = options['Expression']?.isNotEmpty == true ? options['Expression']![0] : '';
      currentHair = options['Hair']?.isNotEmpty == true ? options['Hair']![0] : '';
      currentFacialHair = options['Facial Hair']?.isNotEmpty == true ? options['Facial Hair']![0] : '';
      currentClothing = options['Clothing']?.isNotEmpty == true ? options['Clothing']![0] : '';
      currentAccessories = options['Accessories']?.isNotEmpty == true ? options['Accessories']![0] : '';
    });
  }

  // ==========================================
  // OBTENER AVATAR (USUARIOS EXISTENTES)
  // ==========================================
  Future<void> _fetchUserAvatar() async {
    // Ajusta "UserModel" al nombre real de tu clase Provider
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
          currentAccessories = _extractId(data['accessories']) ?? currentAccessories;
          
          // Nota: Si las URLs de estos elementos son muy diferentes, _extractId podría fallar.
          currentExpression = _extractId(data['expression']) ?? currentExpression;
          currentHair = _extractId(data['hair']) ?? currentHair;
          currentFacialHair = _extractId(data['facialHair']) ?? currentFacialHair;
        });
      }
    } catch (e) {
      _showError('Connection error while loading user avatar.');
    }
  }

  // Función auxiliar para sacar el ID numérico de cualquier URL
  String? _extractId(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final parts = url.split('/');
      
      // Recorremos los segmentos de la URL de atrás hacia adelante
      for (var i = parts.length - 1; i >= 0; i--) {
        final cleanPart = parts[i].replaceAll('.png', '');
        
        // Comprobamos si este segmento es un número válido
        if (int.tryParse(cleanPart) != null) {
          return cleanPart; // ¡Encontrado!
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // GUARDAR EL AVATAR EN LA API
  // ==========================================
  // ==========================================
  // GUARDAR EL AVATAR EN LA API
  // ==========================================
  Future<void> _saveAvatar() async {
    setState(() => isSaving = true);

    final user = Provider.of<UserModel>(context, listen: false);
    final username = user.username;

    try {
      // 💡 CORRECCIÓN: Usamos _extractId para enviar solo el número/nombre al backend, no la URL entera.
      final payload = {
        'body': _extractId(currentBody),
        'eye': _extractId(currentEye),
        'expression': _extractId(currentExpression),
        'hair': _extractId(currentHair), // Ojo: en tu código ponía 'hair_style', revisa si el backend pide 'hair' o 'hair_style'
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeShell()));
        } else {
          Navigator.pop(context); 
        }
      } else {
        debugPrint('Error del backend: ${response.body}');
        _showError('Error saving avatar: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Connection error while saving avatar.');
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
        case 'Body': currentBody = item; break;
        case 'Eyes': currentEye = item; break;
        case 'Expression': currentExpression = item; break;
        case 'Hair': currentHair = item; break;
        case 'Facial Hair': currentFacialHair = item; break;
        case 'Clothing': currentClothing = item; break;
        case 'Accessories': currentAccessories = item; break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ------------------------------------
    // PANTALLA DE CARGA INICIAL
    // ------------------------------------
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isNewUser ? 'Create your Avatar' : 'Edit Avatar'),
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
          title: Text(widget.isNewUser ? 'Create your Avatar' : 'Edit Avatar'),
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
                border: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
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
              tabs: categories.map((cat) => Tab(text: cat)).toList(),
            ),

            // --- ZONA DE SELECCIÓN DE OPCIONES ---
            Expanded(
              child: TabBarView(
                children: categories.map((category) {
                  final items = options[category] ?? [];
                  
                  if (items.isEmpty) {
                    return const Center(child: Text('No options available'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      
                      // Lógica de selección
                      bool isSelected = false;
                      switch (category) {
                        case 'Body': isSelected = currentBody == item; break;
                        case 'Eyes': isSelected = currentEye == item; break;
                        case 'Expression': isSelected = currentExpression == item; break;
                        case 'Hair': isSelected = currentHair == item; break;
                        case 'Facial Hair': isSelected = currentFacialHair == item; break;
                        case 'Clothing': isSelected = currentClothing == item; break;
                        case 'Accessories': isSelected = currentAccessories == item; break; 
                      }

                      return GestureDetector(
                        onTap: () => updateAvatar(category, item),
                        child: Container(
                          padding: const EdgeInsets.all(8), // Un poco de espacio interior
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF355F3F) : Colors.grey.shade300,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          // 💡 CORRECCIÓN: Aquí mostramos la imagen en lugar del texto
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item,
                              fit: BoxFit.contain,
                              //errorBuilder: (context, error, stackTrace) => const Center(
                              //  child: Icon(Icons.broken_image, color: Colors.grey),
                              //),
                              errorBuilder: (context, error, stackTrace) {
                                // Esto imprimirá en tu consola el motivo real del fallo
                                debugPrint('🔴 Error cargando imagen $item: $error'); 
                                return const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            widget.isNewUser ? 'Continue' : 'Save Changes',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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