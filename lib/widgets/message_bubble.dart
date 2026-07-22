import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../models/message.dart';
import 'code_block.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isLast;
  final VoidCallback? onRegenerate;
  final VoidCallback? onDelete;

  const MessageBubble({
    Key? key,
    required this.message,
    this.isLast = false,
    this.onRegenerate,
    this.onDelete,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser
        ? theme.colorScheme.primary
        : (theme.brightness == Brightness.dark
            ? const Color(0xFF1E1E2A)
            : const Color(0xFFF3F4F6));
            
    final textStyle = isUser
        ? const TextStyle(color: Colors.white, fontSize: 15)
        : TextStyle(color: theme.colorScheme.onSurface, fontSize: 15);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: align,
        children: [
          // Bubble Sender Identity Label
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 6, right: 6),
            child: Text(
              isUser ? 'You' : 'SmartGPT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),

          // Message Body Bubble
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                  ),
                  child: isUser
                      ? SelectableText(
                          message.content,
                          style: textStyle,
                        )
                      : MarkdownBody(
                          data: message.content,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                            p: textStyle.copyWith(height: 1.5),
                            code: const TextStyle(
                              fontFamily: 'monospace',
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          builders: {
                            'code': CodeElementBuilder(),
                          },
                        ),
                ),
              ),

              if (isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                  child: Icon(
                    Icons.person_rounded,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ],
          ),

          // Action Toolbar below the bubble
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 40, right: 40),
            child: Row(
              mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  tooltip: 'Copy Message',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _copyToClipboard(context),
                ),
                if (onDelete != null && !message.id.startsWith('temp_'))
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    tooltip: 'Delete Message',
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                  ),
                if (!isUser && isLast && onRegenerate != null)
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    tooltip: 'Regenerate Response',
                    visualDensity: VisualDensity.compact,
                    onPressed: onRegenerate,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Element builder for markdown code tags
class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';
    if (element.attributes['class'] != null) {
      String lg = element.attributes['class']!;
      if (lg.startsWith('language-')) {
        language = lg.substring(9);
      }
    }
    return CodeBlock(
      code: element.textContent,
      language: language.isNotEmpty ? language : 'code',
    );
  }
}
