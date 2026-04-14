import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/plant_service.dart';
import '../models/dades_usr.dart';
import 'plant_result_page.dart';

class PlantCameraScreen extends StatefulWidget {
  const PlantCameraScreen({super.key});

  @override
  State<PlantCameraScreen> createState() => _PlantCameraScreenState();
}

class _PlantCameraScreenState extends State<PlantCameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();

    // Normalment la càmera posterior serà la que vols
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
  }

  Future<void> _takePicture() async {
    if (_controller == null || _initializeControllerFuture == null) return;

    try {
      await _initializeControllerFuture!;
      final image = await _controller!.takePicture();

      if (!mounted) return;
      final user = Provider.of<UserModel>(context, listen: false);
      final result = await PlantService.identifyPlant(
        username: user.username,
        imagePath: image.path,
      );
      debugPrint("Resultat: $result");

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlantResultPage(result: result)),
      );
    } catch (e) {
      debugPrint('Error: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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

                    // Capa fosca lleugera per llegir millor el text
                    Container(color: Colors.black.withValues(alpha: 0.15)),

                    SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          // Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                const Spacer(),
                                Text(
                                  'MeteoGarden',
                                  style: TextStyle(
                                    color: Colors.green.shade400,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(width: 24),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Fotografia la planta',
                            style: TextStyle(color: Colors.white, fontSize: 20),
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
                                  onTap: _takePicture,
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
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white30,
                                        ),
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
