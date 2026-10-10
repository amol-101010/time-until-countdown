import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dash/app.dart';
import 'package:dash/data/repositories/event_repository.dart';
import 'package:dash/models/event.dart';
import 'package:dash/state/providers/clock_provider.dart';
import 'package:dash/state/providers/database_provider.dart';

/// Never emits during the test, so eventListProvider (and therefore
/// appBootstrapProvider) stays in AsyncLoading - exactly the state this
/// smoke test checks for. Avoids touching the real drift/sqlite database,
/// which spawns a background isolate that leaves a pending Timer at test
/// teardown (flutter_test's binding asserts none remain).
class _FakeEventRepository implements EventRepository {
  final _controller = StreamController<List<Event>>.broadcast();

  @override
  Stream<List<Event>> watchAll() => _controller.stream;

  @override
  Stream<List<Event>> watchAllIncludingDeleted() => _controller.stream;

  @override
  Future<void> upsert(Event event) async {}

  @override
  Future<void> upsertRaw(Event event) async {}

  @override
  Future<void> delete(String id) async {}
}

void main() {
  testWidgets('App boots and shows a loading state before data is ready', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventRepositoryProvider.overrideWithValue(_FakeEventRepository()),
          // Avoid a real Timer.periodic in tests: flutter_test's binding
          // asserts no pending timers remain when a test finishes.
          clockProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        ],
        child: const DashApp(),
      ),
    );
    // One frame only: async providers (settings, bootstrap) are still
    // resolving.
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
