import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/plant_service.dart';
import '../models/dades_usr.dart';
import 'plant_result_page.dart';
import 'package:meteo_garden/models/plantes_desbl.dart';

class PlantCameraScreen extends StatefulWidget {
  const PlantCameraScreen({super.key});

  @override
  State<PlantCameraScreen> createState() => _PlantCameraScreenState();
}

class _PlantCameraScreenState extends State<PlantCameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  bool _isProcessing = false;
  String? _errorMessage;

  String _selectedPlantType = 'leaf';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No s’ha trobat cap càmera disponible.';
        });
        return;
      }

      final backCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      setState(() {});
    } catch (_) {
      setState(() {
        _errorMessage = 'No s’ha pogut inicialitzar la càmera.';
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || _initializeControllerFuture == null) return;

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      await _initializeControllerFuture!;
      final image = await _controller!.takePicture();

      if (!mounted) return;

      final user = Provider.of<UserModel>(context, listen: false);

      final result = await PlantService.identifyPlant(
        username: user.username,
        imagePath: image.path,
        organ: _selectedPlantType,
      );
      debugPrint('IMAGE URL RESULT: ${result.image.url}');

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlantResultPage(result: result),
        ),
      );

      if (!mounted) return;

      await context.read<PlantProvider>().loadPlants(user);

    } on PlantIdentificationException catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.message;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'S’ha produït un error inesperat.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('S’ha produït un error inesperat.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildTypeButton({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedPlantType == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPlantType = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.shade600 : Colors.white24,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white54,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: controller == null || _initializeControllerFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(controller),

                    Container(color: Colors.black.withValues(alpha: 0.15)),

                    SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          // Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Center(
                              child: Text(
                                'MeteoGarden',
                                style: TextStyle(
                                  color: Colors.green.shade400,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Fotografia la planta',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                _buildTypeButton(
                                  label: 'Arbre',
                                  value: 'leaf',
                                  icon: Icons.park,
                                ),
                                const SizedBox(width: 12),
                                _buildTypeButton(
                                  label: 'Flor',
                                  value: 'flower',
                                  icon: Icons.local_florist,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),
                          Text(
                            _selectedPlantType == 'leaf'
                                ? 'Mode arbre seleccionat'
                                : 'Mode flor seleccionat',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (_isProcessing)
                            const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Text(
                                'Identificant planta...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),

                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.redAccent),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                          const Spacer(),

                          // Marc central
                          Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Centra la planta dins el marc',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),

                          const Spacer(),

                          // Controls inferiors
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.photo,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _isProcessing ? null : _takePicture,
                                  child: Container(
                                    width: 78,
                                    height: 78,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 58,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _isProcessing ? Colors.white30 : Colors.white,
                                        ),
                                        child: _isProcessing
                                            ? const Padding(
                                          padding: EdgeInsets.all(14),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                          ),
                                        )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.cameraswitch,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
