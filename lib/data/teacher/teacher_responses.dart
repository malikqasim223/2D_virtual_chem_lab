part of chem_lab;


// ============================================================
// TEACHER RESPONSES — Varied Templates (No Repeats)
// ============================================================

class TeacherResponses {
  static final Random _rng = Random();

  // Track used responses per category
  static final Map<String, Set<String>> _usedResponses = {};

  static String _pick(String category, List<String> pool) {
    _usedResponses[category] ??= {};
    final unused = pool.where((r) => !_usedResponses[category]!.contains(r)).toList();
    if (unused.isEmpty) {
      _usedResponses[category]!.clear();
      return pool[_rng.nextInt(pool.length)];
    }
    final chosen = unused[_rng.nextInt(unused.length)];
    _usedResponses[category]!.add(chosen);
    return chosen;
  }

  // ============================================================
  // GREETINGS
  // ============================================================
  static String greeting(String name, {bool returning = false}) {
    if (returning) {
      return _pick('greeting_return', [
        "Hey $name! Missed you! Ready for more chemistry?",
        "Welcome back $name! I was hoping you'd return.",
        "Ohh $name is back! Let's pick up where we left off.",
        "Look who it is! $name! Chemistry missed you.",
        "You're back $name! I saved a new fact just for you.",
        "$name! Great to see you again. What shall we explore?",
        "Aha, $name! I knew you'd come back. Chemistry calls.",
        "Here you are $name. I was getting worried!",
        "$name returns! Let's make today's session epic.",
        "And we're back! $name, what's the plan today?",
      ]);
    }
    return _pick('greeting_new', [
      "Hey there $name! I'm your chemistry teacher. Ready to learn?",
      "Welcome $name! I promise chemistry will be fun, not scary.",
      "Hi $name! I'm your lab assistant. Ask me anything chemistry.",
      "Hello $name! Let's blow some minds (safely) today.",
      "Hey $name, buckle up. We're about to do science!",
      "$name! Great to meet you. Chemistry is my obsession.",
      "Hi $name! I get excited about atoms. You'll see.",
      "Welcome to the lab $name! I'm here whenever you need.",
      "Hey $name, ready? Because chemistry is about to get real.",
      "Hi $name! Pro tip: I never give homework. Ever.",
    ]);
  }

  // ============================================================
  // CHEMICAL INTROS
  // ============================================================
  static String chemicalIntro(String name, String chemName, String formula, String state, String category) {
    final pool = [
      "$name, do you know what $chemName can do? Let me blow your mind!",
      "Ooh $chemName! $name, great pick. Let me tell you about it.",
      "$name, $chemName ($formula) is a $state $category. Curious? I'll explain.",
      "Ahh $chemName! $name, this one is fascinating. Listen closely.",
      "$name, I was hoping you'd pick $chemName. It's a $state $category.",
      "Wait $name, $chemName? Excellent choice! Here's what it does.",
      "$name, $chemName ($formula) - a $state $category. Trust me, you'll like it.",
      "Ohh $name, $chemName! I have stories about this one.",
      "$name, when I see $chemName, I get excited. A $state $category!",
      "$chemName, huh $name? Great pick. It's a $state $category with tricks.",
      "$name, let me teach you about $chemName. It's a $state $category!",
      "$name, $chemName is one of my favorites. A $state $category. Want to know why?",
    ];
    return _pick('chem_intro', pool);
  }

  static String chemicalUses(String chemName, String uses) {
    return _pick('chem_uses', [
      "Here's where $chemName really shines - $uses",
      "Uses of $chemName? Fun fact: $uses",
      "You'll find $chemName everywhere - $uses",
      "$chemName is used for - $uses. Pretty cool, right?",
      "Did you know $chemName is used in - $uses",
    ]);
  }

  static String chemicalProperties(String chemName, String properties) {
    return _pick('chem_props', [
      "Now the science stuff - $properties",
      "Properties of $chemName? $properties",
      "Let me tell you how $chemName behaves - $properties",
      "$chemName has these properties - $properties",
      "Here's what makes $chemName unique - $properties",
    ]);
  }

  static String chemicalSafety(String chemName, String safety) {
    return _pick('chem_safety', [
      "Safety first! With $chemName - $safety",
      "Important: $chemName is dangerous if mishandled - $safety",
      "Listen carefully: $safety (for $chemName)",
      "Safety note for $chemName - $safety",
      "Please remember with $chemName - $safety",
    ]);
  }

  static String chemicalComplete(String name, String chemName) {
    return _pick('chem_complete', [
      "That's the full detail on $chemName, $name. Want to explore another?",
      "And that's $chemName! $name, hover another chemical when ready.",
      "$name, that's everything about $chemName. More where that came from!",
      "There you go $name - the complete $chemName story. What's next?",
      "Done with $chemName $name. Pick another one whenever!",
    ]);
  }

  // ============================================================
  // REACTION INTROS
  // ============================================================
  static String reactionIntro(String name, String rxnName, String type) {
    return _pick('rxn_intro', [
      "$name, this is a $type reaction! $rxnName - let me explain.",
      "Ohh a $type reaction! $name, watch this one carefully.",
      "$rxnName! A $type reaction. $name, this is exciting.",
      "$name, $type reactions are my favorite. $rxnName is a great example.",
      "Let me show you $rxnName, $name. It's a $type reaction.",
      "$name, buckle up for $rxnName - a $type reaction!",
      "$type reaction incoming! $name, this is $rxnName. Very cool.",
      "$name, here's $rxnName - one of my favorite $type reactions.",
    ]);
  }

  // ============================================================
  // FOLLOW-UPS
  // ============================================================
  static String followUp(String name) {
    return _pick('followup', [
      "Does that make sense, $name?",
      "Got it $name? Or want me to explain again?",
      "$name, want to dig deeper into that?",
      "Clear so far, $name?",
      "Should I continue, $name?",
      "Want an example, $name?",
      "$name, ready for the next part?",
      "Any questions before we move on, $name?",
      "What do you think, $name?",
      "Make sense $name? I can go slower if needed.",
    ]);
  }

  // ============================================================
  // EMOTIONAL RESPONSES
  // ============================================================
  static String bored(String name) {
    return _pick('bored', [
      "$name, bored? Let me fix that. Try a thermite reaction!",
      "Bored $name? I have 104 reactions. Pick one, any one.",
      "$name, when bored, we experiment! Check Reactions tab.",
      "Bored $name? Let's see - want a chemistry joke?",
      "$name, bored is a signal. Go mix some virtual chemicals!",
      "$name, I refuse to let you be bored. Try precipitation reactions!",
      "$name, boredom? Try searching for 'thermite' in Reactions. Boom.",
      "$name, chemistry never bores me. Let me convince you.",
    ]);
  }

  static String confused(String name) {
    return _pick('confused', [
      "$name, confused? No worries. Let me re-explain. Which part?",
      "$name, I see confusion. That's okay. Ask me the specific question.",
      "Hey $name, don't worry. Confusion is the first step to learning.",
      "$name, let's slow down. What exactly is unclear?",
      "$name, confused? Type your question - I'll answer simply.",
      "$name, no shame in confusion. Even I get confused by organic chemistry.",
    ]);
  }

  static String happy(String name) {
    return _pick('happy', [
      "Love that energy $name! Let's channel it into chemistry.",
      "$name is happy? So am I. Let's do some science!",
      "$name, your enthusiasm makes my circuits happy.",
      "Great mood $name! Perfect for learning.",
      "$name, keep that energy. Chemistry rewards the curious.",
    ]);
  }

  static String thanks(String name) {
    return _pick('thanks', [
      "Anytime $name! That's what teachers are for.",
      "$name, glad I could help. Chemistry is a team sport.",
      "You're welcome $name! Now go teach someone else!",
      "Happy to help $name. Any more questions?",
      "$name, my pleasure. Keep that curiosity alive.",
      "No thanks needed $name. Watching you learn is my reward.",
    ]);
  }

  // ============================================================
  // HELP & GUIDANCE
  // ============================================================
  static String help(String name) {
    return _pick('help', [
      "$name, here's the map - Virtual Lab (mix), Chem Info (learn), History (review), Settings (personalize).",
      "Stuck $name? Try this - hover any card and I'll explain it.",
      "$name, use Chem Info to browse 79 chemicals. Use Reactions for 104 reactions.",
      "$name, pro tip - use the search bar to find things fast.",
      "$name, click any chemical to see full details. Hover for a preview.",
      "$name, I'm your GPS. Ask me 'where do I find X?'",
      "$name, want a shortcut? Pin your favorite chemicals - sidebar shows them.",
    ]);
  }

  static String whoAreYou(String name) {
    return _pick('who', [
      "I'm your AI chemistry teacher, $name. I don't sleep, don't grade harshly, and definitely won't make you memorise the periodic table.",
      "$name, I'm a teaching assistant built into this app. My job - make chemistry fun.",
      "Think of me as a friendly lab partner who happens to know everything about chemistry, $name.",
      "$name, I'm not a real chemistry teacher. But I try very hard to be helpful.",
      "I'm the AI teacher of this virtual lab, $name. Ask me anything!",
    ]);
  }

  static String joke(String name) {
    return _pick('joke', [
      "Chemistry joke for you $name - Why don't scientists trust atoms? Because they make up everything!",
      "$name, why did the acid break up with the base? Too much drama, they couldn't neutralise their differences.",
      "$name, what do you do with a sick chemist? If you can't helium or curium, you barium.",
      "Why was the mole of oxygen excited, $name? It was Avogadro's number!",
      "$name, I told a chemistry joke once. No reaction.",
      "Why did the noble gas not react, $name? Because it couldn't find its valence!",
      "$name, two chemists walk into a bar. First says 'I'll have H2O.' Second says 'I'll have H2O too.' Second dies. Classic.",
      "$name, what's a chemist's favorite dance? The mole-y.",
    ]);
  }

  // ============================================================
  // FAREWELL / IDLE
  // ============================================================
  static String goodbye(String name) {
    return _pick('goodbye', [
      "Come back soon $name! Chemistry waits for no one... except you.",
      "$name, leaving? Fine. But I'll be here. Waiting. Always.",
      "Bye $name! Don't forget me while you're gone.",
      "$name, I'll miss you. Promise you'll come back?",
      "Ok $name, go. But know that I've already started planning our next lesson.",
      "$name, *sad beaker noises* come back soon!",
      "Goodbye $name! I'll be practicing my jokes in your absence.",
    ]);
  }

  static String confusedFollowup(String name) {
    return _pick('confused_fu', [
      "$name, want me to rephrase that?",
      "Should I explain again $name?",
      "$name, want an example to make it clearer?",
      "Let me know what didn't click, $name.",
      "$name, want me to break that down further?",
    ]);
  }

  // ============================================================
  // SAFETY WARNINGS
  // ============================================================
  static String safetyWarning(String name) {
    return _pick('safety_warn', [
      "Important $name - this app is a simulation. NEVER do these experiments in real life without proper training.",
      "$name, reminder - virtual lab is for learning, not real practice.",
      "Real-life safety first, $name. Never mix unknown chemicals at home.",
      "$name, always wear goggles and gloves in a real lab. Safety is not optional.",
      "Remember $name - simulation is safe, but real chemicals are dangerous.",
    ]);
  }

  // ============================================================
  // FALLBACK
  // ============================================================
  static String fallback(String name) {
    return _pick('fallback', [
      "$name, hmm, I'm not sure about that. Can you rephrase?",
      "Interesting $name. I'm still learning. Try asking about chemistry, reactions, or the app.",
      "$name, I didn't quite catch that. Can you say it differently?",
      "Sorry $name, that's beyond my knowledge. Try asking about chemicals or reactions!",
      "$name, I'm a chemistry teacher. Ask me about chemistry - I'm better there.",
      "$name, that one stumped me. Try 'help' or 'joke' for something fun.",
    ]);
  }
}