import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppBarType { standard, gradient, transparent }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final AppBarType type;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final List<Color>? gradientColors;

  const CustomAppBar({
    super.key,
    required this.title,
    this.type = AppBarType.standard,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    Widget appBarContent = AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: _getTitleColor(),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading ?? (automaticallyImplyLeading ? _buildBackButton(context) : null),
      actions: actions,
      backgroundColor: _getBackgroundColor(),
      elevation: type == AppBarType.transparent ? 0 : 2,
      shadowColor: DesignTokens.shadowLight,
    );

    if (type == AppBarType.gradient) {
      return Container(
        decoration: BoxDecoration(
          gradient: DesignTokens.getGradient(
            gradientColors ?? DesignTokens.primaryCoralGradient,
          ),
        ),
        child: appBarContent,
      );
    }

    return appBarContent;
  }

  Widget? _buildBackButton(BuildContext context) {
    if (!Navigator.canPop(context)) return null;
    
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: _getIconColor(),
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case AppBarType.standard:
        return backgroundColor ?? DesignTokens.surfacePrimary;
      case AppBarType.gradient:
        return Colors.transparent;
      case AppBarType.transparent:
        return Colors.transparent;
    }
  }

  Color _getTitleColor() {
    switch (type) {
      case AppBarType.standard:
        return DesignTokens.gray900;
      case AppBarType.gradient:
        return Colors.white;
      case AppBarType.transparent:
        return DesignTokens.gray900;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case AppBarType.standard:
        return DesignTokens.gray900;
      case AppBarType.gradient:
        return Colors.white;
      case AppBarType.transparent:
        return DesignTokens.gray900;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Specialized app bar variants
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      type: AppBarType.gradient,
      actions: actions,
      leading: leading,
      gradientColors: DesignTokens.primaryCoralGradient,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}