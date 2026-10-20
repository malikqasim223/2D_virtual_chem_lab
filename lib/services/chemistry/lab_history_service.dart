part of chem_lab;

class LabHistoryService {
  static const String _fileName = 'saved_experiments.json';

  static Future<void> saveExperiment(List<EquipItem> equipment, String expName) async {
    final data = {
      'name': expName,
      'date': DateTime.now().toIso8601String(),
      'equipment': equipment.map((e) => {
        'shape': e.shape.toString(),
        'label': e.shape.label,
        'temperature': e.temperature,
        'layers': e.layers.map((l) => {'chemId': l.chemId, 'volume': l.volume}).toList(),
      }).toList(),
    };

    final file = File(_fileName);
    List<dynamic> history = [];
    
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        history = jsonDecode(content) as List<dynamic>;
      } catch (e) {
        history = [];
      }
    }
    
    history.insert(0, data);
    await file.writeAsString(jsonEncode(history));
  }

  static Future<List<dynamic>> loadHistory() async {
    final file = File(_fileName);
    if (!await file.exists()) return [];
    
    try {
      final content = await file.readAsString();
      return jsonDecode(content) as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearHistory() async {
    final file = File(_fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }
}