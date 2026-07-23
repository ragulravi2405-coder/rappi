import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../routes/app_routes.dart';

class ChatHistoryDrawer extends StatefulWidget {
  const ChatHistoryDrawer({super.key});

  @override
  State<ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends State<ChatHistoryDrawer> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load chats on drawer opening
    Future.microtask(() {
      if (mounted) {
        Provider.of<ChatProvider>(context, listen: false).loadChats();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRenameDialog(String chatId, String currentTitle) {
    final titleController = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Conversation'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Chat Title',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTitle = titleController.text.trim();
                if (newTitle.isNotEmpty) {
                  final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  final success = await chatProvider.renameChat(chatId, newTitle);
                  navigator.pop();
                  if (!success) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Failed to rename chat')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(String chatId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Chat?'),
          content: const Text(
            'This will permanently delete this conversation and all associated messages.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final success = await chatProvider.deleteChat(chatId);
                navigator.pop();
                if (success && chatProvider.selectedChat == null) {
                  navigator.pushReplacementNamed(AppRoutes.home);
                } else if (!success) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Failed to delete chat')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    final filteredChats = chatProvider.chats.where((chat) {
      return chat.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header (User info)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      authProvider.currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.currentUser?.name ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          authProvider.currentUser?.email ?? 'user@gmail.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // "New Chat" Action Button
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  
                  final newChat = await chatProvider.createChat('New Conversation');
                  if (newChat != null) {
                    navigator.pushReplacementNamed(AppRoutes.chat);
                  }
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('New Chat'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  foregroundColor: theme.colorScheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // "Search Chats" Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
              ),
            ),
            const SizedBox(height: 8),

            // Chats History List
            Expanded(
              child: chatProvider.isChatsLoading && chatProvider.chats.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filteredChats.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty ? 'No conversations yet' : 'No chats found',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              fontSize: 13,
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredChats.length,
                          itemBuilder: (context, index) {
                            final chat = filteredChats[index];
                            final isSelected = chatProvider.selectedChat?.id == chat.id;

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                dense: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.only(left: 12, right: 4),
                                leading: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 16,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                                title: Text(
                                  chat.title,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                    fontSize: 13.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    size: 16,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                  padding: EdgeInsets.zero,
                                  onSelected: (action) {
                                    if (action == 'rename') {
                                      _showRenameDialog(chat.id, chat.title);
                                    } else if (action == 'delete') {
                                      _showDeleteDialog(chat.id);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'rename',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 16),
                                          SizedBox(width: 8),
                                          Text('Rename', style: TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(fontSize: 13, color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  chatProvider.selectChat(chat);
                                  Navigator.pushReplacementNamed(context, AppRoutes.chat);
                                },
                              ),
                            );
                          },
                        ),
            ),
            const Divider(height: 1),

            // Footer Sidebar Actions (Settings, Profile, About, Logout)
            Column(
              children: [
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.person_outline_rounded, size: 20),
                  title: const Text('View Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.settings_outlined, size: 20),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.settings);
                  },
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.info_outline_rounded, size: 20),
                  title: const Text('About SmartGPT'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.about);
                  },
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.logout_rounded, size: 20, color: Colors.redAccent),
                  title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
                  onTap: () async {
                    final navigator = Navigator.of(context);
                    navigator.pop();
                    await authProvider.logout();
                    navigator.pushNamedAndRemoveUntil(
                        AppRoutes.login, (route) => false);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
