import 'package:flutter/material.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/font-style.dart';
import 'package:project_web/styles/text-style.dart';

class CustomAdminBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueNotifier<int> selectedIndex;
  final VoidCallback onRefresh;

  CustomAdminBar({
    required this.selectedIndex,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryBackground, 
      foregroundColor: AppColors.primaryText, 
      elevation: 0, 
      
      title: Text(
        'Admin Dashboard',
        style: TextStyles.title.copyWith(
          fontSize: FontStyles.heading, 
          fontWeight: FontStyles.bold,
          color: AppColors.primaryBlack,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(48.0),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.inputBorder, 
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabButton(
                context,
                title: 'Schools',
                index: 0,
              ),
              _buildTabButton(
                context,
                title: 'Requests',
                index: 1,
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: AppColors.primaryText, 
          ),
          onPressed: onRefresh,
        ),
      ],
    );
  }

  Widget _buildTabButton(BuildContext context, {required String title, required int index}) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (context, value, child) {
        final isSelected = value == index;
        return TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            splashFactory: NoSplash.splashFactory, 
          ),
          onPressed: () {
            selectedIndex.value = index;
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: isSelected
                    ? TextStyles.navigationActive.copyWith(fontSize: FontStyles.medium) 
                    : TextStyles.navigationInactive.copyWith(
                        fontSize: FontStyles.medium, 
                        color: AppColors.primaryBlack, 
                        fontWeight: FontStyles.regular, 
                      ),
              ),
              const SizedBox(height: 4.0),
              if (isSelected)
                Container(
                  height: 3.0,
                  width: 40.0, 
                  decoration: const BoxDecoration(
                    color: AppColors.primaryButton, 
                    borderRadius: BorderRadius.all(Radius.circular(1.5)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 48.0);
}