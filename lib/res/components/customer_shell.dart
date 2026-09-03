import 'package:flutter/material.dart';

/// Lets nested screens open the web-style customer sidebar.
class CustomerShell extends InheritedWidget {
  final VoidCallback openDrawer;

  const CustomerShell({
    super.key,
    required this.openDrawer,
    required super.child,
  });

  static CustomerShell? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CustomerShell>();
  }

  static Widget? menuButton(BuildContext context, {Color? color}) {
    final shell = maybeOf(context);
    if (shell == null) return null;
    return IconButton(
      tooltip: 'Menu',
      onPressed: shell.openDrawer,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: Icon(Icons.menu_rounded, color: color ?? const Color(0xFF1E293B)),
    );
  }

  @override
  bool updateShouldNotify(CustomerShell oldWidget) =>
      openDrawer != oldWidget.openDrawer;
}
