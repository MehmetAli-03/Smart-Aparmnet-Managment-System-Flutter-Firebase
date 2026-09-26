import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModernBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomBar({super.key, required this.currentIndex, required this.onTap});

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
          _navItem(Icons.dashboard_rounded, "Duyuru", 0),
          _navItem(Icons.account_balance_wallet_rounded, "Ödeme", 1),
          const SizedBox(width: 48), // FAB Boşluğu
          _navItem(Icons.forum_rounded, "Şikayet", 2),
          _navItem(Icons.lock_clock, "Oylama", 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
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