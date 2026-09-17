import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Lab3DScreen extends StatefulWidget {
  const Lab3DScreen({super.key});
  @override
  State<Lab3DScreen> createState() => _Lab3DScreenState();
}

class _Lab3DScreenState extends State<Lab3DScreen> {
  String selectedModel = 'assets/models/chemistry_glassware.glb';

  final List<Map<String, String>> models = [
    {
      'name': 'Chemistry Glassware',
      'path': 'assets/models/chemistry_glassware.glb',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10161D),
        elevation: 0,
        title: const Text(
          '3D Chemistry Lab',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE4E9EE),
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF9FB6CC)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          // Left panel
          Container(
            width: 230,
            decoration: const BoxDecoration(
              color: Color(0xFF161D26),
              border: Border(
                right: BorderSide(color: Color(0xFF2A3542)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: const [
                      Icon(Icons.view_in_ar, size: 14, color: Color(0xFF9FB6CC)),
                      SizedBox(width: 10),
                      Text(
                        'MODELS',
                        style: TextStyle(
                          color: Color(0xFFE4E9EE),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: const Color(0xFF2A3542)),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: models.length,
                    itemBuilder: (_, i) {
                      final m = models[i];
                      final active = selectedModel == m['path'];
                      return GestureDetector(
                        onTap: () => setState(() => selectedModel = m['path']!),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF232936)
                                : const Color(0xFF1F2933),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: active
                                  ? const Color(0xFF6E8FA8)
                                  : const Color(0xFF2A3542),
                              width: active ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.science_outlined,
                                size: 16,
                                color: active
                                    ? const Color(0xFF9FB6CC)
                                    : const Color(0xFF6B7885),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  m['name']!,
                                  style: TextStyle(
                                    color: active
                                        ? const Color(0xFFE4E9EE)
                                        : const Color(0xFFA2AFBD),
                                    fontSize: 11,
                                    fontWeight: active
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(height: 1, color: const Color(0xFF2A3542)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.info_outline,
                              size: 11, color: Color(0xFF6B7885)),
                          SizedBox(width: 6),
                          Text(
                            'Controls',
                            style: TextStyle(
                              color: Color(0xFF6B7885),
                              fontSize: 9,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _ctrl('Drag', 'Rotate model'),
                      _ctrl('Scroll', 'Zoom in/out'),
                      _ctrl('Right-drag', 'Pan view'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Right panel - 3D viewer
          Expanded(
            child: Container(
              color: const Color(0xFF0B0F14),
              child: ModelViewer(
                src: selectedModel,
                alt: 'Chemistry equipment',
                ar: false,
                autoRotate: true,
                cameraControls: true,
                backgroundColor: const Color(0xFF0B0F14),
                disableZoom: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ctrl(String key, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2933),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: const Color(0xFF2A3542)),
            ),
            child: Text(
              key,
              style: const TextStyle(
                color: Color(0xFF9FB6CC),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(color: Color(0xFF6B7885), fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}
