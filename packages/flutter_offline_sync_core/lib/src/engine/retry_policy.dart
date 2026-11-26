import 'dart:math';

/// Exponential backoff with a cap and jitter, so a step that keeps failing
/// (e.g. no connectivity) doesn't hammer the server on every sync trigger,
/// and so many steps/devices retrying around the same moment (e.g. right
/// after connectivity returns for everyone at once) don't all land on the
/// exact same retry instant.
class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 5,
    this.baseDelay = const Duration(seconds: 10),
    this.maxDelay = const Duration(minutes: 30),
    this.jitterFraction = 0.2,
  }) : assert(jitterFraction >= 0 && jitterFraction <= 1);

  final int maxAttempts;
  final Duration baseDelay;
  final Duration maxDelay;

  /// Fraction of the computed delay to randomize by, in both directions.
  /// e.g. 0.2 means the actual delay is the base value +/- 20%. Set to 0
  /// to disable jitter (useful in tests that assert exact delays).
  final double jitterFraction;

  bool shouldRetry(int attempt) => attempt < maxAttempts;

  Duration delayFor(int attempt, {Random? random}) {
    final seconds = baseDelay.inSeconds * (1 << attempt.clamp(0, 10));
    final capped = seconds > maxDelay.inSeconds ? maxDelay.inSeconds : seconds;

    if (jitterFraction == 0) return Duration(seconds: capped);

    final rand = random ?? Random();
    // Uniform in [1 - jitterFraction, 1 + jitterFraction].
    final factor = 1 + (rand.nextDouble() * 2 - 1) * jitterFraction;
    final jittered = (capped * factor).round();
    return Duration(seconds: jittered.clamp(0, maxDelay.inSeconds));
  }
}
