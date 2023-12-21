import 'package:flutter/material.dart';

class SimpleSlider extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;
  final String? label;

  const SimpleSlider({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.label,
  });

  @override
  _SimpleSliderState createState() => _SimpleSliderState();
}

class _SimpleSliderState extends State<SimpleSlider> {
  double _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: _currentValue,
          label: widget.label,
          onChanged: (newValue) {
            setState(() {
              _currentValue = newValue;
            });
            widget.onChanged(newValue);
          },
        ),
        Text('Current value: ${_currentValue.toStringAsFixed(3)}'),
      ],
    );
  }
}
