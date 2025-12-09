import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const LoadingButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        foregroundColor ??
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Connecting...'),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
                  Text(label),
                ],
              ),
      ),
    );
  }
}
