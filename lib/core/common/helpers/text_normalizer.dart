/// Language-agnostic text normalisation used by the search feature.
///
/// It is a **pure, dependency free** utility so it can be unit tested without
/// any Flutter binding, and so both the repository and the cubit can rely on
/// exactly the same rules.
///
/// Two scripts are supported at the same time:
///
/// * **English** - case insensitive, whitespace and punctuation insensitive.
/// * **Arabic**  - diacritics (tashkeel) and tatweel are removed, and the
///   common orthographic variants are folded together so that a user typing
///   `سوره الفاتحه` still finds `سُورَة ٱلْفَاتِحَة`.
abstract final class AppTextNormalizer {
  const AppTextNormalizer._();

  /// Arabic diacritics, superscript alef, Quranic marks and tatweel.
  ///
  /// Written with explicit code points on purpose. The *letters* of the Arabic
  /// alphabet live in `U+0620..U+064A`, which is why the harakat range starts at
  /// `U+064B` - widening it (e.g. to `U+0610`) would silently delete real
  /// letters. The ranges are also split around `U+0660..U+0669` (Arabic-Indic
  /// digits) and `U+06DE` / `U+06E9` (Arabic punctuation) so those survive.
  static final RegExp _diacritics = RegExp(
    '[ً-ٕ' // U+064B..U+0652 tanween, fatha..sukun, shadda
    'ٓ-ٕ' // U+0653..U+0655 maddah, hamza above, hamza below
    'ٰ' //        U+0670        superscript alef
    'ۖ-ۜ' // U+06D6..U+06DC small high Quranic marks
    '۟-ۨ' // U+06DF..U+06E8 small low marks
    '۪-ۭ' // U+06EA..U+06ED
    'ـ]', // U+0640 tatweel
  );

  /// Arabic letter variants that must be treated as the same character.
  ///
  /// | Variant | Folded to |
  /// |---|---|
  /// | أ إ آ ٱ ٲ ٳ ٵ | ا |
  /// | ة | ه |
  /// | ى ی | ي |
  /// | ئ | ي |
  /// | ؤ | و |
  /// | ک | ك |
  static const Map<String, String> _letterVariants = <String, String>{
    'أ': 'ا', // أ
    'إ': 'ا', // إ
    'آ': 'ا', // آ
    'ٱ': 'ا', // ٱ
    'ٲ': 'ا', // ٲ
    'ٳ': 'ا', // ٳ
    'ٵ': 'ا', // ٵ
    'ى': 'ي', // ى
    'ئ': 'ي', // ئ
    'ؤ': 'و', // ؤ
    'ة': 'ه', // ة
    'ک': 'ك', // ک -> ك
    'ی': 'ي', // ی -> ي
  };

  static final RegExp _variants = RegExp('[${_letterVariants.keys.join()}]');

  /// Arabic-Indic (٠..٩) and Extended Arabic-Indic (۰..۹) digits.
  static final RegExp _arabicDigits = RegExp('[٠-٩۰-۹]');

  static final RegExp _whitespace = RegExp(r'\s+');

  /// Everything that is **not** a letter, a digit or a space.
  ///
  /// Turning punctuation into a separator makes `sura-fatiha` and `sura fatiha`
  /// equivalent.
  ///
  /// Note: Dart's [RegExp] has no `\p{L}` support, so the kept ranges are
  /// listed explicitly: Arabic, Arabic Supplement, Arabic Extended-A/B,
  /// Presentation Forms-A/B, Latin and digits.
  static final RegExp _punctuation = RegExp(
    '[^'
    r'\u0041-\u005A' // A-Z
    r'\u0061-\u007A' // a-z
    r'\u0030-\u0039' // 0-9
    r'\u0600-\u06FF' // Arabic
    r'\u0750-\u077F' // Arabic Supplement
    r'\u08A0-\u08FF' // Arabic Extended-A
    r'\uFB50-\uFDFF' // Presentation Forms-A
    r'\uFE70-\uFEFF' // Presentation Forms-B
    r'\s]', // whitespace
  );

  /// Collapses every orthographic variant into its canonical form.
  ///
  /// `normalize('سُورَة ٱلْفَاتِحَة')` and `normalize('سوره الفاتحه')` both return
  /// `'سوره الفاتحه'`.
  static String normalize(String input) {
    if (input.isEmpty) return '';

    String value = input.toLowerCase();

    // 1. Strip diacritics first, otherwise step 2 can never match.
    value = value.replaceAll(_diacritics, '');

    // 2. Fold Arabic orthographic variants.
    value = value.replaceAllMapped(
      _variants,
      (Match match) => _letterVariants[match[0]!]!,
    );

    // 3. Arabic-Indic digits -> ASCII digits.
    value = value.replaceAllMapped(_arabicDigits, (Match match) {
      final int code = match[0]!.runes.first;
      final int base = code >= 0x06F0 ? 0x06F0 : 0x0660;
      return '${code - base}';
    });

    // 4. Punctuation acts as a separator.
    value = value.replaceAll(_punctuation, ' ');

    // 5. Collapse repeated whitespace.
    value = value.replaceAll(_whitespace, ' ');

    return value.trim();
  }

  /// Splits a string into normalised search tokens.
  static List<String> tokenize(String input) {
    final String normalized = normalize(input);
    if (normalized.isEmpty) return const <String>[];
    return normalized
        .split(' ')
        .where((String token) => token.isNotEmpty)
        .toList(growable: false);
  }

  /// Levenshtein distance, used as a last-resort fuzzy fallback.
  static int levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<int> previous = List<int>.generate(b.length + 1, (int i) => i);
    List<int> current = List<int>.filled(b.length + 1, 0);

    for (int i = 0; i < a.length; i++) {
      current[0] = i + 1;
      for (int j = 0; j < b.length; j++) {
        final int cost = a[i] == b[j] ? 0 : 1;
        final int deletion = previous[j + 1] + 1;
        final int insertion = current[j] + 1;
        final int substitution = previous[j] + cost;
        current[j + 1] = deletion < insertion
            ? (deletion < substitution ? deletion : substitution)
            : (insertion < substitution ? insertion : substitution);
      }
      final List<int> swap = previous;
      previous = current;
      current = swap;
    }

    return previous[b.length];
  }

  /// Similarity between two normalised strings, in the `0.0 .. 1.0` range.
  static double similarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0;
    if (a == b) return 1;

    final int distance = levenshtein(a, b);
    final int longest = a.length > b.length ? a.length : b.length;
    return (1 - (distance / longest)).clamp(0.0, 1.0);
  }



  /// Relevance score of [rawNeedle] (a query) inside [rawHaystack] (a title).
  ///
  /// * `0`      - no match at all.
  /// * `1..99`  - the higher, the stronger the match.
  /// * `100`    - exact equality.
  ///
  /// Results are ranked by *intent* rather than alphabetically:
  ///
  /// | Score | Match type |
  /// |---|---|
  /// | 100 | exact equality |
  /// | 90 | title starts with the query |
  /// | 80 | a word of the title starts with the query |
  /// | 70 | every query token is present (any order) |
  /// | 60 | tokens present in the same order |
  /// | 40 | substring match |
  /// | 1-39 | fuzzy (typo tolerant), scaled by similarity |
  static int score(String rawHaystack, String rawNeedle) {
    final String haystack = normalize(rawHaystack);
    final String needle = normalize(rawNeedle);
    if (needle.isEmpty || haystack.isEmpty) return 0;

    if (haystack == needle) return 100;
    if (haystack.startsWith(needle)) return 90;

    final List<String> haystackWords = haystack.split(' ');
    final List<String> needleTokens = needle.split(' ');

    // A word of the title starts with the whole query.
    for (final String word in haystackWords) {
      if (word.startsWith(needle)) return 80;
    }

    // Every token of the query appears somewhere in the title.
    final bool allTokensPresent = needleTokens.every(
      (String token) => haystackWords.any(
        (String word) => word == token || word.startsWith(token),
      ),
    );
    if (allTokensPresent) return 70;

    // Tokens in the same relative order.
    if (_isOrderedSubsequence(needleTokens, haystackWords)) return 60;

    // Plain substring.
    if (haystack.contains(needle)) return 40;

    // Typo tolerance, token by token, keeping the weakest link.
    double worst = 1;
    for (final String token in needleTokens) {
      double best = 0;
      for (final String word in haystackWords) {
        final double candidate = similarity(token, word);
        if (candidate > best) best = candidate;
      }
      if (best < worst) worst = best;
    }

    // >= 0.62 similarity is a confident match, below that it is noise.
    if (worst < 0.62) return 0;
    return (worst * 39).round().clamp(1, 39);
  }

  /// `true` when [tokens] appear inside [words] in the same relative order.
  static bool _isOrderedSubsequence(List<String> tokens, List<String> words) {
    if (tokens.isEmpty) return false;

    int cursor = 0;
    for (final String word in words) {
      if (word.startsWith(tokens[cursor])) {
        cursor++;
        if (cursor == tokens.length) return true;
      }
    }
    return false;
  }
}
