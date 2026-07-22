import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/chat_history_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const List<Map<String, String>> _samplePrompts = [
    {
      'title': 'Write a Python Script',
      'subtitle': 'To download YouTube thumbnails or parse HTML data',
      'prompt': 'Write a clean, documented Python script to fetch metadata from a URL.',
      'icon': '🐍'
    },
    {
      'title': 'Explain Like I\'m 5',
      'subtitle': 'The concept of Quantum Computing or APIs',
      'prompt': 'Explain quantum computing in extremely simple terms with a real-life analogy.',
      'icon': '💡'
    },
    {
      'title': 'Refactor Code',
      'subtitle': 'Improve readability and apply clean architecture',
      'prompt': 'Review this pseudocode and refactor it according to DRY and SOLID principles: \n```\nfunction printData(d) { console.log(d); }\n```',
      'icon': '🛠️'
    },
    {
      'title': 'Draft an Email',
      'subtitle': 'Professional request for sick leave or promotion',
      'prompt': 'Write a professional email requesting a week of medical leave starting tomorrow.',
      'icon': '✉️'
    }
  ];

  Future<void> _handlePromptClick(BuildContext context, String promptText, String title) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    // Create new chat room
    final chat = await chatProvider.createChat(title);
    if (chat != null && context.mounted) {
      // Route to Chat screen
      Navigator.pushReplacementNamed(context, AppRoutes.chat);
      // Automatically send the selected prompt
      chatProvider.sendMessage(promptText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartGPT Dashboard'),
      ),
      drawer: const ChatHistoryDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Greeting Header
              Text(
                'Hello, ${authProvider.currentUser?.name.split(' ').first ?? 'User'} 👋',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'How can I help you today?',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),

              // Welcome prompt choices grid header
              const Text(
                'Get Started with Quick Prompts',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Quick Prompts list/grid
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _samplePrompts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _samplePrompts[index];
                    return InkWell(
                      onTap: () => _handlePromptClick(
                        context,
                        item['prompt']!,
                        item['title']!,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
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
                          boxShadow: theme.brightness == Brightness.light
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(
                              item['icon']!,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['subtitle']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
