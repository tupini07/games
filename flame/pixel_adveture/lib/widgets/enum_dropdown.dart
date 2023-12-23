import 'package:flutter/material.dart';

class EnumDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) display;
  final void Function(T) onChanged;

  const EnumDropdown({
    super.key,
    required this.items,
    required this.display,
    required this.onChanged,
  });

  @override
  EnumDropdownState<T> createState() => EnumDropdownState<T>();
}

class EnumDropdownState<T> extends State<EnumDropdown<T>> {
  T? _selectedValue;

  @override
  Widget build(BuildContext context) {
    _selectedValue = _selectedValue ?? widget.items.first;

    return DropdownButton<T>(
      value: _selectedValue,
      items: widget.items.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(widget.display(value)),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedValue = newValue;
        });
        if (newValue != null) {
          widget.onChanged(newValue);
        }
      },
    );
  }
}
