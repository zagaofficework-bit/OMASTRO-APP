import 'package:flutter/material.dart';
import 'navigation_model.dart';

final navigationItems = [
  NavigationItem(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    route: '/home',
  ),
  NavigationItem(
    label: 'Astrologers',
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
    route: '/astrologers',
  ),
  NavigationItem(
    label: 'Live',
    icon: Icons.live_tv_outlined,
    selectedIcon: Icons.live_tv,
    route: '/live',
  ),
  NavigationItem(
    label: 'E-Store',
    icon: Icons.shopping_cart_outlined,
    selectedIcon: Icons.shopping_cart,
    route: '/estore',
  ),
  NavigationItem(
    label: 'Profile',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    route: '/profile',
  ),
];
