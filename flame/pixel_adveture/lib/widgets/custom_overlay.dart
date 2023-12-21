import 'package:flutter/material.dart';

class CustomOverlay extends StatelessWidget {
  final List<Widget> children;

  const CustomOverlay({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: MaterialApp(
        home: Material(
          color: const Color.fromARGB(71, 253, 250, 250),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }
}
