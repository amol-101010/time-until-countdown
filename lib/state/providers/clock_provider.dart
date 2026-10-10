import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ticks once immediately and then once a minute. Screens/widgets that
/// display elapsed-time progress watch this to know when to recompute,
/// since progress isn't stored - it's always derived from `DateTime.now()`.
final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());
});
