import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';
import 'icons.dart';
import 'pressable.dart';
import 'theme.dart';
import 'tokens.dart';

/// Text input with the label above the field, a Plum focus border, and the
/// app's own selection handles and cut/copy/paste menu.
class B4TextField extends StatefulWidget {
  const B4TextField({
    required this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.autocorrect = true,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.prefixIcon,
    this.suffix,
    this.enabled = true,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  /// Enforced while typing; no counter is shown.
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final bool autocorrect;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool enabled;
  final bool autofocus;

  @override
  State<B4TextField> createState() => _B4TextFieldState();
}

class _B4TextFieldState extends State<B4TextField> {
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(B4TextField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownFocus)?.removeListener(_onFocus);
      _focus.addListener(_onFocus);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _ownFocus?.dispose();
    super.dispose();
  }

  void _onFocus() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = context.text;
    final hasError = widget.errorText != null;
    final focused = _focus.hasFocus;
    final multiline = (widget.maxLines ?? 2) > 1;

    final border = focused
        ? Border.all(color: hasError ? p.dangerText : p.primary, width: 2)
        : Border.all(
            color: hasError ? p.dangerText : const Color(0x00000000),
            width: hasError ? 1.5 : 2,
          );

    final field = AnimatedContainer(
      duration: Tokens.motion,
      constraints: const BoxConstraints(minHeight: Tokens.controlHeight),
      padding: EdgeInsets.fromLTRB(
        widget.prefixIcon == null ? 16 : 12,
        multiline ? 14 : 0,
        widget.suffix == null ? 16 : 4,
        multiline ? 14 : 0,
      ),
      decoration: BoxDecoration(
        color: p.surfaceVariant,
        borderRadius: BorderRadius.circular(Tokens.controlRadius),
        border: border,
      ),
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (widget.prefixIcon != null) ...[
            Icon(widget.prefixIcon, color: p.textSecondary),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Semantics(
              label: widget.label,
              child: B4EditableText(
                controller: widget.controller,
                focusNode: _focus,
                hint: widget.hint,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                textCapitalization: widget.textCapitalization,
                inputFormatters: [
                  ...?widget.inputFormatters,
                  if (widget.maxLength != null)
                    LengthLimitingTextInputFormatter(widget.maxLength),
                ],
                minLines: widget.minLines,
                maxLines: widget.maxLines,
                autocorrect: widget.autocorrect,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
              ),
            ),
          ),
          if (widget.suffix != null) widget.suffix!,
        ],
      ),
    );

    return DisabledOpacity(
      enabled: widget.enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null)
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  widget.label!,
                  style: text.labelMedium.copyWith(
                    color: hasError
                        ? p.dangerText
                        : focused
                        ? p.primaryText
                        : p.textSecondary,
                  ),
                ),
              ),
            ),
          field,
          if (hasError)
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        RemixIcons.errorWarningLine,
                        size: 16,
                        color: p.dangerText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.errorText!,
                        style: text.bodyMedium.copyWith(color: p.dangerText),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (widget.helperText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Text(widget.helperText!, style: text.bodySmall),
            ),
        ],
      ),
    );
  }
}

/// [B4TextField] that takes part in a [Form]. The validator receives the
/// controller's current text, so programmatic changes are validated too.
class B4TextFormField extends FormField<String> {
  B4TextFormField({
    required TextEditingController controller,
    String? Function(String text)? validator,
    String? label,
    String? hint,
    String? helperText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    int? minLines,
    int? maxLines = 1,
    bool autocorrect = true,
    ValueChanged<String>? onChanged,
    super.key,
  }) : super(
         initialValue: controller.text,
         validator: validator == null
             ? null
             : (_) => validator(controller.text),
         builder: (field) => B4TextField(
           controller: controller,
           label: label,
           hint: hint,
           helperText: helperText,
           errorText: field.errorText,
           keyboardType: keyboardType,
           textInputAction: textInputAction,
           textCapitalization: textCapitalization,
           inputFormatters: inputFormatters,
           maxLength: maxLength,
           minLines: minLines,
           maxLines: maxLines,
           autocorrect: autocorrect,
           onChanged: (value) {
             field.didChange(value);
             onChanged?.call(value);
           },
         ),
       );
}

/// Rounded search box with a leading search icon.
class B4SearchField extends StatefulWidget {
  const B4SearchField({
    required this.controller,
    required this.hint,
    this.onChanged,
    this.trailing,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final Widget? trailing;

  @override
  State<B4SearchField> createState() => _B4SearchFieldState();
}

class _B4SearchFieldState extends State<B4SearchField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedContainer(
      duration: Tokens.motion,
      height: 52,
      padding: EdgeInsets.only(
        left: 16,
        right: widget.trailing == null ? 16 : 2,
      ),
      decoration: BoxDecoration(
        color: p.surfaceVariant,
        borderRadius: BorderRadius.circular(Tokens.controlRadius),
        border: Border.all(
          color: _focus.hasFocus ? p.primary : const Color(0x00000000),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(RemixIcons.searchLine, color: p.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              label: widget.hint,
              child: B4EditableText(
                controller: widget.controller,
                focusNode: _focus,
                hint: widget.hint,
                textInputAction: TextInputAction.search,
                onChanged: widget.onChanged,
              ),
            ),
          ),
          ?widget.trailing,
        ],
      ),
    );
  }
}

/// [EditableText] with the gestures, selection handles and context menu a
/// text field needs, styled for B4Due. Used inside [B4TextField] and
/// [B4SearchField].
class B4EditableText extends StatefulWidget {
  const B4EditableText({
    required this.controller,
    required this.focusNode,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.minLines,
    this.maxLines = 1,
    this.autocorrect = true,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int? maxLines;
  final bool autocorrect;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool autofocus;

  @override
  State<B4EditableText> createState() => _B4EditableTextState();
}

class _B4EditableTextState extends State<B4EditableText>
    implements TextSelectionGestureDetectorBuilderDelegate {
  @override
  final GlobalKey<EditableTextState> editableTextKey = GlobalKey();

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => widget.enabled;

  late final _gestures = TextSelectionGestureDetectorBuilder(delegate: this);
  var _showHandles = false;

  bool _shouldShowHandles(SelectionChangedCause? cause) {
    if (!_gestures.shouldShowSelectionToolbar ||
        !_gestures.shouldShowSelectionHandles) {
      return false;
    }
    if (cause == SelectionChangedCause.keyboard || !widget.enabled) {
      return false;
    }
    if (cause == SelectionChangedCause.longPress) return true;
    return widget.controller.text.isNotEmpty;
  }

  void _onSelectionChanged(
    TextSelection selection,
    SelectionChangedCause? cause,
  ) {
    final show = _shouldShowHandles(cause);
    if (show != _showHandles) setState(() => _showHandles = show);
    if (cause == SelectionChangedCause.longPress) {
      editableTextKey.currentState?.bringIntoView(selection.extent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = context.text.bodyLarge;
    final focused = widget.focusNode.hasFocus;

    final editable = EditableText(
      key: editableTextKey,
      controller: widget.controller,
      focusNode: widget.focusNode,
      readOnly: !widget.enabled,
      style: style,
      cursorColor: p.primary,
      backgroundCursorColor: p.textSecondary,
      cursorWidth: 2,
      cursorRadius: const Radius.circular(1),
      selectionColor: focused ? p.primary.withValues(alpha: 0.28) : null,
      selectionControls: widget.enabled
          ? B4TextSelectionControls(p.primary)
          : null,
      showSelectionHandles: _showHandles,
      onSelectionChanged: _onSelectionChanged,
      contextMenuBuilder: (context, state) =>
          B4TextContextMenu(editableTextState: state),
      rendererIgnoresPointer: true,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.autocorrect,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      keyboardAppearance: p.brightness,
      scrollPadding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
    );

    return _gestures.buildGestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Padding(
        // Vertical room so single-line fields are easy to hit.
        padding: EdgeInsets.symmetric(
          vertical: (widget.maxLines ?? 2) > 1 ? 0 : 14,
        ),
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            if (widget.hint != null)
              ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) => widget.controller.text.isEmpty
                    ? ExcludeSemantics(
                        child: Text(
                          widget.hint!,
                          style: style.copyWith(color: p.textSecondary),
                          maxLines: widget.maxLines,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            editable,
          ],
        ),
      ),
    );
  }
}

/// Plum teardrop handles.
class B4TextSelectionControls extends TextSelectionControls
    with TextSelectionHandleControls {
  B4TextSelectionControls(this.color);

  final Color color;
  static const _size = 22.0;

  @override
  Size getHandleSize(double textLineHeight) => const Size(_size, _size);

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    final handle = SizedBox.square(
      dimension: _size,
      child: CustomPaint(
        painter: _HandlePainter(color),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
        ),
      ),
    );
    // The painted teardrop points to the top left; rotate per handle type.
    return switch (type) {
      TextSelectionHandleType.left => Transform.rotate(
        angle: math.pi / 2,
        child: handle,
      ),
      TextSelectionHandleType.right => handle,
      TextSelectionHandleType.collapsed => Transform.rotate(
        angle: math.pi / 4,
        child: handle,
      ),
    };
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) =>
      switch (type) {
        TextSelectionHandleType.collapsed => const Offset(_size / 2, -4),
        TextSelectionHandleType.left => const Offset(_size, 0),
        TextSelectionHandleType.right => Offset.zero,
      };
}

class _HandlePainter extends CustomPainter {
  _HandlePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final r = size.width / 2;
    canvas
      ..drawCircle(Offset(r, r), r, paint)
      ..drawRect(Rect.fromLTWH(0, 0, r, r), paint);
  }

  @override
  bool shouldRepaint(_HandlePainter old) => old.color != color;
}

/// Floating cut/copy/paste/select-all bar shown above the selection: a light
/// card with Plum labels, unlike the dark system toolbar.
class B4TextContextMenu extends StatelessWidget {
  const B4TextContextMenu({required this.editableTextState, super.key});

  final EditableTextState editableTextState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final items = [
      for (final item in editableTextState.contextMenuButtonItems)
        if (_label(l10n, item) case final label?) (label, item.onPressed),
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    final anchors = editableTextState.contextMenuAnchors;
    final top = MediaQuery.paddingOf(context).top + 8;
    const side = 8.0;
    final shift = Offset(side, top);

    return Padding(
      padding: EdgeInsets.fromLTRB(side, top, side, side),
      child: CustomSingleChildLayout(
        delegate: TextSelectionToolbarLayoutDelegate(
          anchorAbove: anchors.primaryAnchor - shift - const Offset(0, 10),
          anchorBelow:
              (anchors.secondaryAnchor ?? anchors.primaryAnchor) -
              shift +
              const Offset(0, 24),
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(Tokens.chipRadius),
            border: Border.all(color: p.outlineStrong),
            boxShadow: [
              BoxShadow(
                color: p.isDark
                    ? const Color(0x66000000)
                    : const Color(0x261F1A2E),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(width: 1, color: p.outline),
                    ),
                  Pressable(
                    onTap: items[i].$2,
                    pressedOverlay: p.primarySoft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Text(
                        items[i].$1,
                        style: context.text.labelMedium.copyWith(
                          color: p.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String? _label(AppLocalizations l10n, ContextMenuButtonItem item) =>
      switch (item.type) {
        ContextMenuButtonType.cut => l10n.textCut,
        ContextMenuButtonType.copy => l10n.textCopy,
        ContextMenuButtonType.paste => l10n.textPaste,
        ContextMenuButtonType.selectAll => l10n.textSelectAll,
        ContextMenuButtonType.delete => l10n.actionDelete,
        _ => item.label,
      };
}
