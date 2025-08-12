import 'package:flutter/material.dart';

class FilterTabsComponent extends StatefulWidget {
  final int selectedIndex;
  final Function(int)? onTabSelected;

  const FilterTabsComponent({
    Key? key,
    this.selectedIndex = 0,
    this.onTabSelected,
  }) : super(key: key);

  @override
  State<FilterTabsComponent> createState() => _FilterTabsComponentState();
}

class _FilterTabsComponentState extends State<FilterTabsComponent> {
  final List<TabItem> tabs = [
    TabItem(icon: Icons.explore_outlined, label: 'Explore', hasNotification: false),
    TabItem(icon: Icons.favorite_border, label: 'Wishlist', hasNotification: false),
    TabItem(icon: Icons.card_travel_outlined, label: 'Trips', hasNotification: false),
    TabItem(icon: Icons.inbox_outlined, label: 'Inbox', hasNotification: true),
    TabItem(icon: Icons.person_outline, label: 'Profile', hasNotification: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tabs.asMap().entries.map((entry) {
          int index = entry.key;
          TabItem tab = entry.value;
          bool isSelected = index == widget.selectedIndex;

          return GestureDetector(
            onTap: () => widget.onTabSelected?.call(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Icon(
                      isSelected ? _getSelectedIcon(tab.icon) : tab.icon,
                      color: isSelected ? const Color(0xFFE91E63) : Colors.grey,
                      size: 24.0,
                    ),
                    if (tab.hasNotification)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE91E63),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  tab.label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFE91E63) : Colors.grey,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getSelectedIcon(IconData icon) {
    switch (icon) {
      case Icons.explore_outlined:
        return Icons.explore;
      case Icons.favorite_border:
        return Icons.favorite;
      case Icons.card_travel_outlined:
        return Icons.card_travel;
      case Icons.inbox_outlined:
        return Icons.inbox;
      case Icons.person_outline:
        return Icons.person;
      default:
        return icon;
    }
  }
}

class TabItem {
  final IconData icon;
  final String label;
  final bool hasNotification;

  TabItem({
    required this.icon,
    required this.label,
    this.hasNotification = false,
  });
}