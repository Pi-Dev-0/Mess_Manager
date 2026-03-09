import 'package:flutter/material.dart';
import 'dart:ui'; // Import for ImageFilter
import 'dart:math'; // Import for Random

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  static const List<Color> _beautifulColors = [
    Color(0xFF6200EE), // deepPurple
    Color(0xFF03DAC6), // tealAccent
    Color(0xFFFF7F50), // coralSunset
    Color(0xFF228B22), // forestGreen
    Color(0xFF4B0082), // vibrantIndigo
    Color(0xFF4169E1), // royalBlue
    Color(0xFF9966CC), // amethyst
    Color(0xFF40E0D0), // turquoise
    Color(0xFFDC143C), // richCrimson
    Color(0xFFDAA520), // goldenrodYellow
    Color(0xFF008080), // deepSeaTeal
    Color(0xFFFF69B4), // roseQuartz
  ];

  static final Random _random = Random();
  late final Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = _beautifulColors[_random.nextInt(_beautifulColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double appBarHeight = isLandscape ? 45 : kToolbarHeight;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(30),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: appBarHeight + MediaQuery.of(context).padding.top,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
          ),
          child: AppBar(
            leading: widget.leading,
            title: Text(
              widget.title,
              style: TextStyle(
                color: selectedColor,
                shadows: [
                  Shadow(
                    color: selectedColor.withOpacity(0.5),
                    offset: const Offset(0, 1),
                    blurRadius: 30,
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            centerTitle: widget.centerTitle,
            actions: widget.actions ?? [],
            toolbarHeight: appBarHeight,
            iconTheme: IconThemeData(color: selectedColor),
          ),
        ),
      ),
    );
  }
}
