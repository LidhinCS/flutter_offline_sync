import 'package:flutter/material.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('How this works')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Three databases', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          const _Bullet('AppDatabase (app.sqlite) — notes you see in the list'),
          const _Bullet(
            'SyncDatabase (sync_core.sqlite) — outbox jobs & steps',
          ),
          const _Bullet('PullDatabase — pull checkpoints only (page progress)'),
          const SizedBox(height: 24),
          Text('Program flow', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          const _Bullet(
            'Create note → optimistic App DB insert + JobBuilder enqueue',
          ),
          const _Bullet(
            'SyncEngine.syncAll → handlers call FakeNotesApi → upsert App DB',
          ),
          const _Bullet(
            'PullCoordinator.runAll → paginated fake API → upsert App DB',
          ),
          const _Bullet('Reconnect order: push (syncAll) then pull (runAll)'),
          const SizedBox(height: 24),
          Text('Architecture folders', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          const _Bullet(
            'domain/ — entities + repository contract (no sync pkgs)',
          ),
          const _Bullet('data/ — Drift, FakeNotesApi, handlers, repo impl'),
          const _Bullet('presentation/ — screens watch App DB / Sync DB'),
          const _Bullet('core/sync/ — composition root + registries'),
          const SizedBox(height: 24),
          Text(
            'Tip: open Outbox while creating notes to watch SyncDatabase '
            'update independently from the Notes list.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
