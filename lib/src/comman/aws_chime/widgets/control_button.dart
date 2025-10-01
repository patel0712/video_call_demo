import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;

  const ControlButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.iconColor = Colors.white,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isEnabled ? backgroundColor : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(icon, color: iconColor, size: 24),
                  onPressed: isEnabled ? onPressed : null,
                ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.roboto(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
