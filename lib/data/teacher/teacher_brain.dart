part of chem_lab;

// ============================================================
// TEACHER BRAIN — Intent Detection + Response Orchestration
// ============================================================

class TeacherBrain {
  static String respond(String userMessage) {
    final name = userName.value == 'Student' ? 'friend' : userName.value;
    final lower = userMessage.toLowerCase().trim();

    teacherMemory.addMessage('user', userMessage);

    // Greeting
    if (lower == 'hi' || lower == 'hello' || lower == 'hey' || lower == 'salam' ||
        lower.startsWith('hi ') || lower.startsWith('hello ') || lower.startsWith('hey ') ||
        lower.contains('good morning') || lower.contains('good evening') || lower.contains('assalam')) {
      teacherMemory.userMood = 'happy';
      final returning = teacherMemory.messagesInSession > 2;
      return _reply(TeacherResponses.greeting(name, returning: returning));
    }

    // Confused
    if (lower.contains('confused') || lower.contains("don't understand") ||
        lower.contains('not clear') || lower.contains('samajh nahi') || lower.contains('mushkil')) {
      teacherMemory.userMood = 'confused';
      return _reply(TeacherResponses.confused(name));
    }

    // Bored
    if (lower.contains('bored') || lower.contains('boring') || lower.contains('boor')) {
      teacherMemory.userMood = 'bored';
      return _reply(TeacherResponses.bored(name));
    }

    // Thanks
    if (lower.contains('thank') || lower.contains('shukriya')) {
      return _reply(TeacherResponses.thanks(name));
    }

    // Joke
    if (lower.contains('joke') || lower.contains('funny') || lower.contains('laugh') || lower.contains('hasa')) {
      return _reply(TeacherResponses.joke(name));
    }

    // Who are you
    if (lower.contains('who are you') || lower.contains('what are you') ||
        lower.contains('tum kon') || lower.contains('aap kon')) {
      return _reply(TeacherResponses.whoAreYou(name));
    }

    // Help / Navigation
    if (lower.contains('help') || lower.contains('how') || lower.contains('where') ||
        lower.contains('guide') || lower.contains('madad')) {
      return _reply(TeacherResponses.help(name));
    }

    // Safety
    if (lower.contains('safe') || lower.contains('safety') || lower.contains('danger') ||
        lower.contains('hazard')) {
      return _reply(TeacherResponses.safetyWarning(name));
    }

    // Goodbye
    if (lower.contains('bye') || lower.contains('goodbye') || lower.contains('khuda hafiz')) {
      return _reply(TeacherResponses.goodbye(name));
    }

    // Chemical
    if (lower.contains('chemical') || lower.contains('acid') || lower.contains('base') ||
        lower.contains('salt') || lower.contains('element') || lower.contains('compound')) {
      return _reply(TeacherResponses.help(name));
    }

    // Reaction
    if (lower.contains('react') || lower.contains('reaction') || lower.contains('equation') ||
        lower.contains('mix')) {
      return _reply(TeacherResponses.help(name));
    }

    // Fallback
    return _reply(TeacherResponses.fallback(name));
  }

  static String _reply(String text) {
    teacherMemory.addMessage('teacher', text);
    return text;
  }
}