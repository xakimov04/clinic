import 'package:flutter/material.dart' show IconData;

class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavItem &&
        other.label == label &&
        other.icon == icon &&
        other.activeIcon == activeIcon &&
        other.path == path;
  }

  @override
  int get hashCode {
    return label.hashCode ^ icon.hashCode ^ activeIcon.hashCode ^ path.hashCode;
  }

  @override
  String toString() {
    return 'NavItem(label: $label, icon: $icon, activeIcon: $activeIcon, path: $path)';
  }
}
