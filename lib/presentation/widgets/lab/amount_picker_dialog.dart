part of chem_lab;

class AmountPickerDialog extends StatefulWidget {
  final Chemical chemical;
  const AmountPickerDialog({super.key, required this.chemical});
  @override
  State<AmountPickerDialog> createState() => _AmountPickerDialogState();
}


class _AmountPickerDialogState extends State<AmountPickerDialog> {
  late FixedExtentScrollController _ctrl;
  late List<int> _amounts;
  late int _selectedIdx;
  late String _unit;

  @override
  void initState() {
    super.initState();
    final isLiquid = widget.chemical.state == 'Liquid';
    if (isLiquid) {
      _amounts = List.generate(50, (i) => (i + 1) * 5);
      _unit = 'ml';
      _selectedIdx = _amounts.indexOf(50);
    } else {
      _amounts = List.generate(50, (i) => i + 1);
      _unit = 'g';
      _selectedIdx = _amounts.indexOf(5);
    }
    if (_selectedIdx < 0) _selectedIdx = 0;
    _ctrl = FixedExtentScrollController(initialItem: _selectedIdx);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1F2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 280,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.chemical.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.chemical.formula, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
          const SizedBox(height: 12),
          Text('SELECT AMOUNT', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 10, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: Stack(alignment: Alignment.center, children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.symmetric(horizontal: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1)),
                ),
              ),
              ListWheelScrollView.useDelegate(
                controller: _ctrl,
                itemExtent: 48,
                perspective: 0.003,
                diameterRatio: 1.6,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) => setState(() => _selectedIdx = i),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: _amounts.length,
                  builder: (context, index) {
                    final sel = index == _selectedIdx;
                    return Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('${_amounts[index]}', style: TextStyle(
                            color: sel ? Colors.white : Colors.white.withValues(alpha: 0.25),
                            fontSize: sel ? 32 : 20,
                            fontWeight: sel ? FontWeight.bold : FontWeight.w400,
                          )),
                          const SizedBox(width: 6),
                          Text(_unit, style: TextStyle(
                            color: sel ? Colors.white70 : Colors.white.withValues(alpha: 0.15),
                            fontSize: sel ? 16 : 12,
                          )),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
            )),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.pop(context, _amounts[_selectedIdx].toDouble()),
              child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )),
          ]),
        ]),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// CHEMICAL INFO — Extended Study Data
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

