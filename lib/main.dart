library chem_lab;

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

part 'presentation/widgets/lab/realistic_equip_painter.dart';
part 'data/models/bench_tool_model.dart';
part 'services/chemistry/heating_effect_model.dart';
part 'services/chemistry/heating_effects_data.dart';
part 'services/chemistry/reactions_data.dart';
part 'services/chemistry/heat_decompose_chems_data.dart';
part 'services/chemistry/multi_reactions_data.dart';
part 'data/models/experiment_model.dart';
part 'presentation/widgets/lab/heating_setup_painter.dart';
part 'presentation/widgets/lab/ice_painter.dart';
part 'data/models/reaction_model.dart';
part 'data/models/reaction_details.dart';
part 'presentation/widgets/lab/drag_bottle_painter.dart';
part 'app.dart';
part 'data/models/equipment_model.dart';
part 'presentation/widgets/lab/molecule_painter.dart';
part 'presentation/widgets/lab/marble_bench_painter.dart';
part 'presentation/widgets/lab/bench_tool_painter.dart';
part 'presentation/screens/lab/lab_screen.dart';
part 'presentation/widgets/lab/amount_picker_dialog.dart';
part 'presentation/widgets/lab/mini_bottle_painter.dart';
part 'core/theme/lab_colors.dart';
part 'services/chemistry/side_effect.dart';
part 'data/models/lab_effect.dart';
part 'data/models/lab_effect_ext.dart';
part 'data/models/equip_shape.dart';
part 'data/models/equip_shape_ext.dart';
part 'data/models/chemical_model.dart';
part 'data/models/molecule_model.dart';

part 'services/chemistry/ph_calculator.dart';
part 'services/chemistry/lab_ph_service.dart';
part 'presentation/widgets/lab/ph_color_book.dart';
part 'presentation/widgets/lab/litmus_color_book.dart';
void main() => runApp(const ChemLabApp());





