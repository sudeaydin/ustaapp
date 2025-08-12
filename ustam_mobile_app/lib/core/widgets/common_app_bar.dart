import 'package:flutter/material.dart';
import '../../features/support/screens/support_screen.dart';
import '../theme/app_colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showNotifications;
  final bool showTutorialTrigger;
  final String? userType;
  final List<Widget>? additionalActions;
  final List<Widget>? actions; // New parameter
  final VoidCallback? onNotificationTap;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showNotifications = false,
    this.showTutorialTrigger = false,
    this.userType,
    this.additionalActions,
    this.actions, // New parameter
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              color: Colors.white, // Changed from AppColors.textPrimary to white
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getGradient(AppColors.headerGradient),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        // Custom actions first
        if (actions != null) ...actions!,
        
        // Default actions
        if (showNotifications)
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.textWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_outlined, color: AppColors.textWhite),
              onPressed: onNotificationTap ?? () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
          ),
        if (showTutorialTrigger && userType != null)
          SupportButton(userType: userType!),
        if (additionalActions != null) ...additionalActions!,
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SupportButton extends StatelessWidget {
  final String userType;

  const SupportButton({
    super.key,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SupportScreen(userType: userType),
          ),
        );
      },
    );
  }
}