import 'package:flutter/material.dart';

/// Reusable action button widget with icon, label, and description
class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final String? description;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isEnabled;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.description,
    this.backgroundColor,
    this.foregroundColor,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      child: Card(
        elevation: isEnabled ? 2 : 0,
        color: backgroundColor ?? theme.colorScheme.surface,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEnabled
                        ? (foregroundColor ?? theme.colorScheme.primary)
                              .withOpacity(0.1)
                        : theme.colorScheme.onSurface.withOpacity(0.1),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isEnabled
                        ? foregroundColor ?? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isEnabled
                              ? foregroundColor ?? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isEnabled
                                ? (foregroundColor ??
                                          theme.colorScheme.onSurface)
                                      .withOpacity(0.7)
                                : theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isEnabled
                      ? (foregroundColor ?? theme.colorScheme.onSurface)
                            .withOpacity(0.5)
                      : theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
