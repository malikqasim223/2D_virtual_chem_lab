part of chem_lab;

// ============================================================
// REACTION DEEP DIVE — Real-world & educational knowledge
// Keys match ReactionInfo.name AND ReactionInfo.type
// ============================================================
const Map<String, Map<String, String>> reactionDeepDive = {

  // ═══════════════════════════════════════════════════
  // BY NAME (specific reactions)
  // ═══════════════════════════════════════════════════
  'Thermite Reaction': {
    'mechanism': 'Aluminum is more reactive than iron. It grabs oxygen from iron oxide, releasing enormous heat and molten iron.',
    'realWorld': 'Thermite welds railroad tracks and is used in demolition — it burns through steel like butter.',
    'whenMixed': 'Burns at 2500 degrees Celsius. Water does NOT stop it. Never mix with water.',
    'safety': 'Never attempt at home. Blindingly bright, cannot be extinguished. Professionals only.',
  },
  'Neutralization': {
    'mechanism': 'The acid gives H+ ions and the base gives OH- ions. They join to form water. The leftover ions pair up as a salt.',
    'realWorld': 'This is exactly how antacids like Tums or Eno work — they neutralize stomach acid and relieve heartburn.',
    'whenMixed': 'If you add more acid, the solution turns acidic again. Add zinc and you get hydrogen gas.',
    'safety': 'Always add acid to water, never the reverse. Strong acids and bases cause burns. Wear goggles.',
  },
  'Acid-Base Neutralization': {
    'mechanism': 'H+ from acid and OH- from base combine to form water, leaving a salt behind.',
    'realWorld': 'Used in every antacid tablet, in wastewater treatment, and in soil pH correction for farming.',
    'whenMixed': 'With excess acid, the solution stays acidic. Add more base and it turns basic. Perfect balance gives pH 7.',
    'safety': 'Strong acids and bases burn skin. Add slowly and stir. Never mix concentrated solutions directly.',
  },
  'Copper Hydroxide': {
    'mechanism': 'OH- ions from the base displace sulfate ions, forming insoluble copper hydroxide — a blue gel that settles out.',
    'realWorld': 'Copper hydroxide is used as a fungicide on grapes and potatoes, protecting crops from fungal rot.',
    'whenMixed': 'Excess ammonia dissolves the precipitate into a deep blue solution. Acid dissolves it back to clear.',
    'safety': 'Copper salts are toxic if swallowed. Avoid skin contact. Do not pour down the drain — harms fish.',
  },
  'Precipitation (AgCl)': {
    'mechanism': 'Silver ions and chloride ions meet and instantly lock together as insoluble silver chloride — a white curdy solid.',
    'realWorld': 'This exact reaction is used to test for chloride in water and in classical black-and-white photography.',
    'whenMixed': 'Adding ammonia dissolves the precipitate. Sunlight slowly turns it grey-purple as silver metal forms.',
    'safety': 'Silver nitrate stains skin black for days. Wear gloves. Keep away from eyes and clothing.',
  },
  'Ag2SO4 Precipitation': {
    'mechanism': 'Silver ions meet sulfate ions, forming slightly soluble silver sulfate — a white precipitate at high concentration.',
    'realWorld': 'Used in silver plating and in analytical chemistry to detect sulfate ions in solution.',
    'whenMixed': 'Adding more water often dissolves it. Concentrated solutions favor precipitation.',
    'safety': 'Silver salts are light-sensitive and stain skin. Handle with gloves in dim light.',
  },
  'Brown Precipitate (Ag2O)': {
    'mechanism': 'Hydroxide ions react with silver ions to form silver oxide — a dark brown solid — instead of silver hydroxide.',
    'realWorld': 'This is a classic test for silver ions in solution and is used in mirror-making chemistry.',
    'whenMixed': 'Adding ammonia dissolves it, forming the Tollens reagent used to detect aldehydes.',
    'safety': 'Silver compounds are toxic and light-sensitive. Use gloves, keep away from light.',
  },
  'Complex': {
    'mechanism': 'Ligands (like ammonia) donate electron pairs to a central metal ion, forming a coordinated complex.',
    'realWorld': 'Hemoglobin, chlorophyll, and vitamin B12 are all metal complexes. EDTA in shampoo softens hard water.',
    'whenMixed': 'Adding excess ligand dissolves precipitates into colored solutions. Adding acid breaks the complex apart.',
    'safety': 'Some metal complexes are toxic. Cyanide complexes are lethal — handle with extreme care.',
  },
  'HCl Gas Evolution': {
    'mechanism': 'A strong acid displaces chloride from a salt, releasing hydrogen chloride gas — sharp, choking fumes.',
    'realWorld': 'HCl gas is used in industrial cleaning and pH control, but in the lab it is dangerous.',
    'whenMixed': 'Water absorbs HCl gas to form hydrochloric acid. Ammonia forms white fumes of ammonium chloride.',
    'safety': 'Extremely toxic fumes. Do this only in a fume hood. Gas irritates lungs instantly.',
  },
  'No Reaction': {
    'mechanism': 'The chemicals are chemically incompatible at these conditions — no bonds break, no new bonds form.',
    'realWorld': 'Most mixtures in daily life are stable — salt and sugar sit fine together, water and oil stay separate.',
    'whenMixed': 'Changing temperature, adding a catalyst, or a different reagent may trigger reaction. Otherwise nothing.',
    'safety': 'No danger, but still avoid mixing unknown chemicals — surprise reactions do happen.',
  },
  'Indicator - Pink': {
    'mechanism': 'Phenolphthalein is colorless in acid and neutral, but turns pink in base — a molecular color switch.',
    'realWorld': 'Universal indicator paper uses this exact trick — pink for base, red for acid, green for neutral.',
    'whenMixed': 'Adding acid turns it colorless again. Adding more base deepens the pink to magenta.',
    'safety': 'Phenolphthalein is safe but do not drink. Wash spills with water.',
  },
  'Indicator - Colorless': {
    'mechanism': 'In acidic or neutral solution, the indicator molecule stays in its colorless form.',
    'realWorld': 'Used to confirm acids in water samples and in titration endpoints.',
    'whenMixed': 'Adding base turns it pink. This is the endpoint of an acid-base titration.',
    'safety': 'Safe to handle but not for ingestion.',
  },
  'May form Ag2SO4 (Condition-Dependent)': {
    'mechanism': 'Whether silver sulfate precipitates depends on concentration and temperature.',
    'realWorld': 'Analytical labs carefully control concentration to detect silver or sulfate.',
    'whenMixed': 'High concentration gives white precipitate. Dilute solutions stay clear.',
    'safety': 'Silver salts stain skin and clothing. Handle in dim light.',
  },
  'Condition Not Met': {
    'mechanism': 'The reaction needs a trigger — heat, acid, or another condition — that is not yet present.',
    'realWorld': 'Labs carefully control temperature and pH so reactions happen exactly when wanted.',
    'whenMixed': 'Add the missing condition and the reaction proceeds as expected.',
    'safety': 'Never force a reaction without understanding what it will do.',
  },

  // ═══════════════════════════════════════════════════
  // BY TYPE (broader categories)
  // ═══════════════════════════════════════════════════
  'Precipitation': {
    'mechanism': 'Two soluble salts swap ions. One pairing is insoluble and falls out as a solid — that solid is the precipitate.',
    'realWorld': 'Water treatment plants use precipitation to remove heavy metal pollution from drinking water.',
    'whenMixed': 'Adding ammonia may dissolve the precipitate. Adding acid often reverses it.',
    'safety': 'Many precipitates are toxic heavy metal salts. Never taste or inhale. Wear gloves.',
  },
  'Double Displacement': {
    'mechanism': 'Two compounds swap partners. Often produces a precipitate, a gas, or water.',
    'realWorld': 'Soap making is double displacement — fat plus lye gives soap plus glycerin.',
    'whenMixed': 'If all products are soluble, nothing visible happens — but chemistry still occurs.',
    'safety': 'Products may be corrosive or toxic. Handle byproducts carefully.',
  },
  'Acid-Base Displacement': {
    'mechanism': 'An acid protonates a base, changing its structure and often releasing a gas or forming a salt.',
    'realWorld': 'Stomach acid breaks down food through this type of reaction every time you eat.',
    'whenMixed': 'Adding excess acid pushes the reaction further. Adding base reverses it partially.',
    'safety': 'Acids burn — especially strong ones. Always add acid to water, never water to acid.',
  },
  'Single Displacement': {
    'mechanism': 'A more reactive element pushes out a less reactive one from its compound. Reactivity series decides who wins.',
    'realWorld': 'Silver plating, tinning of cans, and chroming of car parts — all single displacement.',
    'whenMixed': 'If the metal you add is less reactive, nothing happens. Cu + ZnSO4: no reaction.',
    'safety': 'May generate heat and flammable hydrogen. Keep away from flames.',
  },
  'Redox': {
    'mechanism': 'One species loses electrons (oxidation) while another gains electrons (reduction). Both always happen together.',
    'realWorld': 'Rusting, respiration, batteries, and photosynthesis are all redox reactions.',
    'whenMixed': 'A strong oxidizing agent will oxidize many things — even water. Dangerous if uncontrolled.',
    'safety': 'Strong oxidizers can cause fires or explosions. Store away from organic materials.',
  },
  'Metal + Water': {
    'mechanism': 'Very reactive metals like sodium or potassium snatch OH from water, releasing hydrogen gas and heat.',
    'realWorld': 'Alkali metals stored under oil because even air moisture triggers reaction. Sodium water is a classic demo.',
    'whenMixed': 'Burns with a yellow flame, may explode. Lithium is calmer, potassium is violent, cesium explodes.',
    'safety': 'NEVER touch reactive metals with wet hands. Store under oil. Keep a fire extinguisher nearby.',
  },
  'Metal + Acid': {
    'mechanism': 'The metal gives electrons to H+ ions from the acid, releasing hydrogen gas and forming a salt.',
    'realWorld': 'Pickling of steel uses this to remove rust and scale. Lead-acid batteries use it to store energy.',
    'whenMixed': 'Metals below hydrogen in the series (Cu, Ag, Au) do NOT react with dilute acid.',
    'safety': 'Hydrogen plus air is explosive. Do this in a ventilated area, away from flames.',
  },
  'Catalytic Decomposition': {
    'mechanism': 'A catalyst lowers the energy needed to break a molecule apart, without being consumed.',
    'realWorld': 'Catalytic converters in cars break down toxic exhaust gases using platinum and rhodium.',
    'whenMixed': 'More catalyst speeds it up to a point. After that, no change.',
    'safety': 'Some catalysts (like manganese dioxide) are fine; others (like platinum) are expensive — handle carefully.',
  },
  'Gas Evolution': {
    'mechanism': 'A reaction produces a gas as one of the products — bubbles rise and escape.',
    'realWorld': 'Baking bread, safety airbags, and fire extinguishers all rely on controlled gas evolution.',
    'whenMixed': 'The CO2 from acid-carbonate reactions is heavier than air. It can suffocate in closed spaces.',
    'safety': 'Test with a lit match — CO2 puts it out. Never trap gases in sealed bottles — they burst.',
  },
  'Acid-Carbonate': {
    'mechanism': 'Acid donates H+ to the carbonate, releasing carbon dioxide gas and forming a salt plus water.',
    'realWorld': 'Baking soda + vinegar volcano. In the kitchen, it makes cookies rise.',
    'whenMixed': 'Acid rain slowly dissolves limestone and marble — old monuments lose detail over decades.',
    'safety': 'CO2 is heavier than air. In a closed room, it can suffocate.',
  },
  'Complex Formation': {
    'mechanism': 'Ligands attach to a central metal ion, forming a larger, often colored complex.',
    'realWorld': 'EDTA in shampoo binds calcium to soften water. Chlorophyll is a magnesium complex.',
    'whenMixed': 'Excess ligand deepens the color. Adding acid or a competing ligand breaks it apart.',
    'safety': 'Some complexes are toxic (cyanide complexes especially). Handle with care.',
  },
  'Equilibrium': {
    'mechanism': 'Forward and reverse reactions occur at the same rate. Concentrations stop changing, but nothing stops moving.',
    'realWorld': 'Carbonated drinks, blood pH, and the Haber process for making ammonia all rely on equilibrium.',
    'whenMixed': 'Adding product shifts the equilibrium back. Removing product pushes it forward.',
    'safety': 'Equilibrium reactions are usually safe, but high-pressure systems can explode.',
  },
  'Oxidation': {
    'mechanism': 'The metal loses electrons to oxygen, forming a metal oxide. Water acts as a catalyst.',
    'realWorld': 'Rusting costs industry billions. Bridges, cars, ships rust without protection.',
    'whenMixed': 'Salt accelerates rusting — this is why cars rust faster near the sea.',
    'safety': 'Fine iron dust can self-ignite. Iron oxide itself is safe to touch.',
  },
  'Decomposition': {
    'mechanism': 'One compound splits into two or more simpler substances. Energy drives the split.',
    'realWorld': 'Hydrogen peroxide breaks into water and oxygen — that is why old bottles puff open.',
    'whenMixed': 'Adding a catalyst (like MnO2) speeds it up dramatically — elephant toothpaste demo.',
    'safety': 'Rapid gas release can burst sealed containers. Always open slowly.',
  },
  'Amphoteric': {
    'mechanism': 'The substance can act as both an acid and a base — like aluminum hydroxide — depending on what it meets.',
    'realWorld': 'Amphoteric oxides in soil buffer pH, helping plants grow. Antacids use aluminum hydroxide.',
    'whenMixed': 'In acid, it acts as a base. In base, it acts as an acid. In water — depends on pH.',
    'safety': 'Aluminum compounds are usually safe but excessive aluminum is linked to health issues.',
  },
  'Thermite': {
    'mechanism': 'Aluminum grabs oxygen from a metal oxide, releasing so much heat it becomes molten metal.',
    'realWorld': 'Railroad welding, underwater welding, emergency steel cutting — all thermite.',
    'whenMixed': 'Burns at 2500°C. Cannot be extinguished by water — water makes it worse.',
    'safety': 'NEVER attempt without professional training. Blinding light, extreme heat.',
  },
  'Explosive': {
    'mechanism': 'A rapid reaction releases gas and heat so fast it creates a shockwave — that is the explosion.',
    'realWorld': 'Fireworks, mining, demolition — all use controlled explosions.',
    'whenMixed': 'Controlled by temperature, pressure, and confinement. Uncontrolled = disaster.',
    'safety': 'NEVER mix these chemicals at home. Even small amounts can kill.',
  },
  'Indicator': {
    'mechanism': 'A dye changes color based on pH — it is a molecular pH sensor.',
    'realWorld': 'Litmus paper, universal indicator, and red cabbage juice — all natural pH indicators.',
    'whenMixed': 'Color changes visibly at specific pH values — very useful for testing.',
    'safety': 'Safe to handle, but do not drink. Wash spills.',
  },
  'Haloform Reaction': {
    'mechanism': 'A methyl ketone reacts with halogen in base, forming a haloform (like chloroform) and a carboxylate.',
    'realWorld': 'Used in medical tests to detect acetone in urine (diabetes). Also makes chloroform.',
    'whenMixed': 'Yields a pale yellow precipitate with iodine — a sign of a positive test.',
    'safety': 'Chloroform is a carcinogen and anesthetic. Work in a fume hood.',
  },
  'Electrophilic Substitution': {
    'mechanism': 'An electrophile replaces an H atom on an aromatic ring — like benzene to benzoic acid.',
    'realWorld': 'How aspirin, dyes, and explosives are synthesized industrially.',
    'whenMixed': 'The position substituted depends on existing groups on the ring.',
    'safety': 'Many reagents are hazardous — strong acids, benzene (carcinogen), halogens (toxic).',
  },
  'Dehydration': {
    'mechanism': 'A compound loses water (H2O). Often driven by heat or a dehydrating agent.',
    'realWorld': 'Concentrated sulfuric acid dehydrates sugar into black carbon — a classic demo.',
    'whenMixed': 'Strong heat yields more dehydration. Cooling reverses some.',
    'safety': 'Sulfuric acid dehydrates skin too — burns are severe. Handle with extreme care.',
  },
  'Hydrolysis': {
    'mechanism': 'Water breaks a bond in a molecule. Often catalyzed by acid or base.',
    'realWorld': 'Digestion uses hydrolysis to break down proteins, fats, and carbs into usable pieces.',
    'whenMixed': 'Acid or base accelerates hydrolysis. Extreme pH can completely break the molecule.',
    'safety': 'Often safe, but strong acid or base hydrolysis is dangerous.',
  },
  'Spontaneous Combustion': {
    'mechanism': 'A slow reaction builds up heat faster than it can escape, until the substance ignites itself.',
    'realWorld': 'Oily rags in workshops catch fire on their own. White phosphorus ignites in air.',
    'whenMixed': 'Higher temperature or finer particle size makes it more likely.',
    'safety': 'Store oily rags in sealed metal bins. Never pile them loosely.',
  },
  'Alkali Metal': {
    'mechanism': 'Group 1 metals have one loosely-held outer electron, making them extremely reactive.',
    'realWorld': 'Sodium lamps give yellow street lights. Lithium powers your phone battery.',
    'whenMixed': 'Reactivity increases down the group. Lithium is calmer, potassium is violent, cesium explodes.',
    'safety': 'Never touch with wet hands. Store under oil. Never put in water for fun.',
  },
  'Alkaline Earth': {
    'mechanism': 'Group 2 metals have two outer electrons. Reactive but less extreme than group 1.',
    'realWorld': 'Magnesium burns with blinding white light. Calcium builds bones and shells.',
    'whenMixed': 'Reactivity increases down the group. Magnesium burns, barium reacts violently.',
    'safety': 'Magnesium flames are hard to extinguish. Never look directly at burning Mg.',
  },
  'None': {
    'mechanism': 'No chemical change occurs — the two substances are compatible as they are.',
    'realWorld': 'Most mixtures in daily life are stable — salt and sugar, oil and water.',
    'whenMixed': 'A catalyst, heat, or different reagent might trigger something. Otherwise nothing.',
    'safety': 'Safe, but avoid mixing unknown chemicals — surprises happen.',
  },

  // ═══════════════════════════════════════════════════
  // GENERIC FALLBACK — any unmapped reaction
  // ═══════════════════════════════════════════════════
  '_default': {
    'mechanism': 'Atoms rearrange — old bonds break and new bonds form, yielding different substances.',
    'realWorld': 'Every reaction in chemistry is a variation of this basic pattern, happening all around you.',
    'whenMixed': 'The outcome depends on concentration, temperature, and the exact chemicals involved.',
    'safety': 'Always wear safety goggles and handle chemicals with care — even familiar ones can surprise you.',
  },
};
