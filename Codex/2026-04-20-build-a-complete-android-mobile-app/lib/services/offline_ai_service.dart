import '../core/constants/app_identity.dart';

class OfflineAiService {
  String generateReply({
    required String prompt,
    required String preferredLanguage,
    String? imagePath,
  }) {
    final String trimmed = prompt.trim();
    final String language = _resolveLanguage(trimmed, preferredLanguage);

    if (_isIdentityQuestion(trimmed)) {
      return AppIdentity.identityAnswer(language);
    }

    final _ArithmeticResult? arithmetic = _tryArithmetic(trimmed);
    final bool hasImage = imagePath != null && imagePath.isNotEmpty;

    if (language == 'bengali') {
      return _bengaliReply(trimmed, arithmetic, hasImage);
    }
    if (language == 'dual') {
      return '${_englishReply(trimmed, arithmetic, hasImage)}\n\n${_bengaliReply(trimmed, arithmetic, hasImage)}';
    }
    return _englishReply(trimmed, arithmetic, hasImage);
  }

  String _resolveLanguage(String text, String preferredLanguage) {
    if (preferredLanguage != 'auto') {
      return preferredLanguage;
    }

    final RegExp bengali = RegExp(r'[\u0980-\u09FF]');
    return bengali.hasMatch(text) ? 'bengali' : 'english';
  }

  bool _isIdentityQuestion(String text) {
    final String value = text.toLowerCase();
    return value.contains('who are you') ||
        value.contains('who built you') ||
        value.contains('who made you') ||
        value.contains('created you') ||
        value.contains('developer') ||
        value.contains('designer') ||
        value.contains('logo') ||
        value.contains('তুমি কে') ||
        value.contains('পরিচয়');
  }

  _ArithmeticResult? _tryArithmetic(String text) {
    final RegExp expression = RegExp(r'(-?\d+(?:\.\d+)?)\s*([\+\-\*xX/])\s*(-?\d+(?:\.\d+)?)');
    final Match? match = expression.firstMatch(text);
    if (match == null) {
      return null;
    }

    final double left = double.parse(match.group(1)!);
    final double right = double.parse(match.group(3)!);
    final String op = match.group(2)!;

    late final double answer;
    switch (op) {
      case '+':
        answer = left + right;
      case '-':
        answer = left - right;
      case '*':
      case 'x':
      case 'X':
        answer = left * right;
      case '/':
        if (right == 0) {
          return const _ArithmeticResult(problem: '', answer: 'undefined');
        }
        answer = left / right;
      default:
        return null;
    }

    final String answerText = answer == answer.roundToDouble()
        ? answer.toStringAsFixed(0)
        : answer.toStringAsFixed(2);

    return _ArithmeticResult(
      problem: '${match.group(1)} $op ${match.group(3)}',
      answer: answerText,
    );
  }

  String _englishReply(String prompt, _ArithmeticResult? arithmetic, bool hasImage) {
    final StringBuffer buffer = StringBuffer()
      ..writeln('Shindhu Offline Tutor')
      ..writeln()
      ..writeln('Step-by-step:')
      ..writeln('1. Read the question carefully and identify the core concept.')
      ..writeln('2. Break the problem into smaller parts before jumping to the answer.');

    if (arithmetic != null) {
      buffer
        ..writeln('3. Solve the expression ${arithmetic.problem}.')
        ..writeln('4. Final answer: ${arithmetic.answer}.');
    } else {
      buffer
        ..writeln('3. Recall the related rule, formula, or fact.')
        ..writeln('4. Write the answer in exam-friendly points.');
    }

    buffer
      ..writeln()
      ..writeln('Simple explanation:')
      ..writeln(arithmetic != null
          ? 'This is a direct calculation, so accuracy matters more than speed. Work one operation at a time.'
          : 'Since offline mode is active, I will guide you using stored study logic and clear exam strategy.');

    if (hasImage) {
      buffer
        ..writeln()
        ..writeln('Image note:')
        ..writeln('I can see that you attached an image, but offline mode cannot fully read it. Type the question text for a more exact answer, or enable online AI later.');
    }

    buffer
      ..writeln()
      ..writeln('Exam tip:')
      ..writeln('Revise the key point once more and solve one similar question immediately.');

    return buffer.toString().trim();
  }

  String _bengaliReply(String prompt, _ArithmeticResult? arithmetic, bool hasImage) {
    final StringBuffer buffer = StringBuffer()
      ..writeln('Shindhu Offline Tutor')
      ..writeln()
      ..writeln('ধাপে ধাপে ব্যাখ্যা:')
      ..writeln('1. প্রশ্নটি ভাল করে পড়ে মূল concept ধরো।')
      ..writeln('2. বড় সমস্যাকে ছোট ধাপে ভেঙে নাও।');

    if (arithmetic != null) {
      buffer
        ..writeln('3. ${arithmetic.problem} expression টি solve করো।')
        ..writeln('4. Final answer: ${arithmetic.answer}.');
    } else {
      buffer
        ..writeln('3. প্রয়োজনীয় rule, formula, বা fact মনে করো।')
        ..writeln('4. Exam-friendly point আকারে উত্তর লিখো।');
    }

    buffer
      ..writeln()
      ..writeln('সহজ ভাষায়:')
      ..writeln(arithmetic != null
          ? 'এটি একটি সরাসরি calculation। তাই তাড়াহুড়োর চেয়ে সঠিক ধাপ বেশি গুরুত্বপূর্ণ।'
          : 'অফলাইন মোডে আমি stored logic দিয়ে তোমাকে conceptually সাহায্য করছি।');

    if (hasImage) {
      buffer
        ..writeln()
        ..writeln('Image note:')
        ..writeln('তুমি একটি image attach করেছ, কিন্তু offline mode-এ পুরো image question পড়া যায় না। প্রশ্নটি type করলে আমি আরও নির্ভুলভাবে সাহায্য করতে পারব।');
    }

    buffer
      ..writeln()
      ..writeln('Study tip:')
      ..writeln('একই ধরনের আরও একটি প্রশ্ন এখনই solve করে practice করো।');

    return buffer.toString().trim();
  }
}

class _ArithmeticResult {
  const _ArithmeticResult({
    required this.problem,
    required this.answer,
  });

  final String problem;
  final String answer;
}
