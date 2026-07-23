import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About SmartGPT'),
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
              // Logo Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'SmartGPT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Version 1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 32),

              // Description Block
              const Text(
                'Project Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'SmartGPT is a state-of-the-art, full-stack AI Conversational application modeled after ChatGPT. It uses a high-performance Flutter frontend paired with a secure Node.js + Express backend, integrating Mongoose/MongoDB Atlas for cloud persistence and the Groq API cloud for lightning-fast inference.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 24),

              // Feature chips / Bullet list
              const Text(
                'Key Architectural Features',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildFeatureTile(
                context,
                Icons.bolt_rounded,
                'Groq Llama-3 Inference',
                'Supports supercharged generation speeds with real-time SSE streaming.',
              ),
              _buildFeatureTile(
                context,
                Icons.security_rounded,
                'Robust Security Middlewares',
                'Employs JWT authentication, bcrypt hash salts, rate limiters, and Helmet configurations.',
              ),
              _buildFeatureTile(
                context,
                Icons.memory_rounded,
                'Full Conversation Memory',
                'Stores and sends historical conversation pairs to models to ensure context-aware responses.',
              ),
              _buildFeatureTile(
                context,
                Icons.code_rounded,
                'Markdown & Code Copying',
                'Renders rich markdown layouts with horizontal scrolling code blocks and clipboard tools.',
              ),
              _buildFeatureTile(
                context,
                Icons.sync_rounded,
                'Session Recall & Auto-Login',
                'Saves JWT keys in local storage to bypass logins on app restarts.',
              ),
              
              const SizedBox(height: 32),
              // Footer signature
              Text(
                'Built for Portfolio & Internship Demo\n© 2026 SmartGPT Team. All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
      BuildContext context, IconData icon, String title, String desc) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
