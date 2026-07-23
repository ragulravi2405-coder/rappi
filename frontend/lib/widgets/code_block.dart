import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeBlock extends StatelessWidget {
  final String code;
  final String language;

  const CodeBlock({
    super.key,
    required this.code,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final headerBgColor = isDark ? const Color(0xFF151520) : const Color(0xFFE5E7EB);
    final codeBgColor = isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF3F4F6);
    final borderColor = isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE5E7EB);
    final textColor = isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937);
    final labelColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: codeBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Code Block Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: headerBgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language.isEmpty ? 'CODE' : language.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                    letterSpacing: 1.0,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code.trim()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Code copied to clipboard!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.copy_all_rounded,
                          size: 14,
                          color: labelColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: labelColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Code Block Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Text(
                code.trim(),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.4,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
