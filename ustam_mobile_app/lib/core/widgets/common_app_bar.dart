import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/support/screens/support_screen.dart';
import '../../features/onboarding/widgets/tutorial_overlay.dart';
import '../../features/onboarding/models/tutorial_steps.dart';

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
              color: AppColors.textPrimary,
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
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.help_outline, color: AppColors.textWhite),
        onSelected: (value) {
          if (value == 'support') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SupportScreen(userType: userType),
              ),
            );
          } else if (value == 'tutorial') {
            // Show tutorial overlay
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => TutorialOverlay(
                userType: userType,
                steps: userType == 'customer' 
                    ? TutorialSteps.getCustomerSteps()
                    : TutorialSteps.getCraftsmanSteps(),
              ),
            );
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'support',
            child: Row(
              children: [
                Icon(Icons.support_agent, size: 20),
                SizedBox(width: 8),
                Text('Destek Merkezi'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'tutorial',
            child: Row(
              children: [
                Icon(Icons.help_outline, size: 20),
                SizedBox(width: 8),
                Text('Rehberi Tekrar Göster'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}