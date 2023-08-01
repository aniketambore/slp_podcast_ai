import 'package:flutter/material.dart';

import 'phone_container.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child; // Add this line to receive the child widget.

  const ResponsiveLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 720) {
          return Scaffold(
            body: PhoneContainer(
              child: child, // Use the provided child widget.
            ),
          );
        } else {
          return child; // Use the provided child widget.
        }
      },
    );
  }
}
