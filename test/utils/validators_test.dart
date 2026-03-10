import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_found/utils/validators.dart';

void main() {
  group('Item Validators', () {
    test('validateItemTitle should reject empty title', () {
      final result = Validators.validateItemTitle('');
      expect(result, isNotNull);
      expect(result, contains('required'));
    });

    test('validateItemTitle should reject title less than 3 characters', () {
      final result = Validators.validateItemTitle('AB');
      expect(result, isNotNull);
      expect(result, contains('least 3'));
    });

    test('validateItemTitle should reject title more than 100 characters', () {
      final longTitle = 'A' * 101;
      final result = Validators.validateItemTitle(longTitle);
      expect(result, isNotNull);
      expect(result, contains('less than 100'));
    });

    test('validateItemTitle should accept valid title', () {
      final result = Validators.validateItemTitle('Lost iPhone');
      expect(result, isNull);
    });

    test('validateItemDescription should reject empty description', () {
      final result = Validators.validateItemDescription('');
      expect(result, isNotNull);
    });

    test('validateItemDescription should reject description less than 10 characters', () {
      final result = Validators.validateItemDescription('Short');
      expect(result, isNotNull);
      expect(result, contains('least 10'));
    });

    test('validateItemDescription should accept valid description', () {
      final result = Validators.validateItemDescription('This is a valid description');
      expect(result, isNull);
    });

    test('validateItemLocation should reject empty location', () {
      final result = Validators.validateItemLocation('');
      expect(result, isNotNull);
    });

    test('validateItemLocation should reject location less than 3 characters', () {
      final result = Validators.validateItemLocation('AB');
      expect(result, isNotNull);
    });

    test('validateItemLocation should accept valid location', () {
      final result = Validators.validateItemLocation('Main Library');
      expect(result, isNull);
    });

    test('validateItemDate should reject empty date', () {
      final result = Validators.validateItemDate('');
      expect(result, isNotNull);
    });

    test('validateItemDate should reject invalid date format', () {
      final result = Validators.validateItemDate('2024-03-10');
      expect(result, isNotNull);
      expect(result, contains('MM/dd/yyyy'));
    });

    test('validateItemDate should accept valid date format', () {
      final result = Validators.validateItemDate('03/10/2024');
      expect(result, isNull);
    });

    test('validateMessage should reject empty message', () {
      final result = Validators.validateMessage('');
      expect(result, isNotNull);
    });

    test('validateMessage should accept valid message', () {
      final result = Validators.validateMessage('This is a valid message');
      expect(result, isNull);
    });

    test('validateMessage should reject message over 1000 characters', () {
      final longMessage = 'A' * 1001;
      final result = Validators.validateMessage(longMessage);
      expect(result, isNotNull);
    });
  });

  group('Email & Password Validators', () {
    test('validateNcstEmail should reject invalid email', () {
      final result = Validators.validateNcstEmail('invalidemail');
      expect(result, isNotNull);
    });

    test('validateNcstEmail should accept valid email', () {
      final result = Validators.validateNcstEmail('user@university.com');
      expect(result, isNull);
    });

    test('validatePassword should reject short password', () {
      final result = Validators.validatePassword('123');
      expect(result, isNotNull);
    });

    test('validatePassword should accept valid password', () {
      final result = Validators.validatePassword('ValidPassword123!');
      expect(result, isNull);
    });

    test('validateConfirmPassword should reject non-matching passwords', () {
      final result = Validators.validateConfirmPassword('Pass123', 'Pass456');
      expect(result, isNotNull);
      expect(result, contains('do not match'));
    });

    test('validateConfirmPassword should accept matching passwords', () {
      final result = Validators.validateConfirmPassword('Pass123', 'Pass123');
      expect(result, isNull);
    });
  });
}
