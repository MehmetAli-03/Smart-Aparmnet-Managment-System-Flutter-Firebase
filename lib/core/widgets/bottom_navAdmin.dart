import 'package:flutter/material.dart';

class AdminBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onCenterTap;

  const AdminBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 70,
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.campaign_rounded, "Duyuru", 0),
          _navItem(Icons.account_balance_rounded, "IBAN", 1),
          const SizedBox(width: 48),
          _navItem(Icons.group_rounded, "Sakinler", 2),
          _navItem(Icons.dashboard_customize_rounded, "Panel", 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade400,
            size: 26,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade400,
            ),
          )
        ],
      ),
    );
  }
}