import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CameraDescription> _cameras = [];
  bool _cameraAvailable = false;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      final cams = await availableCameras();
      if (!mounted) return;
      setState(() {
        _cameras = cams;
        _cameraAvailable = cams.isNotEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cameraAvailable = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.science,
                    size: 80, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Virtual Chemistry Lab',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Learn chemistry the safe way',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 40),
              _HomeButton(
                icon: Icons.science_outlined,
                label: 'Start Experiment (2D)',
                onTap: () => context.go('/lab'),
              ),
              const SizedBox(height: 14),
              _HomeButton(
                icon: Icons.view_in_ar,
                label: '3D Lab Demo',
                onTap: () => context.go('/lab3d'),
              ),
              const SizedBox(height: 14),
              _HomeButton(
                icon: Icons.camera_alt_outlined,
                label: _cameraAvailable
                    ? 'Camera Ready (${_cameras.length})'
                    : 'No Camera Detected',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _cameraAvailable
                            ? '${_cameras.length} camera(s) found'
                            : 'Please connect a webcam',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              _HomeButton(
                icon: Icons.info_outline,
                label: 'About',
                onTap: () => _showAbout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Virtual Chemistry Lab v1.0.0\n\n'
          'An interactive virtual chemistry laboratory. '
          'Includes 2D interactive lab and 3D model viewer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1976D2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
