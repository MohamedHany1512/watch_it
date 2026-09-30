import 'package:flutter/material.dart';
import 'package:watch_it/core/common/widgets/glass_surface.dart';
import 'package:watch_it/core/themes/app_colors.dart';

class FloatingSearchBar extends StatefulWidget {
  const FloatingSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    this.hintText = 'Search videos…',
    this.autofocus = false,
  });

  final TextEditingController controller;

  /// Debounced by the Cubit.
  final ValueChanged<String> onChanged;

  /// Fired by the keyboard "search" key, runs immediately.
  final ValueChanged<String> onSubmitted;

  final VoidCallback onClear;
  final String hintText;
  final bool autofocus;

  @override
  State<FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<FloatingSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleClear() {
    widget.onClear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AnimatedScale(
      // A subtle "lift" on focus: the bar physically comes forward.
      scale: _isFocused ? 1.0 : 0.985,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: GlassSurface(
        blur: 28,
        borderRadius: AppColors.pillRadius,
        fill: _isFocused ? AppColors.glassFillStrong : AppColors.glassFill,
        borderColor: _isFocused
            ? AppColors.primary.withValues(alpha: 0.55)
            : AppColors.glassBorder,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 14),
              // Icon cross-fades between search and "AI/sparkle" when focused.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  _isFocused
                      ? Icons.auto_awesome_rounded
                      : Icons.search_rounded,
                  key: ValueKey<bool>(_isFocused),
                  size: 21,
                  color: _isFocused
                      ? AppColors.primaryLight
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  textInputAction: TextInputAction.search,
                  keyboardType: TextInputType.text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  cursorWidth: 2,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: widget.hintText,
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
              // Trailing clear button, animated in and out.
              AnimatedScale(
                scale: _isFocused ? 1 : 0.8,
                duration: const Duration(milliseconds: 200),
                child: AnimatedOpacity(
                  opacity: _isFocused ? 1 : 0.55,
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    onPressed: _handleClear,
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
