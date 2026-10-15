import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/iyo_theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';
import 'primitives.dart';

class IyoChatMessage {
  const IyoChatMessage({required this.id, required this.body, required this.mine, this.meta});

  final String id;
  final String body;

  /// Sent by the current user (right-aligned, pale yellow).
  final bool mine;

  /// Pre-formatted meta line, e.g. "09:39 · Read".
  final String? meta;
}

/// Figma chat bubble: up to 82% width, radius 16, padding 14, 9 px meta line.
class IyoChatBubble extends StatelessWidget {
  const IyoChatBubble({super.key, required this.message});

  final IyoChatMessage message;

  @override
  Widget build(BuildContext context) {
    // Figma: bubbles are at most 280 wide (82% of the width on small phones).
    final width = MediaQuery.sizeOf(context).width * 0.82;
    final maxWidth = width < 280 ? width : 280.0;
    return Column(
      crossAxisAlignment: message.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: message.mine ? context.iyo.accentSoft : IyoPalette.surface,
              borderRadius: BorderRadius.circular(IyoRadii.lg),
            ),
            child: IyoText(message.body),
          ),
        ),
        if (message.meta != null) ...[
          const SizedBox(height: 3),
          IyoText(message.meta!, variant: IyoTextVariant.micro, color: IyoPalette.textSecondary),
        ],
      ],
    );
  }
}

/// Message list (Figma 2025:342).
class IyoChatThread extends StatelessWidget {
  const IyoChatThread({
    super.key,
    required this.messages,
    this.header,
    this.footer,
    this.controller,
  });

  final List<IyoChatMessage> messages;

  /// Above the first message (identity card, privacy note).
  final Widget? header;

  /// Below the last message (quick replies).
  final Widget? footer;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      if (header != null) header!,
      for (final m in messages) IyoChatBubble(key: ValueKey(m.id), message: m),
      if (footer != null) footer!,
    ];
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(
        IyoSpacing.screenPadding,
        0,
        IyoSpacing.screenPadding,
        IyoSpacing.md,
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: IyoSpacing.stack),
      itemBuilder: (_, i) => items[i],
    );
  }
}

/// Figma "Message composer": 52 px grey bar, plus icon, input, 32 px accent send button.
class IyoChatComposer extends StatefulWidget {
  const IyoChatComposer({
    super.key,
    required this.placeholder,
    required this.sendLabel,
    required this.onSend,
    this.attachLabel,
    this.onAttach,
    this.enabled = true,
  });

  final String placeholder;
  final String sendLabel;
  final ValueChanged<String> onSend;
  final String? attachLabel;
  final VoidCallback? onAttach;
  final bool enabled;

  @override
  State<IyoChatComposer> createState() => _IyoChatComposerState();
}

class _IyoChatComposerState extends State<IyoChatComposer> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSend => widget.enabled && _controller.text.trim().isNotEmpty;

  void _send() {
    if (!_canSend) return;
    widget.onSend(_controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: IyoSizes.buttonHeight),
      padding: const EdgeInsets.fromLTRB(16, 6, 14, 6),
      decoration: BoxDecoration(
        color: IyoPalette.surface,
        borderRadius: BorderRadius.circular(IyoRadii.md),
      ),
      child: Row(
        children: [
          if (widget.onAttach != null && widget.attachLabel != null) ...[
            // Figma: bare 18 px "+" 16 from the edge, placeholder 12 after it.
            IyoPressable(
              onPressed: widget.onAttach,
              semanticLabel: widget.attachLabel,
              minHitSize: 0,
              child: const SizedBox(
                width: 18,
                height: 40,
                child: IyoIcon(LucideIcons.plus, size: 18),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              minLines: 1,
              maxLines: 4,
              maxLength: 1000,
              style: IyoTextVariant.body.style.copyWith(color: IyoPalette.ink),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                hintText: widget.placeholder,
                hintStyle: IyoTextVariant.body.style.copyWith(color: IyoPalette.textSecondary),
              ),
            ),
          ),
          const SizedBox(width: IyoSpacing.sm),
          IyoIconButton(
            icon: LucideIcons.arrowUp,
            tone: IyoIconButtonTone.accent,
            rounded: true,
            size: 32,
            iconSize: 18,
            semanticLabel: widget.sendLabel,
            // Stays solid like the frame; sending empty text is a no-op.
            onPressed: _send,
            disabled: !widget.enabled,
          ),
        ],
      ),
    );
  }
}
