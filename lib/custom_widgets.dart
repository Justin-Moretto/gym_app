import 'package:flutter/material.dart';
import 'package:gym_app/Constant.dart' as constant;
import 'package:gym_app/styles/text_styles.dart';

class MainPageButton extends StatelessWidget {
  final String labelText;
  final VoidCallback onPressed;
  final Color? backGroundColor;

  const MainPageButton({
    Key? key,
    required this.labelText,
    required this.onPressed,
    this.backGroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backGroundColor ?? theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        labelText,
        style: AppTextStyles.withColor(AppTextStyles.mainPageButton, theme.colorScheme.onSecondary),
      ),
    );
  }
}

class GymPalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const GymPalAppBar({Key? key, this.title = constant.appBarDefaultTitle})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      title: Text(
        title,
        style: theme.appBarTheme.titleTextStyle,
      ),
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: theme.appBarTheme.iconTheme?.color,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      centerTitle: theme.appBarTheme.centerTitle ?? true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class GymPalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const GymPalCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: color ?? theme.cardColor,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}
