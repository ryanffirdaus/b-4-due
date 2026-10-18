import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'icons.dart';
import 'pressable.dart';
import 'theme.dart';
import 'tokens.dart';

/// Page for go_router: pushed pages slide in slightly from the right and
/// fade; the page below dims a little.
CustomTransitionPage<void> b4Page(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      name: state.name,
      child: child,
      transitionDuration: Tokens.motionSlow,
      reverseTransitionDuration: Tokens.motion,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final inCurve = CurvedAnimation(
          parent: animation,
          curve: Tokens.curve,
          reverseCurve: Curves.easeInCubic,
        );
        final outCurve = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Tokens.curve,
        );
        return SlideTransition(
          position: Tween(
            begin: const Offset(0.12, 0),
            end: Offset.zero,
          ).animate(inCurve),
          child: FadeTransition(
            opacity: inCurve,
            child: FadeTransition(
              opacity: Tween(begin: 1.0, end: 0.85).animate(outCurve),
              child: child,
            ),
          ),
        );
      },
    );

/// Page for a tab root: no transition (tabs switch in place).
NoTransitionPage<void> b4TabPage(GoRouterState state, Widget child) =>
    NoTransitionPage<void>(key: state.pageKey, name: state.name, child: child);

/// Heading row that expands to reveal [child].
class B4Expandable extends StatefulWidget {
  const B4Expandable({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    super.key,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<B4Expandable> createState() => _B4ExpandableState();
}

class _B4ExpandableState extends State<B4Expandable> {
  late var _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          expanded: _expanded,
          child: Pressable(
            onTap: () => setState(() => _expanded = !_expanded),
            pressedScale: 1,
            child: Container(
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: context.text.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: Tokens.motion,
                    child: Icon(
                      RemixIcons.arrowDownSLine,
                      color: p.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: Tokens.motion,
            curve: Tokens.curve,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
      ],
    );
  }
}
