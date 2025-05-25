import 'dart:io';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/features/client/main/data/model/nav_item.dart';
import 'package:flutter/cupertino.dart';

class NavigationConfig {
  NavigationConfig._(); // Private constructor

  // Платформа-специфик иконларни олиш
  static List<NavItem> getDestinations() {
    return _cupertinoDestinations;
  }

  // Cupertino (iOS) иконлари
  static const List<NavItem> _cupertinoDestinations = [
    NavItem(
      label: 'Главная',
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      path: '/home',
    ),
    NavItem(
      label: 'Новости',
      icon: CupertinoIcons.news,
      activeIcon: CupertinoIcons.news_solid,
      path: '/news',
    ),
    NavItem(
      label: 'Записи',
      icon: CupertinoIcons.calendar,
      activeIcon: CupertinoIcons.calendar,
      path: '/appointments',
    ),
    NavItem(
      label: 'Чат',
      icon: CupertinoIcons.chat_bubble,
      activeIcon: CupertinoIcons.chat_bubble_fill,
      path: '/chat',
    ),
    NavItem(
      label: 'Профиль',
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
      path: '/profile',
    ),
  ];

  static Color getInactiveColor() {
    return Platform.isIOS
        ? CupertinoColors.inactiveGray
        : const Color(0xFFADB5BD);
  }

  static Color getBackgroundColor() {
    return Platform.isIOS
        ? CupertinoColors.systemBackground
        : ColorConstants.backgroundColor;
  }
}
