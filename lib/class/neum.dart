import 'package:flutter/material.dart';

class NeumorphicButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const NeumorphicButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: Offset(-4, -4),
              blurRadius: 10,
            ),
            BoxShadow(
              color: Colors.grey[500]!,
              offset: Offset(4, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 25,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
