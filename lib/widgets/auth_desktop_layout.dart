import 'package:flutter/material.dart';

class AuthDesktopLayout extends StatelessWidget {
  const AuthDesktopLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.form,
    this.footer,
    this.side,
    this.maxFormWidth = 420,
  });

  final String title;
  final String? subtitle;
  final Widget form;
  final Widget? footer;
  final Widget? side;
  final double maxFormWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          // Subtle animated gradient background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withOpacity(0.08),
                    colorScheme.secondary.withOpacity(0.08),
                    colorScheme.surfaceVariant.withOpacity(0.08),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 800),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  final card = _AuthCard(
                    title: title,
                    subtitle: subtitle,
                    form: form,
                    footer: footer,
                    maxFormWidth: maxFormWidth,
                  );

                  if (!isWide) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: card,
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SidePanel(child: side),
                        ),
                        const SizedBox(width: 24),
                        SizedBox(
                          width: 520,
                          child: card,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.title,
    required this.form,
    this.subtitle,
    this.footer,
    required this.maxFormWidth,
  });

  final String title;
  final String? subtitle;
  final Widget form;
  final Widget? footer;
  final double maxFormWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceVariant.withOpacity(0.4),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxFormWidth),
                child: form,
              ),
              if (footer != null) ...[
                const SizedBox(height: 20),
                Divider(color: colorScheme.outlineVariant),
                const SizedBox(height: 8),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withOpacity(0.9),
            colorScheme.tertiaryContainer.withOpacity(0.8),
          ],
        ),
      ),
      child: child ?? _DefaultSideContent(),
    );
  }
}

class _DefaultSideContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onContainer = theme.colorScheme.onPrimaryContainer;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fitness_center_rounded, size: 56, color: onContainer),
          const SizedBox(height: 16),
          Text(
            'Fitness Tracker',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: onContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Build habits. Track progress. Stay motivated.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: onContainer.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration buildFilledInputDecoration({
  required BuildContext context,
  required String label,
  IconData? icon,
}) {
  final theme = Theme.of(context);
  return InputDecoration(
    labelText: label,
    prefixIcon: icon != null ? Icon(icon) : null,
    filled: true,
    isDense: true,
    fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.25),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.6),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}


