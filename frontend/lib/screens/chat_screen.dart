import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_history_drawer.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../routes/app_routes.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Scroll to bottom after frame rendering completes
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(isAnimated: false));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool isAnimated = true}) {
    if (!mounted || !_scrollController.hasClients) return;
    
    if (isAnimated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    _focusNode.requestFocus();
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(text);
    
    // Smooth scroll down
    Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
  }

  void _shareChatHistory() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (chatProvider.messages.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln("SmartGPT Conversation Share: ${chatProvider.selectedChat?.title}\n");
    for (var msg in chatProvider.messages) {
      buffer.writeln(msg.isUser ? "USER: " : "ASSISTANT: ");
      buffer.writeln("${msg.content}\n");
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conversation copied to clipboard to share!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    // Scroll to bottom dynamically if generating
    if (chatProvider.isAiGenerating || chatProvider.streamingText.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    // Also trigger scroll when messages change size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _scrollController.position.atEdge) {
        _scrollToBottom(isAnimated: false);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(chatProvider.selectedChat?.title ?? 'Chat'),
        actions: [
          if (chatProvider.messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Share Conversation',
              onPressed: _shareChatHistory,
            ),
          IconButton(
            icon: const Icon(Icons.dashboard_customize_outlined),
            tooltip: 'Dashboard',
            onPressed: () {
              chatProvider.clearSelection();
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
        ],
      ),
      drawer: const ChatHistoryDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Error panel if any occurs
            if (chatProvider.errorMessage != null)
              Container(
                color: theme.colorScheme.errorContainer,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        chatProvider.errorMessage!,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => chatProvider.sendMessage(_inputController.text),
                      // We can just trigger a simple clear or retry
                    )
                  ],
                ),
              ),

            // Messages feed
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (chatProvider.selectedChat != null) {
                    await chatProvider.loadMessages(chatProvider.selectedChat!.id);
                  }
                },
                child: chatProvider.isMessagesLoading && chatProvider.messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : chatProvider.messages.isEmpty && chatProvider.streamingText.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 64,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No messages yet',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Type your prompt below to start.'),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            itemCount: chatProvider.messages.length +
                                (chatProvider.streamingText.isNotEmpty ? 1 : 0) +
                                (chatProvider.isAiGenerating && chatProvider.streamingText.isEmpty ? 1 : 0),
                            itemBuilder: (context, index) {
                              // If it's the streaming item
                              if (index == chatProvider.messages.length) {
                                if (chatProvider.streamingText.isNotEmpty) {
                                  // Stream bubble
                                  return MessageBubble(
                                    message: Message(
                                      id: 'stream',
                                      chatId: chatProvider.selectedChat!.id,
                                      role: 'assistant',
                                      content: chatProvider.streamingText,
                                      timestamp: DateTime.now(),
                                    ),
                                  );
                                } else {
                                  // Typing/Thinking placeholder
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                          child: Icon(
                                            Icons.auto_awesome_rounded,
                                            size: 16,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const TypingIndicator(),
                                      ],
                                    ),
                                  );
                                }
                              }

                              final message = chatProvider.messages[index];
                              final isLast = index == chatProvider.messages.length - 1;

                              return MessageBubble(
                                message: message,
                                isLast: isLast,
                                onRegenerate: () => chatProvider.regenerateResponse(),
                                onDelete: () => chatProvider.deleteMessage(message.id),
                              );
                            },
                          ),
              ),
            ),

            // Quick Actions (Regenerate / Continue)
            if (chatProvider.messages.isNotEmpty && !chatProvider.isAiGenerating)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Regenerate'),
                      onPressed: () {
                        chatProvider.regenerateResponse();
                      },
                    ),
                    const SizedBox(width: 12),
                    ActionChip(
                      avatar: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text('Continue'),
                      onPressed: () {
                        chatProvider.continueResponse();
                      },
                    ),
                  ],
                ),
              ),

            // Bottom Input Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Ask anything...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: chatProvider.isAiGenerating ? null : _handleSend,
                    elevation: 0,
                    backgroundColor: chatProvider.isAiGenerating
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.1)
                        : theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    child: chatProvider.isAiGenerating
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
