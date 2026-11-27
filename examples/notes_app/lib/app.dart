import 'package:flutter/material.dart';
import 'package:flutter_offline_sync_ui/flutter_offline_sync_ui.dart';

import 'core/sync/app_services.dart';
import 'features/notes/presentation/create_note_screen.dart';
import 'features/notes/presentation/how_it_works_screen.dart';
import 'features/notes/presentation/notes_list_screen.dart';
import 'features/notes/presentation/outbox_screen.dart';

class NotesApp extends StatefulWidget {
  const NotesApp({required this.services, super.key});

  final AppServices services;

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final services = widget.services;
    final pages = [
      NotesListScreen(services: services),
      CreateNoteScreen(services: services),
      OutboxScreen(services: services),
      const HowItWorksScreen(),
    ];

    return OfflineSyncScope(
      db: services.syncDb,
      engine: services.engine,
      child: MaterialApp(
        title: 'Offline Notes',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F6E56)),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: IndexedStack(index: _index, children: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.notes_outlined),
                selectedIcon: Icon(Icons.notes),
                label: 'Notes',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                selectedIcon: Icon(Icons.add_circle),
                label: 'Create',
              ),
              NavigationDestination(
                icon: Icon(Icons.outbox_outlined),
                selectedIcon: Icon(Icons.outbox),
                label: 'Outbox',
              ),
              NavigationDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: 'Guide',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
