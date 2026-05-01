import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/constant/app_theme.dart';
import '../../data/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use plain Text for user messages, Markdown for AI messages
            if (isUser)
              Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              )
            else
              MarkdownBody(
                data: message.text,
                shrinkWrap: true,
                styleSheet: MarkdownStyleSheet(
                  // Regular text
                  p: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  // Bold text (**text**)
                  strong: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                  // Italic text (*text*)
                  em: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                  // Bullet list items
                  listBullet: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                    fontSize: 15,
                  ),
                  // Inline code (`code`)
                  code: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 13,
                    fontFamily: 'monospace',
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                  // Headings (# Heading)
                  h1: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  h2: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  h3: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  // Block quote (> text)
                  blockquote: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                  // Spacing
                  blockSpacing: 6,
                  listIndent: 16,
                ),
              ),

            // "Calorie Advice" tag for relevant messages
            if (message.isCalorieRelated && !isUser) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Calorie Advice',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
