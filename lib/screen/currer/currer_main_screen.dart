import 'package:flutter/material.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/screen/currer/history/currer_history_screen.dart';
import 'package:water_go/screen/currer/home/currer_home_screen.dart';
import 'package:water_go/screen/currer/kassa/currer_kassa_screen.dart';
import 'package:water_go/screen/currer/order/currer_order_screen.dart';
import 'package:water_go/screen/profile/profile_screen.dart';

class CurrerMainScreen extends StatefulWidget {
  const CurrerMainScreen({super.key});
  @override
  State<CurrerMainScreen> createState() => _CurrerMainScreenState();
}

class _CurrerMainScreenState extends State<CurrerMainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    CurrerHomeScreen(),
    CurrerOrderScreen(),
    CurrerHistoryScreen(),
    CurrerKassaScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: ColorConst.navy,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: ColorConst.card.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0,-4,),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0,Icons.home_rounded,Icons.home_outlined,"Asosiy",),
              _buildNavItem(1,Icons.local_shipping_rounded,Icons.local_shipping_outlined,"Aktiv",),
              _buildNavItem(2,Icons.history_rounded,Icons.history_outlined,"Tarix",),
              _buildNavItem(3,Icons.account_balance_wallet_rounded,Icons.account_balance_wallet_outlined,"Kassa",),
              _buildNavItem(4,Icons.person_rounded,Icons.person_outline_rounded,"Profil",),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index,IconData selectedIcon,IconData unselectedIcon,String label,) {
    final bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () { setState(() { _currentIndex = index; }); },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ColorConst.bluePale : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? ColorConst.blue : ColorConst.muted,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? ColorConst.blue : ColorConst.muted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
