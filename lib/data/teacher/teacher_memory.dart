part of chem_lab;

// ============================================================
// TEACHER MEMORY — Conversation History + User State
// ============================================================

class TeacherMemory {
  // Conversation history (last 20 messages)
  final List<TeacherMessage> _history = [];
  static const int maxHistory = 20;

  // User state
  String lastChemicalDiscussed = '';
  String lastReactionDiscussed = '';
  int messagesInSession = 0;
  DateTime sessionStart = DateTime.now();
  Set<String> seenTopics = {};

  // Mood detection from recent messages
  String userMood = 'neutral'; // neutral, happy, confused, bored, curious

  void addMessage(String role, String text) {
    _history.add(TeacherMessage(role: role, text: text, timestamp: DateTime.now()));
    if (_history.length > maxHistory) _history.removeAt(0);
    if (role == 'user') messagesInSession++;
  }

  List<TeacherMessage> getHistory() => List.unmodifiable(_history);

  String getLastUserMessage() {
    for (int i = _history.length - 1; i >= 0; i--) {
      if (_history[i].role == 'user') return _history[i].text;
    }
    return '';
  }

  String getLastTeacherMessage() {
    for (int i = _history.length - 1; i >= 0; i--) {
      if (_history[i].role == 'teacher') return _history[i].text;
    }
    return '';
  }

  bool hasDiscussed(String topic) => seenTopics.contains(topic.toLowerCase());
  void markDiscussed(String topic) => seenTopics.add(topic.toLowerCase());

  bool isNewUser() => messagesInSession <= 2;
  bool isRegularUser() => messagesInSession > 10;

  String getSessionGreeting() {
    final minutes = DateTime.now().difference(sessionStart).inMinutes;
    if (minutes < 2) return 'just_started';
    if (minutes < 10) return 'a_while';
    return 'long_time';
  }

  void clear() {
    _history.clear();
    seenTopics.clear();
    messagesInSession = 0;
    sessionStart = DateTime.now();
  }
}

class TeacherMessage {
  final String role; // 'user' or 'teacher'
  final String text;
  final DateTime timestamp;
  TeacherMessage({required this.role, required this.text, required this.timestamp});
}

// Global instance
final TeacherMemory teacherMemory = TeacherMemory();