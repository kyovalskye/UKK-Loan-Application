import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentalify/core/themes/app_colors.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../home/pages/home_page.dart';
import '../../profile/pages/profile_page.dart';
import '../widgets/bottom_nav_item.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});    

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Navigation items untuk setiap role
  List<BottomNavItem> _getNavItems(String? role) {
    if (role == 'peminjam') {
      return [
        BottomNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
        ),
        BottomNavItem(
          icon: Icons.assignment_outlined,
          activeIcon: Icons.assignment,
          label: 'Peminjaman',
        ),
        BottomNavItem(
          icon: Icons.history_outlined,
          activeIcon: Icons.history,
          label: 'Riwayat',
        ),
        BottomNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
        ),
      ];
    } else if (role == 'petugas') {
      return [
        BottomNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
        ),
        BottomNavItem(
          icon: Icons.pending_actions_outlined,
          activeIcon: Icons.pending_actions,
          label: 'Persetujuan',
        ),
        BottomNavItem(
          icon: Icons.assignment_return_outlined,
          activeIcon: Icons.assignment_return,
          label: 'Pengembalian',
        ),
        BottomNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
        ),
      ];
    } else if (role == 'admin') {
      return [
        BottomNavItem(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          label: 'Dashboard',
        ),
        BottomNavItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
          label: 'Alat',
        ),
        BottomNavItem(
          icon: Icons.people_outline,
          activeIcon: Icons.people,
          label: 'Users',
        ),
        BottomNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
        ),
      ];
    }
    return [];
  }

  List<Widget> _getPages(String? role) {
    // Profile page is the same for all roles
    const profilePage = ProfilePage();
    
    if (role == 'peminjam') {
      return [
        const HomePage(),
        _buildPlaceholderPage('Peminjaman Saya'),
        _buildPlaceholderPage('Riwayat'),
        profilePage,
      ];
    } else if (role == 'petugas') {
      return [
        const HomePage(),
        _buildPlaceholderPage('Persetujuan'),
        _buildPlaceholderPage('Pengembalian'),
        profilePage,
      ];
    } else if (role == 'admin') {
      return [
        const HomePage(),
        _buildPlaceholderPage('Kelola Alat'),
        _buildPlaceholderPage('Kelola Users'),
        profilePage,
      ];
    }
    
    return [
      const HomePage(),
      _buildPlaceholderPage('Page 2'),
      _buildPlaceholderPage('Page 3'),
      profilePage,
    ];
  }

  Widget _buildPlaceholderPage(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final navItems = _getNavItems(state.userRole);
        final pages = _getPages(state.userRole);

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    navItems.length,
                    (index) => _buildNavItem(
                      navItems[index],
                      index,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(BottomNavItem item, int index) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}