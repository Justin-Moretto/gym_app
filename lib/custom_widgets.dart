import 'package:flutter/material.dart';
import 'package:gym_app/Constant.dart' as constant;

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
        elevation: 20,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      child: Text(
        labelText,
        style: TextStyle(
          color: theme.colorScheme.onSecondary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
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
