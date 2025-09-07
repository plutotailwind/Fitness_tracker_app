import 'dart:math';

class IdGenerator {
  static final Random _random = Random();
  
  static String generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(_random.nextInt(chars.length)))
    );
  }
  
  static String generateChallengeId() {
    return 'challenge_${generateId()}';
  }
  
  static String generateUserId() {
    return 'user_${generateId()}';
  }
} 