import 'package:flutter/material.dart';
import 'package:gym_app/Constant.dart' as constant;

class MainPageButton extends StatelessWidget {
  final String labelText;
  final VoidCallback onPressed;
  final Color backGroundColor;

  const MainPageButton({
    Key? key,
    required this.labelText,
    required this.onPressed,
    this.backGroundColor = const Color.fromRGBO(100, 70, 110, 1.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            backGroundColor, //?? Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 20,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      child: Text(
        labelText,
        style: const TextStyle(color: Colors.white, fontSize: 32),
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
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 40)),
      leading:
          Navigator.canPop(context)
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
              : null,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
