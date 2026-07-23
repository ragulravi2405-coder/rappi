import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    final user = authProvider.currentUser;
    final chatCount = chatProvider.chats.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Big Profile Circle Initials
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    user?.name.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name & Email Header
              Text(
                user?.name ?? 'User Name',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'user@gmail.com',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF1E1E2A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF2D2D3D)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            chatCount.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Chats Created',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF1E1E2A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF2D2D3D)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.security_outlined,
                            color: theme.colorScheme.secondary,
                            size: 28,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'JWT Active',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Session Secured',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Account Details List
              Container(
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF1E1E2A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF2D2D3D)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: const Text('Account Status'),
                      trailing: Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('User ID'),
                      subtitle: Text(
                        user?.id ?? '0000000000000000',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
