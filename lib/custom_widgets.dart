import 'package:flutter/material.dart';

class MainPageButton extends StatelessWidget {
  final String labelText;
  final VoidCallback onPressed;
  final Color backGroundColor;

  const MainPageButton({
    Key? key,
    required this.labelText,
    required this.onPressed,
    this.backGroundColor = const Color(0xFF8764A1),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            backGroundColor, //?? Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: Colors.white, width: 2),
        ),
      ),
      child: Text(
        labelText,
        style: const TextStyle(color: Colors.white, fontSize: 32),
      ),
    );
  }
}

class GymPalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GymPalAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF5C446E),
      title: Text(
        "Gym Pal",
        style: TextStyle(color: Colors.white, fontSize: 40),
      ),
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
